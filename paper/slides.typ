#import "@preview/touying:0.5.5": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.author,
  config-info(
    title: [Sistem Verifikasi Objektif Gestur BISINDO Varietas Solo],
    subtitle: [Berbasis MediaPipe Holistic dan Arsitektur Conv1D–GRU Teratensi pada Perangkat Edge],
    author: [Dunhill William Putra],
    date: datetime.today(),
    institution: [Seminar Proposal Skripsi — 2026],
  ),
)

#set text(lang: "id", size: 18pt)

#title-slide()

== Agenda Presentasi

#slide(align: horizon)[
  #columns(2)[
    *1. Pendahuluan*
    #list[
      Latar Belakang & Urgensi
    ][
      Research Gap & Posisi Penelitian
    ][
      Rumusan & Batasan Masalah
    ][
      Tujuan & Manfaat Penelitian
    ]

    #colbreak()

    *2. Tinjauan Pustaka*
    #list[
      Karakteristik BISINDO vs SIBI
    ][
      Ekstraksi Fitur MediaPipe Holistic
    ][
      Model RNN, LSTM, & GRU
    ][
      Conv1D, Attention, & TensorFlow Lite
    ]

    #v(0.5em)
    *3. Metode Penelitian*
    #list[
      Alur Penelitian & Dataset
    ][
      Arsitektur Conv1D–BiGRU Teratensi
    ][
      Tuning, K-Fold LOSO, & Deployment
    ][
      Jadwal Pelaksanaan
    ]
  ]
]

// ==========================================
// 1. PENDAHULUAN
// ==========================================

== Latar Belakang & Masalah

#slide(align: horizon)[
  #grid(
    columns: (1.1fr, 0.9fr),
    gutter: 1.5em,
    [
      *Konteks & Komunikasi Tuli:*
      #list[
        BISINDO merupakan bahasa alami primer komunitas Tuli di Indonesia yang sarat variasi regional (termasuk *Solo*).
      ][
        Lembaga pelatihan & sertifikasi JBI membutuhkan standar verifikasi gestur yang baku dan objektif.
      ]

      #v(0.3em)
      *Tantangan Verifikasi Saat Ini:*
      #list[
        Verifikasi manual oleh penguji bersifat *subjektif*, lambat, dan sulit diskalakan.
      ]
    ],
    [
      *Keterbatasan SLR Eksisting:*
      #list[
        Pendekatan *raw visual* (CNN / YOLO) berbobot komputasi tinggi dan boros daya di perangkat mobile.
      ][
        Belum optimal memodelkan dinamika temporal sekuens gestur bergerak.
      ]

      #v(0.3em)
      *Solusi yang Diusulkan:*
      Ekstraksi koordinat *MediaPipe Holistic* + *Conv1D–BiGRU teratensi* yang dioptimasi via *TensorFlow Lite* di Android.
    ]
  )
]

== Research Gap & Posisi Penelitian

#slide(align: center + horizon)[
  #set text(size: 14pt)
  #table(
    columns: (1.3fr, 2.5fr, 2.7fr),
    stroke: 0.5pt,
    inset: 0.6em,
    align: (left, left, left),
    table.header([*Aspek*], [*State-of-the-Art / Keterbatasan*], [*Posisi Penelitian Ini*]),
    [*Dataset*],
    [Alfabet statis BISINDO atau varietas Jakarta; belum ada korpus khusus regional Solo.],
    [*Membangun dataset 20 kelas BISINDO Solo* terstandarisasi (500 video, 5 signer, 5 repetisi).],

    [*Representasi Gestur*],
    [Dominan citra statis atau video mentah beresolusi tinggi dengan beban komputasi berat.],
    [*Gestur dinamis berbasis 51 titik landmark* (MediaPipe Holistic) yang ringan & invarian lingkungan.],

    [*Arsitektur Model*],
    [Model sekuensial dasar (LSTM/GRU tunggal) atau ViT dengan latensi tinggi.],
    [*Hibrida Conv1D + BiGRU + Temporal Attention* untuk menangkap fitur lokal & sekuensial kritis.],

    [*Target & Konteks*],
    [Penerjemah umum di peladen/PC atau aplikasi IoT dengan kosakata sangat terbatas.],
    [*Sistem verifikasi objektif pada perangkat edge (Android)* untuk pelatihan/sertifikasi JBI.]
  )
]

