"""
extractor.py
=====================
Reusable MediaPipe landmark extractor (Pose + Hand + Face).
Hanya menyimpan & menggambar subset landmark yang relevan:
  - Pose : 9 titik upper-body + skeleton (POSE_UPPER_IDX, POSE_CONNECTIONS)
  - Hand : 21 titik + skeleton (HAND_CONNECTIONS)
  - Face : 478 titik (x, y, z) + kontur (FACE_CONNECTIONS)

Usage (single video):
    from src.extractor import LandmarkExtractor
    ext = LandmarkExtractor()
    result = ext.process_video("input.mp4", out_video_path="output.mp4")
    # result = ext.process_video("input.mp4", out_blank_video_path="blank.mp4")
    # result.pose  : [T, 9,   4]
    # result.hands : [T, 2, 21, 3]
    # result.face  : [T, 478, 3]

Usage (batch):
    results = LandmarkExtractor().process_folder(
        "videos/",
        out_video_dir="videos_out/",
        out_npy_dir="npy_out/",
        out_blank_video_dir="blank_out/",
    )
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import cv2
import mediapipe as mp
import numpy as np

logger = logging.getLogger(__name__)

VIDEO_EXTENSIONS = {".mp4", ".avi", ".mov", ".mkv", ".webm", ".flv", ".wmv"}

# ---------------------------------------------------------------------------
# Subset definitions
# ---------------------------------------------------------------------------

# Upper-body pose landmarks (dari 33 total)
POSE_UPPER_IDX = [0, 11, 12, 13, 14, 15, 16, 23, 24]

# Upper-body pose skeleton connections
POSE_CONNECTIONS = [
    (11, 12),  # bahu kiri - bahu kanan
    (11, 13),  # bahu kiri - siku kiri
    (13, 15),  # siku kiri - pergelangan tangan kiri
    (12, 14),  # bahu kanan - siku kanan
    (14, 16),  # siku kanan - pergelangan tangan kanan
    (11, 23),  # bahu kiri - pinggul kiri
    (12, 24),  # bahu kanan - pinggul kanan
    (23, 24),  # pinggul kiri - pinggul kanan
]

# Hand skeleton connections (semua 21 landmark dipakai, koneksi digambar)
HAND_CONNECTIONS = [
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 4),  # ibu jari
    (0, 5),
    (5, 6),
    (6, 7),
    (7, 8),  # telunjuk
    (0, 9),
    (9, 10),
    (10, 11),
    (11, 12),  # jari tengah
    (0, 13),
    (13, 14),
    (14, 15),
    (15, 16),  # jari manis
    (0, 17),
    (17, 18),
    (18, 19),
    (19, 20),  # kelingking
    (5, 9),
    (9, 13),
    (13, 17),  # telapak
]

# Full landmark counts (MediaPipe spec)
N_POSE_FULL = 33
N_HAND = 21
N_FACE = 478

# Face contour connections (MediaPipe spec: contours + left/right iris)
FACE_CONNECTIONS: list[tuple[int, int]] = (
    [
        (c.start, c.end)
        for c in mp.tasks.vision.FaceLandmarksConnections.FACE_LANDMARKS_CONTOURS
    ]
    + [
        (c.start, c.end)
        for c in mp.tasks.vision.FaceLandmarksConnections.FACE_LANDMARKS_LEFT_IRIS
    ]
    + [
        (c.start, c.end)
        for c in mp.tasks.vision.FaceLandmarksConnections.FACE_LANDMARKS_RIGHT_IRIS
    ]
)


# ---------------------------------------------------------------------------
# Config dataclass
# ---------------------------------------------------------------------------
@dataclass
class ExtractorConfig:
    pose_model_path: str = "tasks/pose_landmarker_heavy.task"
    hand_model_path: str = "tasks/hand_landmarker.task"
    face_model_path: str = "tasks/face_landmarker.task"

    # Pose
    num_poses: int = 1
    pose_detection_conf: float = 0.5
    pose_presence_conf: float = 0.5
    pose_tracking_conf: float = 0.5

    # Hand
    num_hands: int = 2
    hand_detection_conf: float = 0.3
    hand_presence_conf: float = 0.3
    hand_tracking_conf: float = 0.3

    num_faces: int = 1
    face_detection_conf: float = 0.3
    face_presence_conf: float = 0.3
    face_tracking_conf: float = 0.3

    # Drawing toggles
    draw_pose: bool = True
    draw_hands: bool = True
    draw_face: bool = True

    # Drawing style
    pose_color: tuple[int, int, int] = (0, 255, 0)  # BGR green
    hand_color: tuple[int, int, int] = (0, 0, 255)  # BGR red
    face_color: tuple[int, int, int] = (0, 255, 255)  # BGR yellow
    pose_radius: int = 4
    hand_radius: int = 3
    face_radius: int = 1
    pose_line_thickness: int = 1
    hand_line_thickness: int = 1
    face_line_thickness: int = 1

    # Blank video options
    blank_background: bool = False
    blank_bg_color: tuple[int, int, int] = (0, 0, 0)  # BGR black

    fourcc: str = "mp4v"


# ---------------------------------------------------------------------------
# Result dataclass
# ---------------------------------------------------------------------------
@dataclass
class ExtractionResult:
    """
    pose  : [T, len(POSE_UPPER_IDX), 4]   (x, y, z, visibility)
    hands : [T, 2, N_HAND,           3]   (hand_idx, landmark, xyz)
    face  : [T, N_FACE,              3]   (landmark, xyz)
    """

    video_path: str
    total_frames: int
    fps: float
    pose: np.ndarray = field(default_factory=lambda: np.array([]))
    hands: np.ndarray = field(default_factory=lambda: np.array([]))
    face: np.ndarray = field(default_factory=lambda: np.array([]))


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _landmarks_to_array(
    list_lm: list,
    extra_fields: Optional[list[str]] = None,
) -> np.ndarray:
    """Convert MediaPipe landmark list → float32 array [N, 3+extras]."""
    cols = ["x", "y", "z"] + (extra_fields or [])
    arr = np.full((len(list_lm), len(cols)), np.nan, dtype=np.float32)
    for i, lm in enumerate(list_lm):
        for j, name in enumerate(cols):
            arr[i, j] = getattr(lm, name, np.nan)
    return arr


def _subset(arr: np.ndarray, indices: list[int]) -> np.ndarray:
    """Select rows by index list; out-of-range indices → NaN row."""
    out = np.full((len(indices), arr.shape[1]), np.nan, dtype=np.float32)
    for out_i, src_i in enumerate(indices):
        if src_i < len(arr):
            out[out_i] = arr[src_i]
    return out


# ---------------------------------------------------------------------------
# Drawing helpers
# ---------------------------------------------------------------------------


def _px(lm, w: int, h: int) -> tuple[int, int]:
    return int(lm.x * w), int(lm.y * h)


def _valid(x: int, y: int, w: int, h: int) -> bool:
    return 0 <= x < w and 0 <= y < h


def _draw_pose_skeleton(
    frame: np.ndarray,
    lm_list: list,
    indices: list[int],
    connections: list[tuple[int, int]],
    color: tuple[int, int, int],
    radius: int,
    thickness: int,
) -> None:
    """Gambar titik-titik pose subset + garis skeleton sesuai POSE_CONNECTIONS."""
    h, w = frame.shape[:2]

    # Kumpulkan semua posisi pixel yang valid
    pts: dict[int, tuple[int, int]] = {}
    for idx in indices:
        if idx >= len(lm_list):
            continue
        x, y = _px(lm_list[idx], w, h)
        if _valid(x, y, w, h):
            pts[idx] = (x, y)
            cv2.circle(frame, (x, y), radius, color, -1)

    # Gambar koneksi/garis tubuh
    for a, b in connections:
        if a in pts and b in pts:
            cv2.line(frame, pts[a], pts[b], color, thickness)


def _draw_pose_subset(
    frame: np.ndarray,
    lm_list: list,
    indices: list[int],
    color: tuple[int, int, int],
    radius: int,
    thickness: int = 1,
    connections: Optional[list[tuple[int, int]]] = None,
) -> None:
    """Backward-compatible wrapper for drawing pose skeleton."""
    _draw_pose_skeleton(
        frame=frame,
        lm_list=lm_list,
        indices=indices,
        connections=POSE_CONNECTIONS if connections is None else connections,
        color=color,
        radius=radius,
        thickness=thickness,
    )


def _draw_hand_skeleton(
    frame: np.ndarray,
    lm_list: list,
    connections: list[tuple[int, int]],
    color: tuple[int, int, int],
    radius: int,
    thickness: int,
) -> None:
    """Gambar semua titik tangan + garis skeleton sesuai HAND_CONNECTIONS."""
    h, w = frame.shape[:2]

    # Kumpulkan semua posisi pixel yang valid
    pts: dict[int, tuple[int, int]] = {}
    for i, lm in enumerate(lm_list):
        x, y = _px(lm, w, h)
        if _valid(x, y, w, h):
            pts[i] = (x, y)
            cv2.circle(frame, (x, y), radius, color, -1)

    # Gambar koneksi/tulang
    for a, b in connections:
        if a in pts and b in pts:
            cv2.line(frame, pts[a], pts[b], color, thickness)


def _draw_face_skeleton(
    frame: np.ndarray,
    lm_list: list,
    connections: list[tuple[int, int]],
    color: tuple[int, int, int],
    radius: int,
    thickness: int,
) -> None:
    """Gambar titik kontur wajah + garis skeleton sesuai connections."""
    h, w = frame.shape[:2]

    pts: dict[int, tuple[int, int]] = {}
    for i, lm in enumerate(lm_list):
        x, y = _px(lm, w, h)
        if _valid(x, y, w, h):
            pts[i] = (x, y)

    # Gambar koneksi garis kontur
    for a, b in connections:
        if a in pts and b in pts:
            cv2.line(frame, pts[a], pts[b], color, thickness)

    # Gambar titik pada koneksi
    if radius > 0:
        contour_indices = {idx for conn in connections for idx in conn}
        for idx in contour_indices:
            if idx in pts:
                cv2.circle(frame, pts[idx], radius, color, -1)


def _draw_face_subset(
    frame: np.ndarray,
    lm_list: list,
    color: tuple[int, int, int],
    radius: int = 1,
    thickness: int = 1,
    connections: Optional[list[tuple[int, int]]] = None,
) -> None:
    """Wrapper for drawing face skeleton."""
    _draw_face_skeleton(
        frame=frame,
        lm_list=lm_list,
        connections=FACE_CONNECTIONS if connections is None else connections,
        color=color,
        radius=radius,
        thickness=thickness,
    )


# ---------------------------------------------------------------------------
# Main extractor class
# ---------------------------------------------------------------------------


class LandmarkExtractor:
    """
    MediaPipe Tasks extractor (Pose + Hand + Face) — VIDEO mode.

    Pose  → simpan subset POSE_UPPER_IDX (9 titik), gambar dengan POSE_CONNECTIONS
    Hand  → simpan semua 21 titik, gambar dengan HAND_CONNECTIONS
    Face  → simpan semua 478 titik, gambar dengan FACE_CONNECTIONS
    """

    def __init__(self, config: Optional[ExtractorConfig] = None) -> None:
        self.cfg = config or ExtractorConfig()
        self._validate_models()

    def _draw_landmarks(
        self,
        frame: np.ndarray,
        pose_landmarks: Optional[list],
        hand_landmarks: Optional[list],
        face_landmarks: Optional[list] = None,
    ) -> None:
        """Gambar skeleton pose, tangan, dan wajah pada frame yang diberikan."""
        if self.cfg.draw_pose and pose_landmarks:
            _draw_pose_skeleton(
                frame,
                pose_landmarks[0],
                POSE_UPPER_IDX,
                POSE_CONNECTIONS,
                self.cfg.pose_color,
                self.cfg.pose_radius,
                self.cfg.pose_line_thickness,
            )
        if self.cfg.draw_hands and hand_landmarks:
            for lm_list in hand_landmarks:
                _draw_hand_skeleton(
                    frame,
                    lm_list,
                    HAND_CONNECTIONS,
                    self.cfg.hand_color,
                    self.cfg.hand_radius,
                    self.cfg.hand_line_thickness,
                )
        if self.cfg.draw_face and face_landmarks:
            for lm_list in face_landmarks:
                _draw_face_skeleton(
                    frame,
                    lm_list,
                    FACE_CONNECTIONS,
                    self.cfg.face_color,
                    self.cfg.face_radius,
                    self.cfg.face_line_thickness,
                )

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def process_video(
        self,
        video_path: str | Path,
        out_video_path: Optional[str | Path] = None,
        out_npy_path: Optional[str | Path] = None,
        out_blank_video_path: Optional[str | Path] = None,
    ) -> ExtractionResult:
        """
        Proses satu video, kembalikan ExtractionResult.

        Parameters
        ----------
        video_path           : Path video input.
        out_video_path       : Jika diisi, tulis video teranotasi ke sini.
        out_npy_path         : Jika diisi, simpan .npz (pose, hands).
        out_blank_video_path : Jika diisi, tulis video landmark dengan background kosong.
        """
        video_path = Path(video_path)
        logger.info("Processing: %s", video_path)

        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            raise RuntimeError(f"Cannot open video: {video_path}")

        fps = cap.get(cv2.CAP_PROP_FPS) or 25.0
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        writer: Optional[cv2.VideoWriter] = None
        if out_video_path is not None:
            Path(out_video_path).parent.mkdir(parents=True, exist_ok=True)
            fourcc = cv2.VideoWriter.fourcc(*self.cfg.fourcc)
            writer = cv2.VideoWriter(str(out_video_path), fourcc, fps, (width, height))

        writer_blank: Optional[cv2.VideoWriter] = None
        if out_blank_video_path is not None:
            Path(out_blank_video_path).parent.mkdir(parents=True, exist_ok=True)
            fourcc = cv2.VideoWriter.fourcc(*self.cfg.fourcc)
            writer_blank = cv2.VideoWriter(
                str(out_blank_video_path), fourcc, fps, (width, height)
            )

        pose_seq, hand_seq, face_seq = [], [], []
        n_pose_out = len(POSE_UPPER_IDX)

        BaseOpts = mp.tasks.BaseOptions
        RunMode = mp.tasks.vision.RunningMode

        pose_opts = mp.tasks.vision.PoseLandmarkerOptions(
            base_options=BaseOpts(model_asset_path=self.cfg.pose_model_path),
            running_mode=RunMode.VIDEO,
            num_poses=self.cfg.num_poses,
            min_pose_detection_confidence=self.cfg.pose_detection_conf,
            min_pose_presence_confidence=self.cfg.pose_presence_conf,
            min_tracking_confidence=self.cfg.pose_tracking_conf,
        )
        hand_opts = mp.tasks.vision.HandLandmarkerOptions(
            base_options=BaseOpts(model_asset_path=self.cfg.hand_model_path),
            running_mode=RunMode.VIDEO,
            num_hands=self.cfg.num_hands,
            min_hand_detection_confidence=self.cfg.hand_detection_conf,
            min_hand_presence_confidence=self.cfg.hand_presence_conf,
            min_tracking_confidence=self.cfg.hand_tracking_conf,
        )
        face_opts = mp.tasks.vision.FaceLandmarkerOptions(
            base_options=BaseOpts(model_asset_path=self.cfg.face_model_path),
            running_mode=RunMode.VIDEO,
            num_faces=self.cfg.num_faces,
            min_face_detection_confidence=self.cfg.face_detection_conf,
            min_face_presence_confidence=self.cfg.face_presence_conf,
            min_tracking_confidence=self.cfg.face_tracking_conf,
        )

        frame_idx = 0
        try:
            with (
                mp.tasks.vision.PoseLandmarker.create_from_options(
                    pose_opts
                ) as pose_lm,
                mp.tasks.vision.HandLandmarker.create_from_options(
                    hand_opts
                ) as hand_lm,
                mp.tasks.vision.FaceLandmarker.create_from_options(
                    face_opts
                ) as face_lm,
            ):
                while True:
                    ok, bgr = cap.read()
                    if not ok:
                        break

                    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
                    mp_img = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
                    ts_ms = int(frame_idx * 1000.0 / fps)

                    pose_res = pose_lm.detect_for_video(mp_img, ts_ms)
                    hand_res = hand_lm.detect_for_video(mp_img, ts_ms)
                    face_res = face_lm.detect_for_video(mp_img, ts_ms)

                    # ---- Pose → subset upper-body ----
                    if pose_res.pose_landmarks:
                        full = _landmarks_to_array(
                            pose_res.pose_landmarks[0], extra_fields=["visibility"]
                        )
                        pose_arr = _subset(full, POSE_UPPER_IDX)  # [9, 4]
                    else:
                        pose_arr = np.full((n_pose_out, 4), np.nan, dtype=np.float32)
                    pose_seq.append(pose_arr)

                    # ---- Hands → semua 21 titik ----
                    frame_hands = np.full((2, N_HAND, 3), np.nan, dtype=np.float32)
                    if hand_res.hand_landmarks:
                        for hi, lm_list in enumerate(hand_res.hand_landmarks[:2]):
                            ha = _landmarks_to_array(lm_list)
                            n = min(len(ha), N_HAND)
                            frame_hands[hi, :n] = ha[:n]
                    hand_seq.append(frame_hands)

                    # ---- Face → semua N_FACE titik (1 person) ----
                    frame_face = np.full((N_FACE, 3), np.nan, dtype=np.float32)
                    if face_res.face_landmarks:
                        fa = _landmarks_to_array(face_res.face_landmarks[0])
                        n = min(len(fa), N_FACE)
                        frame_face[:n] = fa[:n]
                    face_seq.append(frame_face)

                    # ---- Draw ----
                    if writer is not None:
                        frame_out = (
                            np.full_like(bgr, self.cfg.blank_bg_color)
                            if self.cfg.blank_background
                            else bgr
                        )
                        self._draw_landmarks(
                            frame_out,
                            pose_res.pose_landmarks,
                            hand_res.hand_landmarks,
                            face_res.face_landmarks,
                        )
                        writer.write(frame_out)

                    if writer_blank is not None:
                        if writer is not None and self.cfg.blank_background:
                            writer_blank.write(frame_out)
                        else:
                            frame_blank = np.full_like(bgr, self.cfg.blank_bg_color)
                            self._draw_landmarks(
                                frame_blank,
                                pose_res.pose_landmarks,
                                hand_res.hand_landmarks,
                                face_res.face_landmarks,
                            )
                            writer_blank.write(frame_blank)

                    frame_idx += 1
                    if frame_idx % 100 == 0:
                        logger.debug("  frame %d", frame_idx)

        finally:
            cap.release()
            if writer is not None:
                writer.release()
            if writer_blank is not None:
                writer_blank.release()

        result = ExtractionResult(
            video_path=str(video_path),
            total_frames=frame_idx,
            fps=fps,
            pose=np.stack(pose_seq) if pose_seq else np.empty((0, n_pose_out, 4)),
            hands=np.stack(hand_seq) if hand_seq else np.empty((0, 2, N_HAND, 3)),
            face=np.stack(face_seq) if face_seq else np.empty((0, N_FACE, 3)),
        )

        if out_npy_path is not None:
            self.save_npy(result, out_npy_path)

        logger.info(
            "Done: %s | frames=%d | pose=%s hands=%s face=%s",
            video_path.name,
            frame_idx,
            result.pose.shape,
            result.hands.shape,
            result.face.shape,
        )
        return result

    def process_folder(
        self,
        folder_path: str | Path,
        out_video_dir: Optional[str | Path] = None,
        out_npy_dir: Optional[str | Path] = None,
        out_blank_video_dir: Optional[str | Path] = None,
        recursive: bool = False,
    ) -> dict[str, ExtractionResult]:
        """
        Batch-process semua video dalam folder.

        Returns
        -------
        dict  filename → ExtractionResult
        """
        folder_path = Path(folder_path)
        if not folder_path.is_dir():
            raise NotADirectoryError(f"Not a directory: {folder_path}")

        pattern = "**/*" if recursive else "*"
        videos = sorted(
            p for p in folder_path.glob(pattern) if p.suffix.lower() in VIDEO_EXTENSIONS
        )

        if not videos:
            logger.warning("No video files found in: %s", folder_path)
            return {}

        logger.info("Found %d video(s) in %s", len(videos), folder_path)

        if out_video_dir:
            Path(out_video_dir).mkdir(parents=True, exist_ok=True)
        if out_blank_video_dir:
            Path(out_blank_video_dir).mkdir(parents=True, exist_ok=True)
        if out_npy_dir:
            Path(out_npy_dir).mkdir(parents=True, exist_ok=True)

        results: dict[str, ExtractionResult] = {}
        for idx, vid in enumerate(videos, 1):
            logger.info("[%d/%d] %s", idx, len(videos), vid.name)
            ovp = (
                Path(out_video_dir) / (vid.stem + "_landmarks" + vid.suffix)
                if out_video_dir
                else None
            )
            obvp = (
                Path(out_blank_video_dir) / (vid.stem + "_blank" + vid.suffix)
                if out_blank_video_dir
                else None
            )
            onp = Path(out_npy_dir) / (vid.stem + ".npz") if out_npy_dir else None
            try:
                results[vid.name] = self.process_video(
                    vid,
                    out_video_path=ovp,
                    out_npy_path=onp,
                    out_blank_video_path=obvp,
                )
            except Exception as exc:  # noqa: BLE001
                logger.error("  FAILED %s: %s", vid.name, exc)

        logger.info("Batch complete: %d/%d succeeded", len(results), len(videos))
        return results

    # ------------------------------------------------------------------
    # Save / load
    # ------------------------------------------------------------------

    @staticmethod
    def save_npy(result: ExtractionResult, path: str | Path) -> None:
        """Simpan ExtractionResult ke .npz terkompresi."""
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        np.savez_compressed(
            str(path),
            pose=result.pose,
            hands=result.hands,
            face=result.face,
        )
        logger.info("Saved: %s", path)

    @staticmethod
    def load_npy(path: str | Path) -> dict[str, np.ndarray]:
        """Load .npz → dict dengan key 'pose', 'hands', 'face'."""
        data = np.load(str(path))
        return {k: data[k] for k in ("pose", "hands", "face") if k in data}

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _validate_models(self) -> None:
        missing = [
            str(Path(getattr(self.cfg, attr)))
            for attr in ("pose_model_path", "hand_model_path", "face_model_path")
            if getattr(self.cfg, attr) and not Path(getattr(self.cfg, attr)).exists()
        ]
        if missing:
            raise FileNotFoundError(
                "Model file(s) not found:\n  " + "\n  ".join(missing)
            )