== Rumusan Masalah

#slide(align: horizon)[
  #enum[
    *Bagaimana merancang dan membangun* dataset BISINDO Solo yang terstandarisasi untuk 20 kelas gestur dasar berbasis rekaman video multi-peraga?
  ][
    *Bagaimana kinerja model sekuensial GRU* berbasis fitur landmark MediaPipe Holistic dalam mengenali gestur terisolasi BISINDO Solo?
  ][
    *Seberapa efektif proses optimasi model* (kuantisasi TFLite) dalam mempertahankan akurasi pengujian sambil menekan latensi _inference_ di bawah 100 ms pada perangkat Android?
  ]
]

== Batasan Masalah

#slide(align: horizon)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *1. Cakupan Gestur*
      #list[
        20 kelas gestur dasar terisolasi (tingkat kata/frasa, bukan kalimat utuh).
      ][
        Mengacu pada materi dasar *level 1 PUSBISINDO*.
      ]

      #v(0.5em)
      *2. Ekstraksi Fitur*
      #list[
        MediaPipe Holistic API: 21 titik tiap tangan (kiri & kanan) + 9 titik pose atas tubuh.
      ]
    ],
    [
      *3. Komposisi Dataset*
      #list[
        Total 500 rekaman video: 20 kelas × 5 peraga (signer) × 5 repetisi.
      ][
        Resolusi 480p, diseragamkan ke 30 fps.
      ]

      #v(0.5em)
      *4. Target Deployment*
      #list[
        Perangkat bergerak smartphone *Android*.
      ][
        Eksekusi on-device via *TensorFlow Lite Interpreter*.
      ]
    ]
  )
]

== Tujuan & Manfaat Penelitian

#slide(align: horizon)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      *Tujuan Penelitian*
      #list[
        *Membangun dataset* BISINDO Solo terstandarisasi sebagai kontribusi sumber terbuka (_open-source_).
      ][
        *Melatih & menganalisis* arsitektur model GRU hibrida (Conv1D + Attention) untuk klasifikasi gestur sekuensial.
      ][
        *Menerapkan & menguji* model terkompresi (TFLite) pada smartphone Android secara _real-time_.
      ]
    ],
    [
      *Manfaat Penelitian*
      #list[
        *Akademis:* Memperluas literatur SLR ke ranah varietas regional BISINDO Solo.
      ][
        *Empiris:* Memberikan bukti empiris efektivitas kombinasi MediaPipe dan GRU pada dataset terbatas.
      ][
        *Praktis:* Menjadi dasar pengembangan alat bantu verifikasi objektif pada sertifikasi dan pelatihan JBI.
      ]
    ]
  )
]

// ==========================================
// 2. TINJAUAN PUSTAKA
// ==========================================

== Karakteristik SIBI vs BISINDO

#slide(align: center + horizon)[
  #set text(size: 15pt)
  #table(
    columns: (1fr, 1.8fr, 2.2fr),
    stroke: 0.5pt,
    inset: 0.7em,
    align: (left, left, left),
    table.header([*Aspek*], [*SIBI*], [*BISINDO (Fokus Penelitian)*]),
    [*Asal Usul*], [Sistem buatan pemerintah], [Bahasa alami komunitas Tuli Indonesia],
    [*Tata Bahasa*], [Mengikuti tata bahasa Indonesia lisan (berimbuhan)], [Memiliki tata bahasa visual-spasial tersendiri],
    [*Formalitas*], [Formal (lingkungan pendidikan SLB/resmi)], [Informal & percakapan sehari-hari],
    [*Variasi*], [Terstandarisasi secara nasional], [*Bervariasi antar daerah (mis. varietas Solo)*],
    [*Penggunaan*], [Sekolah / institusi formal], [Bahasa ibu & komunikasi primer komunitas Tuli]
  )
  #v(0.5em)
  #text(size: 13pt)[Sumber: Tabel 2.1 pada naskah proposal]
]

== Ekstraksi Fitur: MediaPipe Holistic

#slide(align: center + horizon)[
  #image("pipeline.pdf", height: 36%)
  #v(0.4em)
  #grid(
    columns: (1.1fr, 1fr),
    gutter: 1.2em,
    align: left,
    [
      #set text(size: 14pt)
      *Representasi 51 Keypoint (153 Fitur 3D):*
      #list[
        *Tangan Kiri & Kanan:* 21 + 21 landmark koordinat $(x, y, z)$.
      ][
        *Pose Tubuh Atas:* 9 landmark torso & bahu.
      ]
    ],
    [
      #set text(size: 14pt)
      *Keunggulan untuk Edge Deployment:*
      #list[
        Abaikan informasi piksel mentah $arrow.r$ reduksi komputasi.
      ][
        Invarian terhadap latar belakang dan variasi busana.
      ]
    ]
  )
]

== Model Sekuensial: RNN, LSTM, & GRU

#slide(align: center + horizon)[
  #set text(size: 15pt)
  #table(
    columns: (1.3fr, 1fr, 1.3fr, 1.3fr),
    stroke: 0.5pt,
    inset: 0.6em,
    align: center,
    table.header([*Karakteristik*], [*RNN*], [*LSTM*], [*GRU (Dipilih)*]),
    [Mekanisme Gate], [0 (tanpa gate)], [3 (Input, Forget, Output)], [*2 (Reset & Update)*],
    [Cell State Terpisah], [Tidak], [Ya], [*Tidak (digabung di $h_t$)*],
    [Jumlah Parameter], [Paling sedikit], [Paling banyak], [*Sedang / Efisien*],
    [Vanishing Gradient], [Tinggi], [Rendah], [*Rendah*],
    [Beban Komputasi], [Rendah], [Tinggi], [*Sedang (cocok untuk edge)*]
  )

  #v(0.5em)
  #align(left)[
    #text(size: 14pt)[
      *Formulasi GRU:*
      $r_t = sigma(W_r [h_(t-1), x_t])$, quad
      $z_t = sigma(W_z [h_(t-1), x_t])$, quad
      $h_t = (1 - z_t) * h_(t-1) + z_t * tilde(h)_t$ \
      $arrow.r$ GRU menyeimbangkan kapasitas representasi dependensi temporal dengan efisiensi memori & latensi.
    ]
  ]
]

== Conv1D, Attention, & Optimasi TFLite

#slide(align: horizon)[
  #grid(
    columns: (1.2fr, 1fr),
    gutter: 1.2em,
    [
      *Conv1D (Fitur Lokal Spasial-Temporal):*
      #list[
        Mengekstrak pola perubahan lokal koordinat antar-frame berturut-turut sebelum masuk ke modul sekuensial.
      ]

      *Temporal Attention Mechanism:*
      #list[
        Membobot frame ($alpha_t$) secara dinamis:
        $c = sum_(t=1)^T alpha_t h_t$
      ][
        Fokus pada momen kritis (puncak formasi tangan).
      ]
    ],
    [
      *TensorFlow Lite (TFLite):*
      #image("convert.pdf", width: 95%)
      #text(size: 13pt)[
        Konversi model ke format FlatBuffer dan kuantisasi untuk eksekusi berlatensi rendah pada runtime ARM Android.
      ]
    ]
  )
]

// ==========================================
// 3. METODE PENELITIAN
// ==========================================

== Alur Penelitian (Computer Vision Life-Cycle)

#slide(align: center + horizon)[
  #image("step.pdf", height: 50%)
  #v(0.4em)
  #set text(size: 13pt)
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    gutter: 0.6em,
    [1. Akuisisi 500 video dari 5 peraga],
    [2. Augmentasi & landmark MediaPipe],
    [3. Latih Conv1D + BiGRU + Attention],
    [4. Evaluasi K-Fold LOSO & Kuantisasi],
    [5. Deployment & Uji Real-Time Android],
  )
]

== Dataset & Prapemrosesan

#slide(align: horizon)[
  #grid(
    columns: (1.1fr, 1fr),
    gutter: 1.5em,
    [
      *Komposisi Dataset BISINDO Solo:*
      #set text(size: 15pt)
      #table(
        columns: (auto, auto),
        stroke: 0.5pt,
        inset: 0.5em,
        align: (left, left),
        [Jumlah Kelas Gestur], [20 frasa dasar (PUSBISINDO level 1)],
        [Jumlah Signer], [5 peraga (masing-masing 5 repetisi)],
        [Total Video Mentah], [500 video ($20 times 5 times 5$)],
        [Spesifikasi Video], [Resolusi 480p, frame rate 30 fps]
      )
    ],
    [
      *Tahap Prapemrosesan:*
      #list[
        *Augmentasi Data:*
        Horizontal shift, horizontal flip, serta variasi kecepatan (slow & fast motion).
      ][
        *Ekstraksi Landmark:*
        51 titik (153 nilai float) diekstraksi per frame via MediaPipe Holistic.
      ][
        *Normalisasi Spasial:*
        Koordinat dinormalisasi terhadap titik referensi bahu/torso agar invarian posisi kamera.
      ]
    ]
  )
]

== Arsitektur Model yang Diusulkan

#slide(align: center + horizon)[
  #image("proposed.pdf", height: 50%)
  #v(0.4em)
  #text(size: 13pt)[
    *Alur Model:* Input (153 fitur) $arrow.r$ Spatial Dropout $arrow.r$ 2 Blok Conv1D $arrow.r$ BiGRU $arrow.r$ Temporal Attention $arrow.r$ Dense(128) $arrow.r$ Softmax (20 Kelas)
  ]
]

== Ruang Eksplorasi Hyperparameter Tuning

#slide(align: center + horizon)[
  #set text(size: 14pt)
  #table(
    columns: (1.5fr, 2fr, 1.5fr, 2fr),
    stroke: 0.5pt,
    inset: 0.6em,
    align: (left, center, left, center),
    table.header([*Hyperparameter*], [*Nilai yang Diuji*], [*Hyperparameter*], [*Nilai yang Diuji*]),
    [Unit GRU], [128, 192, 256], [Blok Conv1D], [1, 2],
    [Kernel Conv1D], [3, 5, 7], [Spatial Dropout], [0.1, 0.3, 0.5],
    [Rate Dropout], [0.2, 0.3, 0.5], [Learning Rate], [$10^(-3)$, $10^(-4)$, $10^(-5)$],
    [Batch Size], [32, 64, 128], [Maksimum Epoch], [60, 100, 150],
    [Early Stopping Patience], [10, 15, 20], [Optimizer], [Adam, RMSprop, SGD]
  )
  #v(0.3em)
  #align(left)[
    #text(size: 13pt)[
      Konfigurasi dasar pelatihan mengacu pada batch size 64, maksimum 100 epoch, serta early stopping dengan patience 15 epoch berdasarkan validation loss untuk mencegah overfitting.
    ]
  ]
]

== Skema Validasi: Leave-One-Signer-Out K-Fold

#slide(align: center + horizon)[
  #text(size: 15pt)[
    *Skema 5-Fold Cross-Validation Berdasarkan Signer (LOSO):*
  ]
  #v(0.3em)
  #set text(size: 14pt)
  #table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    stroke: 0.5pt,
    inset: 0.6em,
    align: center,
    table.header([*Fold*], [*Signer 1*], [*Signer 2*], [*Signer 3*], [*Signer 4*], [*Signer 5*]),
    [Fold 1], table.cell(fill: rgb("#cbe1bd"))[*Uji*], [Latih/Val], [Latih/Val], [Latih/Val], [Latih/Val],
    [Fold 2], [Latih/Val], table.cell(fill: rgb("#cbe1bd"))[*Uji*], [Latih/Val], [Latih/Val], [Latih/Val],
    [Fold 3], [Latih/Val], [Latih/Val], table.cell(fill: rgb("#cbe1bd"))[*Uji*], [Latih/Val], [Latih/Val],
    [Fold 4], [Latih/Val], [Latih/Val], [Latih/Val], table.cell(fill: rgb("#cbe1bd"))[*Uji*], [Latih/Val],
    [Fold 5], [Latih/Val], [Latih/Val], [Latih/Val], [Latih/Val], table.cell(fill: rgb("#cbe1bd"))[*Uji*]
  )
  #v(0.4em)
  #align(left)[
    #text(size: 14pt)[
      *Karakteristik & Urgensi Skema LOSO:*
      #list[
        Pada setiap fold, 1 signer dialokasikan khusus sebagai data uji; 4 signer lainnya dibagi menjadi subset latih dan validasi (80:20).
      ][
        Menilai secara objektif *kemampuan generalisasi model terhadap pengguna baru* yang belum pernah dilihat saat pelatihan, merefleksikan kondisi nyata pengujian sertifikasi JBI.
      ]
    ]
  ]
]

== Evaluasi Model & Kriteria Keberhasilan

#slide(align: horizon)[
  #grid(
    columns: (1.1fr, 1fr),
    gutter: 1.5em,
    [
      *Metrik Evaluasi:*
      #list[
        *Metrik Klasifikasi:*
        Accuracy, Precision, Recall, dan F1-Score (makro serta per-kelas).
      ][
        *Analisis Kesalahan:*
        Confusion Matrix per-kelas untuk memetakan gestur dengan ambiguitas tinggi.
      ][
        *Metrik Deployment:*
        Ukuran berkas biner (.tflite) dan latensi inferensi on-device (ms).
      ]
    ],
    [
      *Kriteria Keberhasilan Target:*
      #v(0.3em)
      #block(
        fill: rgb("#f4f9f4"),
        stroke: 1pt + rgb("#a3d9a5"),
        inset: 0.8em,
        radius: 4pt,
        [
          *1. Akurasi K-Fold LOSO*
          $gt.eq$ *80%* (kemampuan generalisasi antar signer)

          #v(0.3em)
          *2. Ukuran Model TFLite*
          $lt.eq$ *10 MB* (ringan & efisien memori)

          #v(0.3em)
          *3. Latensi Inferensi Android*
          $<$ *100 ms* (real-time feedback)
        ]
      )
    ]
  )
]

== Implementasi & Pipeline Android

#slide(align: center + horizon)[
  #image("android.pdf", height: 36%)
  #v(0.4em)
  #align(left)[
    #set text(size: 13pt)
    *Alur Eksekusi Real-Time di Smartphone Android:*
    1. Kamera menangkap frame video gestur secara kontinu (480p, 30 fps).
    2. MediaPipe Holistic mengekstrak 51 koordinat landmark pada CPU/GPU mobile.
    3. Pembentukan vektor sekuens & normalisasi (nilai padding NaN dikonversi ke nol).
    4. TFLite Interpreter menjalankan model Conv1D–BiGRU–Attention secara lokal (tanpa server).
    5. Antarmuka UI menampilkan hasil verifikasi dan tingkat keyakinan (confidence score).
  ]
]

== Jadwal Pelaksanaan Penelitian

#slide(align: center + horizon)[
  #set text(size: 13pt)
  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    inset: 0.5em,
    align: (left, center, center, center, center, center, center, center, center, center),
    table.header(
      [*Tahap Kegiatan (Sep 2026 – Mei 2027)*],
      [*Sep*], [*Okt*], [*Nov*], [*Des*], [*Jan*], [*Feb*], [*Mar*], [*Apr*], [*Mei*]
    ),
    [1. Studi literatur & identifikasi masalah],
    table.cell(fill: rgb("#cbe1bd"))[✓], [], [], [], [], [], [], [], [],
    [2. Penyusunan dan seminar proposal],
    [], table.cell(fill: rgb("#cbe1bd"))[✓], [], [], [], [], [], [], [],
    [3. Pembangunan dataset (500 video)],
    [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], [], [], [], [], [],
    [4. Prapemrosesan & ekstraksi MediaPipe],
    [], [], [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], [], [], [], [],
    [5. Pelatihan dan evaluasi model GRU],
    [], [], [], [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], [], [],
    [6. Konversi TFLite & implementasi Android],
    [], [], [], [], [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], [], [],
    [7. Pengujian real-time Android & analisis],
    [], [], [], [], [], [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓], [],
    [8. Penyusunan laporan akhir dan sidang],
    [], [], [], [], [], [], [], table.cell(fill: rgb("#cbe1bd"))[✓], table.cell(fill: rgb("#cbe1bd"))[✓]
  )
]

== Penutup

#slide(align: center + horizon)[
  #text(size: 26pt, weight: "bold")[Terima Kasih]

  #v(1em)
  #text(size: 18pt)[Sistem Verifikasi Objektif Gestur BISINDO Varietas Solo] \
  #text(size: 15pt, fill: luma(90))[Berbasis MediaPipe Holistic dan Arsitektur Conv1D–GRU Teratensi pada Perangkat Edge]

  #v(1em)
  #text(size: 16pt)[Dunhill William Putra] \
  #text(size: 14pt, fill: luma(100))[Sesi Tanya Jawab & Diskusi]
]
