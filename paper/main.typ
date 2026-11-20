/*
 * The Rubber Article Template.
 *
 * Here is a quick run-down of the template.
 * Some example content has been added for you to see what the template looks like and how it works.
 * Some features of this template are explained here, so you might want to check it out.
 */

#import "@preview/rubber-article:0.5.2": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Layout and styling
#show: article.with(
  cols: none, // Tip: use #colbreak() instead of #pagebreak() to seamlessly toggle columns
  eq-chapterwise: true,
  eq-numbering: "(1.1)",
  header-display: false,
  header-title: "The Title of the Paper",
  lang: "id",
  page-margins: 3cm,
  page-paper: "a4",
  text-size: 11pt,
  text-font: "Noto Sans",
)

#set par(leading: 0.75em)
#set par(spacing: 1em)

// Frontmatter
#maketitle(
  title: "Pengenalan Gestur Dinamis BISINDO Varietas Solo Berbasis MediaPipe Holistic dan Arsitektur Conv1D–BiGRU Teratensi pada Perangkat Mobile Edge",
  authors: ("Dunhill William Putra",),
  date: datetime.today().display("[day] [month repr:long] [year]"),
)

= Pendahuluan
== Latar Belakang
Akses terhadap komunikasi yang setara merupakan hak asasi dan prasyarat fundamental bagi partisipasi penuh komunitas Tuli dalam kehidupan sosial, pendidikan, serta dunia kerja @betri2026, @sutjiadi2023. Di Indonesia, komunitas Tuli secara alami mengadopsi Bahasa Isyarat Indonesia (BISINDO) sebagai bahasa ibu berbasis visual-spasial yang mengintegrasikan formasi gerakan tangan, orientasi telapak, posisi tubuh, dan ekspresi wajah @mahaputra2026, @rimbawa2025. Kendati Sistem Isyarat Bahasa Indonesia (SIBI) diajarkan secara formal di Sekolah Luar Biasa (SLB), struktur gramatikal SIBI yang mengadopsi tata bahasa lisan dinilai kaku dan tidak alamiah, sehingga mayoritas penyandang Tuli lebih nyaman berkomunikasi menggunakan BISINDO dalam interaksi keseharian @ahwani2024. Namun, rendahnya pemahaman masyarakat mendengar terhadap BISINDO dan keterbatasan media komunikasi mandiri memicu kesenjangan komunikasi yang nyata di ruang publik @sutjiadi2023.

Di sisi lain, kemajuan _Computer Vision_ (CV) dan _Deep Learning_ (DL) telah membuka peluang otomatisasi _Sign Language Recognition_ (SLR) sebagai jembatan komunikasi digital @rimbawa2025. Akan tetapi, sebagian besar penelitian SLR di Indonesia menghadapi dilema komputasi yang tajam antara akurasi model dan kepraktisan implementasi di dunia nyata. Di satu sisi, model-model mutakhir berbasis visual mentah (_raw pixel_) seperti CNN 2D/3D @sulistianingsih2025 atau detektor objek YOLO @swasono2025 memang mampu mengenali gestur, namun membutuhkan konsumsi komputasi dan memori yang sangat masif, serta rentan terdegradasi oleh variasi pencahayaan ruangan dan latar belakang yang kompleks @pramasaa2025. Pendekatan penerjemah kalimat kontinu berbasis peladen (_server-based_) @putra2025 juga menuntut infrastruktur komputasi kelas atas (_workstation_) yang tidak realistis untuk dibawa ke ranah penggunaan personal sehari-hari.

Agar teknologi SLR dapat diakses secara inklusif oleh masyarakat luas, sistem pengenalan bahasa isyarat idealnya dapat dioperasikan langsung pada perangkat bergerak (_mobile edge_) seperti _smartphone_ Android @sutjiadi2023, @pramasaa2025. Implementasi inferensi _on-device_ mandiri tanpa ketergantungan peladen awan (_cloud_) memiliki urgensi vital: (1) menjamin privasi data visual pengguna karena video tidak dikirimkan ke jaringan eksternal, (2) mengeliminasi latensi transmisi jaringan nirkabel yang kerap berfluktuasi hingga beberapa detik @mahaputra2026, dan (3) memastikan aplikasi tetap dapat berfungsi di lingkungan dengan keterbatasan konektivitas internet. Namun, menjalankan inferensi model pembelajaran mendalam pada prosesor bergerak (ARM) yang memiliki keterbatasan daya komputasi dan memori menghadirkan tantangan teknis yang berat, khususnya dalam mempertahankan latensi inferensi di bawah 100 ms agar interaksi terasa waktu-nyata (_real-time_) @darmayunata2026.

Untuk mengatasi beban komputasi visual mentah, ekstraksi titik koordinat rangka (_skeleton landmark_) berbasis MediaPipe Holistic @ahwani2024, @wisudawati2026 menawarkan solusi reduksi dimensionalitas yang sangat signifikan. MediaPipe mengekstrak koordinat geometris 3D sendi tangan dan pose tubuh atas secara efisien, membuang redundansi informasi piksel warna dan tekstur latar belakang, sehingga menghasilkan aliran fitur sekuensial yang ringan dan invarian terhadap variasi pencahayaan @lemmuela2025, @sutjiadi2023. Kendati demikian, mengenali gestur dinamis berbasis sekuens koordinat kerangka pada perangkat bergerak tetap memerlukan arsitektur sekuensial yang cermat. Model rekuren tunggal (LSTM atau GRU) @maheswara2024, @mahaputra2026 kerap mengalami lonjakan latensi saat memproses sekuens video panjang secara langsung, sedangkan arsitektur berbasis graf (GCN) atau Transformer memiliki jejak parameter yang terlalu berat untuk komputasi _edge_ @darmayunata2026, @sebastian2025.

Selain tantangan efisiensi komputasi _edge_, terdapat kesenjangan linguistik yang fundamental dalam literatur SLR di Indonesia. BISINDO merupakan bahasa alami yang bersifat polilektal dengan variasi leksikon dan artikulasi regional yang nyata antardaerah. Salah satu varietas yang aktif digunakan di Jawa Tengah adalah BISINDO varietas Solo (Surakarta). Sayangnya, penelitian SLR di Indonesia saat ini mengalami bias sentralisasi yang tajam: mayoritas penelitian hanya berfokus pada alfabet statis nasional atau dataset publik varietas Jakarta @sutjiadi2023. Belum tersedia korpus komputasional terstandarisasi yang mendokumentasikan BISINDO varietas regional Solo. Memaksakan model yang dilatih pada varietas lain atau representasi alfabet statis tidak hanya memicu penurunan akurasi akibat pergeseran domain (_domain shift_), tetapi juga mengabaikan karakteristik unik komunikasi komunitas Tuli lokal.

Menjawab tantangan tersebut, penelitian ini berfokus pada _benchmarking_ dan evaluasi komprehensif implementasi model pengenalan gestur dinamis BISINDO varietas Solo pada perangkat _mobile edge_ Android. Penelitian ini mengusulkan arsitektur hibrida ringan yang mengombinasikan dua lapisan Conv1D, Bidirectional GRU (BiGRU), dan mekanisme _Temporal Attention_. Dua lapisan Conv1D bertingkat dirancang untuk mengekstrak korelasi spasial-temporal lokal antar-sendi sekaligus mereduksi panjang sekuens waktu melalui _pooling_ bertingkat, sehingga memangkas beban komputasi rekuren BiGRU hingga 75%. Lapisan _Temporal Attention_ ditempatkan pasca-BiGRU untuk memfokuskan pembobotan pada frame puncak gestur (_apex frames_) yang paling diskriminatif @sebastian2025, @darmayunata2026. Selanjutnya, model dioptimasi dan dikuantisasi melalui format TensorFlow Lite (TFLite) untuk menguji _trade-off_ antara retensi akurasi, ukuran model, dan latensi inferensi di bawah 100 ms pada perangkat Android. Melalui pengujian validasi silang lintas-peraga (_cross-signer evaluation_), penelitian ini diharapkan memberikan bukti empiris mengenai batas kelayakan teknis pengenalan gestur dinamis berbasis _landmark_ pada perangkat bergerak.

== Rumusan Masalah

+ Bagaimana merancang dan membangun dataset BISINDO Solo yang terstandarisasi untuk 20 kelas gestur dinamis dasar berbasis rekaman video multi-peraga?

+ Bagaimana kinerja arsitektur hibrida Conv1D–BiGRU teratensi temporal berbasis fitur _landmark_ MediaPipe Holistic dalam mengenali gestur dinamis BISINDO Solo pada skenario pengujian lintas-peraga (_cross-signer generalization_)?

+ Seberapa efektif teknik optimasi dan kuantisasi TensorFlow Lite (TFLite) dalam mempertahankan akurasi model sambil menekan ukuran berkas dan latensi inferensi di bawah 100 ms pada perangkat bergerak Android?

== Batasan Masalah

+ Cakupan Gestur: Berfokus pada 20 kelas gestur kata dinamis terisolasi dalam BISINDO varietas Solo (mengacu pada materi dasar level 1 PUSBISINDO).

+ Ekstraksi Fitur: Menggunakan MediaPipe Holistic API untuk mengekstrak 51 titik koordinat 3D (21 titik tiap tangan kiri dan kanan, serta 9 titik pose tubuh bagian atas).

+ Dataset: Terdiri dari 500 rekaman video yang dikumpulkan dari 5 peraga (signer) dengan 5 repetisi per kelas gestur.

+ Skema Evaluasi: Evaluasi offline berbasis _Leave-One-Signer-Out_ (LOSO) _cross-validation_ untuk menguji generalisasi model terhadap penanda baru yang belum pernah dilihat saat pelatihan.

+ Target Deployment: Implementasi inferensi _on-device_ pada smartphone Android menggunakan TensorFlow Lite Interpreter.

== Tujuan Penelitian

+ Membangun dataset BISINDO Solo terstandarisasi untuk 20 kelas gestur dinamis sebagai kontribusi sumber terbuka (_open-source dataset_) bagi penelitian SLR berbasis varietas regional.

+ Merancang, melatih, dan menganalisis performa arsitektur hibrida Conv1D–BiGRU teratensi temporal dalam mengklasifikasikan sekuens gestur dinamis BISINDO Solo secara lintas-peraga.

+ Mengevaluasi pengaruh konversi dan kuantisasi model TensorFlow Lite terhadap _trade-off_ antara akurasi pengujian, ukuran model, dan latensi inferensi pada perangkat Android guna membuktikan kelayakan inferensi _real-time_ di lingkungan _mobile edge_.

== Manfaat Penelitian

+ *Manfaat Teoretis dan Akademis*: Memperluas literatur komputasi SLR ke ranah varietas regional BISINDO Solo yang selama ini belum terpetakan, serta memberikan bukti empiris mengenai keunggulan arsitektur hibrida Conv1D–BiGRU–Attention dalam memodelkan fitur skeleton berdimensi ringkas pada skenario lintas-peraga.

+ *Manfaat Praktis dan Teknologis*: Menghasilkan model pembelajaran mendalam yang teroptimasi dan siap dioperasikan langsung pada perangkat bergerak Android dengan latensi sub-100 ms, membuktikan kelayakan teknis inferensi _on-device_ tanpa ketergantungan infrastruktur peladen awan.

+ *Manfaat Sosial*: Meletakkan fondasi teknologi asisten bahasa isyarat bergerak yang privat, portabel, dan terjangkau bagi komunitas Tuli maupun masyarakat umum, guna memfasilitasi komunikasi inklusif di tingkat lokal.

= Tinjauan Pustaka
// == Landasan Teori
== Komunikasi, Disabilitas Dengar, dan Bahasa Isyarat
Komunikasi merupakan prasyarat fundamental bagi setiap individu untuk berpartisipasi secara penuh dalam kehidupan sosial, pendidikan, serta dunia kerja @betri2026. Bagi komunitas Tuli dan individu dengan disabilitas dengar, komunikasi verbal-lisan berbasis suara menjadi hambatan utama dalam berinteraksi dengan masyarakat mendengar @rimbawa2025. Kesenjangan komunikasi ini berpotensi memicu isolasi sosial, keterbatasan akses terhadap pendidikan inklusif, serta minimnya peluang kerja bagi komunitas Tuli @sutjiadi2023.

Sebagai solusi atas hambatan tersebut, bahasa isyarat hadir sebagai sistem komunikasi alami berbasis visual-spasial yang memanfaatkan kombinasi gerakan tangan, posisi jari, ekspresi wajah, serta orientasi pose tubuh @rimbawa2025. Di Indonesia, terdapat dua sistem isyarat utama yang dikenal luas, yaitu Sistem Isyarat Bahasa Indonesia (SIBI) dan Bahasa Isyarat Indonesia (BISINDO) @ahwani2024. Pembahasan mengenai karakteristik kedua sistem ini dirangkum pada @tbl-sibi-bisindo.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 1em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([Aspek], [SIBI], [BISINDO]),
    [Asal], [Buatan pemerintah], [Alami dari komunitas Tuli],
    [Struktur], [Mengikuti tata \ bahasa Indonesia], [Struktur sendiri, tidak \ terikat Bahasa Indonesia],

    [Formalitas], [Formal (pendidikan, resmi)], [Informal (sehari-hari)],

    [Variasi], [Terstandarisasi nasional], [Bervariasi antar daerah],
    [Penggunaan], [Sekolah/Institusi], [Komunikasi sehari-hari],
  ),
  caption: "Perbandingan SIBI dan BISINDO",
) <tbl-sibi-bisindo>

== Pose Estimation dan MediaPipe Holistic
Salah satu pendekatan yang banyak digunakan untuk mengatasi kompleksitas DSL adalah pose estimation yang mengekstrak landmark kunci dari tubuh, tangan, dan wajah sebagai representasi fitur yang lebih ringkas namun informatif @samaan2022, @maheswara2024. MediaPipe Holistic merupakan framework yang menyediakan deteksi dan tracking landmark multi‑bagian (tangan, pose, dan wajah) secara real‑time dari video, sehingga cocok digunakan sebagai front‑end ekstraksi fitur untuk tugas pengenalan bahasa isyarat @ahwani2024, @wisudawati2026.

#figure(
  image("mediapipe.pdf", width: 60%),
  caption: "Mediapipe Landmark",
) <fig-mediapipe>

Alur ekstraksi fitur menggunakan MediaPipe Holistic ditunjukkan pada @pipeline-mediapipe.

#figure(
  image("pipeline.pdf", width: 100%),
  caption: "Pipeline ekstraksi landmark MediaPipe Holistic",
) <pipeline-mediapipe>

Dengan menggunakan koordinat landmark sebagai input, sistem dapat mengabaikan sebagian besar informasi raw piksel dan fokus pada struktur gerakan, sehingga mengurangi beban komputasi dan membuat deployment di perangkat edge seperti smartphone menjadi lebih feasible @lemmuela2025, @sutjiadi2023. Pendekatan ini juga membantu mengatasi tantangan yang muncul pada background kompleks dan variasi pencahayaan, karena model bekerja pada representasi skeleton/landmark, bukan langsung pada citra berwarna @wisudawati2026.

== Recurrent Neural Network (RNN), Gated Recurrent Unit (GRU), dan Long Short-Term Memory (LSTM)
Dynamic sign language recognition secara alamiah membutuhkan model yang mampu memproses data sekuensial, sehingga Recurrent Neural Network (RNN) dan turunannya seperti Long Short‑Term Memory (LSTM) dan Gated Recurrent Unit (GRU) banyak digunakan @samaan2022, @myagila2025. RNN memanfaatkan hidden state yang dipropagasikan sepanjang urutan waktu untuk menangkap ketergantungan temporal, sedangkan LSTM dan GRU menambahkan mekanisme gate untuk mengatasi masalah vanishing gradient dan mempelajari dependensi jangka panjang secara lebih stabil.

Ketiga arsitektur tersebut diformulasikan sebagai berikut:

#figure(
  image("rnn.pdf", height: 7em),
  caption: "Arsitektur RNN",
) <fig-rnn>

RNN merupakan bentuk paling sederhana:

$ h_t = tanh(W_h h_(t-1) + W_x x_t + b) $

#figure(
  image("lstm.pdf", height: 8em),
  caption: "Arsitektur LSTM",
) <fig-lstm>

Sementara itu, LSTM menambahkan tiga mekanisme gate dan cell state:

$ i_t = sigma(W_i [h_(t-1), x_t] + b_i) $
$ f_t = sigma(W_f [h_(t-1), x_t] + b_f) $
$ o_t = sigma(W_o [h_(t-1), x_t] + b_o) $
$ tilde(C)_t = tanh(W_C [h_(t-1), x_t] + b_C) $
$ C_t = f_t * C_(t-1) + i_t * tilde(C)_t $
$ h_t = o_t * tanh(C_t) $

dengan $i_t$, $f_t$, $o_t$ masing-masing adalah input gate, forget gate, dan output gate, serta $C_t$ adalah cell state yang menyimpan memori jangka panjang.

#figure(
  image("gru.pdf", height: 7em),
  caption: "Arsitektur GRU",
) <fig-gru>

GRU menyederhanakan arsitektur LSTM dengan dua gate saja:

$ r_t = sigma(W_r [h_(t-1), x_t]) $
$ z_t = sigma(W_z [h_(t-1), x_t]) $
$ tilde(h)_t = tanh(W [r_t * h_(t-1), x_t]) $
$ h_t = (1 - z_t) * h_(t-1) + z_t * tilde(h)_t $

dengan $r_t$ adalah reset gate yang mengontrol seberapa banyak informasi lampau yang dilupakan, $z_t$ adalah update gate yang menentukan seberapa banyak informasi baru yang ditambahkan, dan $h_t$ adalah hidden state pada waktu $t$.

Dalam konteks HAR dan sign language recognition, model seperti GRU dan LSTM terbukti efektif dalam mengklasifikasikan sekuens landmark atau fitur citra menjadi label aktivitas atau kata tertentu @maheswara2024, @myagila2025. Beberapa penelitian menunjukkan bahwa kombinasi MediaPipe Holistic dengan GRU/LSTM mampu mencapai akurasi tinggi pada dataset DSL maupun BISINDO, sekaligus mendemonstrasikan kemampuan generalisasi di skenario real‑time @lemmuela2025, @mahaputra2026, @wisudawati2026.

== Convolutional Neural Network 1D (Conv1D)
Convolutional Neural Network (CNN) pada awalnya dikembangkan untuk data citra dua dimensi, namun varian satu dimensinya (Conv1D) banyak diadopsi untuk pemrosesan data sekuensial seperti sinyal, teks, dan rangkaian fitur gerakan. Operasi konvolusi 1D bekerja dengan menggeser filter (kernel) satu arah sepanjang dimensi temporal dari sekuens input untuk menghasilkan peta fitur yang merepresentasikan pola lokal pada berbagai posisi.

Secara matematis, operasi Conv1D pada sekuens input $x$ dengan kernel $w$ berukuran $k$ didefinisikan sebagai:

$ y_i = sum_(j=0)^(k-1) w_j * x_(i+j) + b $

dengan $b$ adalah bias. Setelah konvolusi, umumnya diterapkan fungsi aktivasi non-linear seperti ReLU ($"ReLU"(x) = max(0, x)$) untuk menambah kapasitas representasi, serta lapisan pooling seperti MaxPooling 1D untuk mereduksi dimensi temporal dan mempertahankan fitur paling dominan.

Dalam konteks pengenalan bahasa isyarat berbasis landmark, penggunaan *dua lapisan Conv1D bertingkat (stacked Conv1D)* yang masing-masing diikuti oleh MaxPooling 1D memiliki tiga fungsi arsitektural krusial:
1. *Ekstraksi Fitur Spasial-Temporal Berjenjang (Hierarchical Feature Representation)*: Lapisan Conv1D pertama dengan kernel $k=5$ menangkap kinematika mikro lokal, seperti sudut relatif antar-sendi dan kecepatan pergerakan jari pada jendela 5 frame (~166 ms pada 30 fps). Setelah direduksi oleh MaxPooling 1D pertama, lapisan Conv1D kedua beroperasi pada representasi fitur yang lebih abstrak dengan *effective receptive field* yang berlipat ganda (~10–14 frame atau ~350–450 ms), sehingga mampu mengekstrak pola meso berupa trajektori tangan dan fase transisi bentuk gestur.
2. *Kompresi Temporal ($4times$ Downsampling) untuk Efisiensi Edge*: Kompleksitas komputasi recurrent neural network (BiGRU) berbanding lurus dengan panjang sekuens waktu ($O(T dot d^2)$). Pada CPU smartphone ARM, menjalankan BiGRU secara bolak-balik pada sekuens panjang (misalnya 60 frame) akan memicu beban komputasi masif dan meningkatkan latensi inferensi. Dengan menyusun dua blok Conv1D yang masing-masing menerapkan MaxPooling 1D dengan faktor reduksi 2, panjang sekuens dipadatkan sebesar $2 times 2 = 4times$ (dari 60 frame menjadi 15 time-steps). Hal ini memangkas iterasi *unrolling* pada BiGRU hingga 75%, menjadikannya sangat efisien untuk mencapai inferensi sub-100 ms pada perangkat mobile.
3. *Penyaring Derau Koordinat MediaPipe*: Koordinat landmark 3D dari MediaPipe rentan mengalami fluktuasi spasial kecil (*jitter*) antar-frame akibat kondisi pencahayaan atau *motion blur*. Dua blok Conv1D yang dilengkapi Batch Normalization bertindak sebagai filter penghalus (*smoothing filter*) yang memetakan koordinat bising menjadi representasi laten yang stabil sebelum diproses oleh lapisan rekuren @sulistianingsih2025, @darmayunata2026.

== Attention Mechanism
Mekanisme atensi (*attention mechanism*) memungkinkan model untuk secara dinamis memfokuskan pembobotan pada bagian-bagian tertentu dari sekuens input yang paling relevan dengan tugas klasifikasi. Dalam gestur dinamis bahasa isyarat, tidak seluruh frame memiliki nilai informasi yang setara. Suatu gestur umumnya terbagi menjadi tiga fase: fase persiapan (*preparation*), fase puncak eksekusi (*stroke/apex*), dan fase kembali ke posisi rileks (*retraction*).

Secara konvensional, model rekuren mengklasifikasikan sekuens dengan hanya mengambil *hidden state* terakhir ($h_T$) atau menerapkan *global average pooling*. Namun, kedua pendekatan tersebut memiliki kelemahan mendasar pada gestur bahasa isyarat:
- Mengambil hanya $h_T$ memicu *recency bias*, di mana model justru mengingat gerakan tangan kembali istirahat (*retraction*) atau frame *padding*, bukan bentuk inti gestur yang telah terjadi di pertengahan sekuens.
- Menerapkan *average pooling* meratakan bobot seluruh frame ($1/T$), sehingga mengencerkan (*dilutes*) fitur diskriminatif pada frame puncak dengan frame persiapan yang tidak informatif.

Oleh karena itu, penempatan lapisan *Temporal Attention* tepat setelah lapisan Bidirectional GRU (BiGRU) menjadi solusi ideal. Ketika BiGRU disetel dengan parameter `return_sequences=True`, model menghasilkan sekuens vektor representasi terkontekstualisasi $H = [h_1, h_2, dots, h_(T')]$ di mana setiap $h_t = [arrow.r(h)_t, arrow.l(h)_t]$ merangkum konteks temporal dari dua arah waktu (masa lalu dan masa depan). Lapisan *Temporal Attention* pasca-BiGRU selanjutnya menghitung skor relevansi ($e_t$) dan bobot atensi ternormalisasi ($alpha_t$):

$ e_t = v^T tanh(W h_t + b) $
$ alpha_t = exp(e_t) / sum_(j=1)^(T') exp(e_j) $
$ c = sum_(t=1)^(T') alpha_t h_t $

dengan $W$ adalah matriks bobot proyeksi, $b$ bias, $v$ vektor konteks atensi, dan $c$ adalah vektor konteks akhir yang merupakan representasi sekuens terbobot. Melalui formulasi ini, lapisan atensi secara adaptif memberikan bobot dominan ($alpha_t approx 1$) pada frame puncak gestur (*apex frames*) dan menekan bobot frame persiapan, transisi, maupun *padding* hingga mendekati nol @sebastian2025, @darmayunata2026. Vektor representasi $c$ yang padat dan informatif ini kemudian diteruskan ke lapisan klasifikasi akhir.

== Optimasi Model dengan TensorFlow Lite untuk Perangkat Mobile
TensorFlow Lite (TFLite) adalah seperangkat alat untuk menjalankan model machine learning pada perangkat edge seperti smartphone Android @sutjiadi2023, @pramasaa2025. TFLite mengonversi model TensorFlow ke format FlatBuffer yang ringkas serta menyediakan interpreter yang dioptimasi untuk arsitektur ARM @lucian2025. Alur konversi dan teknik optimasi yang disediakan TFLite ditunjukkan pada @fig-tflite.

#figure(
  image("convert.pdf", width: 70%),
  caption: "Alur konversi dan teknik optimasi TensorFlow Lite",
) <fig-tflite>

== Evaluasi Sistem Rekognisi Bahasa Isyarat
Evaluasi sistem rekognisi bahasa isyarat umumnya menggunakan metrik klasifikasi seperti accuracy, precision, recall, dan F1‑score untuk mengukur kemampuan model mengenali label gestur dengan benar. Keempat metrik tersebut didefinisikan sebagai berikut:

$ "Accuracy" = ("TP" + "TN") / ("TP" + "TN" + "FP" + "FN") $

$ "Precision" = "TP" / ("TP" + "FP") $

$ "Recall" = "TP" / ("TP" + "FN") $

$ "F1" = 2 * "P" * "R" / ("P" + "R") $

dengan $"TP"$ adalah true positives, $"TN"$ true negatives, $"FP"$ false positives, $"FN"$ false negatives, $"P"$ precision, dan $"R"$ recall.

Selain itu, untuk sistem yang menargetkan penggunaan real‑time di perangkat edge, aspek non‑fungsional seperti latensi inference, ukuran model, dan konsumsi sumber daya (memori dan komputasi) juga menjadi kriteria penting dalam menilai kelayakan deployment @darmayunata2026.

Pada studi sign language translation yang berskala kalimat, metrik tambahan seperti Word Error Rate (WER), Sentence Accuracy (SAcc), dan skor BLEU atau SacreBLEU digunakan untuk menilai kualitas translasi sekuens @putra2025. Meskipun penelitian ini berfokus pada kata terisolasi BISINDO Solo, prinsip pemilihan metrik yang sesuai dengan konteks evaluasi lintas-peraga dan benchmarking latensi on-device tetap krusial dalam perancangan eksperimen dan interpretasi hasil.

== Penelitian Terkait
Penelitian mengenai pengenalan Bahasa Isyarat Indonesia (BISINDO) dalam beberapa tahun terakhir menunjukkan perkembangan yang pesat, dengan beragam pendekatan mulai dari citra statis, video dinamis, pose/landmark, hingga deployment pada platform mobile, web, dan embedded. @tbl-penelitian-terkait merangkum studi-studi utama yang relevan dengan penelitian ini.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    inset: 0.8em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([*Peneliti*], [*Metode*], [*Dataset & Kelas*], [*Keterbatasan Utama*]),
    [@sutjiadi2023],
    [MobileNetV3 + TFLite Android],
    [6.240 citra, 26 alfabet BISINDO],
    [Akurasi rendah pada gestur dua tangan; terbatas citra statis],

    [@sulistianingsih2025],
    [Hybrid CNN-LSTM],
    [Video alfabet dinamis BISINDO],
    [Beban komputasi tinggi pada video mentah; belum teroptimasi edge],

    [@maheswara2024],
    [MediaPipe Holistic + GRU/LSTM],
    [2.400 video, 20 gestur BISINDO],
    [Penurunan akurasi saat real-time; evaluasi signer terbatas],

    [@lemmuela2025],
    [MediaPipe + BiLSTM / CNN],
    [315 video, 15 kata BISINDO],
    [Kosakata terbatas konteks ibadah; pengujian sebatas desktop],

    [@putra2025],
    [YOLOv8 + TCRF + MobileNetV2 + LSTM],
    [190 kalimat, 435 label BISINDO],
    [Beban komputasi tinggi, skenario server bukan perangkat edge],

    [@mahaputra2026],
    [MediaPipe + LSTM + ESP32],
    [250 sampel, 5 kata BISINDO],
    [Dataset 1 peraga, 5 kata saja; latensi transmisi 3,8 detik],

    [@pramasaa2025],
    [MobileNetV2 SSD + TFLite],
    [5.902 citra, 26 alfabet BISINDO],
    [Terbatas alfabet statis; degradasi akurasi pada lux rendah],

    [@sebastian2025],
    [MediaPipe Holistic + GCN + BiLSTM],
    [51 kelas (alfabet & kata)],
    [Inferensi graf kompleks; sensitif missing keypoints],
  ),
  caption: "Ringkasan penelitian terkait pengenalan BISINDO dan dynamic sign language",
) <tbl-penelitian-terkait>

Dari tabel @tbl-penelitian-terkait, terlihat bahwa pendekatan yang digunakan sangat bervariasi, mulai dari model berbasis citra visual mentah (@sutjiadi2023, @pramasaa2025), MediaPipe Holistic dengan GRU/LSTM untuk video dinamis (@maheswara2024, @lemmuela2025), hingga model translasi kalimat berbasis server (@putra2025). Skala deployment pun beragam, dari server dan PC hingga perangkat edge seperti Android (@sutjiadi2023) dan mikrokontroler (@mahaputra2026). Masing-masing pendekatan menunjukkan potensi dan keterbatasannya masing-masing yang menjadi dasar identifikasi gap pada sub-bab selanjutnya.

== Gap Penelitian
@tbl-gap merangkum gap-gap utama yang diidentifikasi dari penelitian-penelitian yang telah dibahas serta posisi penelitian ini terhadap masing-masing gap tersebut.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 1em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([*Aspek*], [*State-of-the-Art*], [*Posisi Penelitian Ini*]),
    [
      Dataset
    ],
    [
      Alfabet statis BISINDO dari webcam publik; ketiadaan dataset varietas regional (@sutjiadi2023, @pramasaa2025)
    ],
    [
      Membangun dataset BISINDO Solo 20 kelas terstandarisasi dengan 5 peraga (signer)
    ],

    [
      Jenis gestur
    ],
    [
      Dominan alfabet statis; gestur dinamis berbasis video mentah berbobot tinggi (@sulistianingsih2025, @putra2025)
    ],
    [
      Gestur dinamis berbasis 51 landmark MediaPipe Holistic yang ringan dan invarian lingkungan
    ],

    [
      Metode
    ],
    [
      Model sekuensial tunggal atau model graf berlatensi tinggi (@maheswara2024, @sebastian2025)
    ],
    [
      Arsitektur hibrida Conv1D–BiGRU teratensi temporal yang efisien untuk edge device
    ],

    [
      Target \ deployment
    ],
    [
      Server/PC atau Android terbatas pada alfabet statis (@sutjiadi2023, @putra2025)
    ],
    [
      Aplikasi bergerak Android (TFLite) untuk gestur dinamis dengan target latensi inferensi di bawah 100 ms
    ],

    [
      Konteks \ evaluasi
    ],
    [
      Pengujian peraga homogen (_signer-dependent_) atau demonstrasi laboratorium tanpa uji latensi perangkat (@maheswara2024, @mahaputra2026)
    ],
    [
      _Benchmarking_ ketat lintas-peraga (_cross-signer_ LOSO) serta evaluasi kompresi model dan latensi _on-device_
    ],
  ),
  caption: "Analisis gap penelitian dan posisi penelitian ini",
) <tbl-gap>
//
= Metode Penelitian

Fokus utama penelitian ini adalah mengukur dan menganalisis performa model SLR secara terukur melalui metrik numerik. Maka dari itu, digunakan pendekatan quasi eksperimental yang memungkinkan evaluasi sistematis terhadap pengaruh desain arsitektur model dan skenario deployment terhadap akurasi klasifikasi gestur BISINDO Solo.

Secara khusus, penelitian ini berfokus pada pengujian kinerja arsitektur hibrida Conv1D–BiGRU teratensi temporal yang dioptimasi dan dikonversi ke format TensorFlow Lite pada perangkat bergerak Android. Dengan demikian, penelitian ini tidak hanya mengevaluasi performa model pada lingkungan laboratorium (offline), tetapi juga menguji kelayakan penggunaan model secara real-time di perangkat edge.

Penelitian ini dilaksanakan secara sistematis mengikuti skema _Computer Vision Life-Cycle_ pada @alur-penelitian. Desain ini dipilih agar model yang diusulkan dapat dibandingkan dengan penelitian sebelumnya dari sisi akurasi dan efisiensi komputasi. Tahap evaluasi offline digunakan untuk memilih konfigurasi model terbaik sebelum dilakukan optimasi dan deployment, sedangkan evaluasi real-time di Android bertujuan memastikan bahwa model yang dipilih memenuhi persyaratan latensi dan ukuran untuk penggunaan praktis pada perangkat bergerak.

#figure(
  image("step.pdf", width: 80%),
  caption: "Alur penelitian",
) <alur-penelitian>

== Dataset
Data yang digunakan dalam penelitian ini berupa rekaman video gestur BISINDO Solo yang merepresentasikan frasa-frasa dasar yang umum digunakan dalam komunikasi sehari-hari komunitas Tuli di Surakarta. Sebanyak 20 kelas gestur dipilih dengan merujuk pada materi kelas level 1 BISINDO yang disusun oleh Pusat Bahasa Isyarat Indonesia (PUSBISINDO), sehingga setiap kelas memiliki relevansi langsung dengan konteks pelatihan dan pembelajaran dasar. @tbl-dataset merangkum komposisi dataset yang digunakan.

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 1em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([Komponen], [Parameter], [Keterangan]),
    [Jumlah Kelas gestur], [20], [Frasa dasar BISINDO Solo level 1],
    [Jumlah signer], [5], [Masing-masing 5 repetisi],
    [Total video mentah], [500], [20 x 5 x 5],
    [Frame rate], [30 fps], [Diseragamkan],
    [Resolusi], [480p], [Diseragamkan],
  ),
  caption: "Komposisi dataset BISINDO Solo",
) <tbl-dataset>

Untuk setiap kelas gestur, data dikumpulkan dari 5 peraga (signer) yang berbeda, masing-masing melakukan 5 repetisi, sehingga total diperoleh 500 video mentah (20 kelas × 5 peraga × 5 repetisi). Proses perekaman dilakukan dalam lingkungan yang relatif terkontrol dengan pengaturan jarak kamera, sudut pengambilan, dan pencahayaan yang cukup, namun tetap mempertahankan variasi alami antar peraga agar dataset representatif terhadap kondisi pelatihan di dunia nyata.

== Prapemrosesan Data dan Fitur
Tahap pra-pemrosesan diawali dengan proses capture video untuk setiap gestur sesuai skenario pengambilan data yang telah ditentukan. Video mentah kemudian diproses menjadi sekuens frame dengan resolusi dan frame rate yang diseragamkan. Untuk meningkatkan keragaman data dan membantu model beradaptasi dengan variasi kecil dalam pelaksanaan gestur, dilakukan augmentasi data menggunakan beberapa transformasi, seperti pergeseran horizontal (shift kiri dan kanan), horizontal flip, serta variasi kecepatan (fast dan slow motion) pada rentang yang masih mempertahankan makna gestur.

Setelah augmentasi, setiap frame video diproses menggunakan MediaPipe Holistic untuk mengekstraksi landmark utama yang relevan dengan gerakan BISINDO Solo. Penelitian ini memanfaatkan landmark tangan dan pose bagian atas tubuh, yang mencakup 9 titik pose upper body serta 21 titik tangan kanan dan 21 titik tangan kiri. Koordinat landmark kemudian dinormalisasi terhadap titik referensi tertentu agar lebih invarian terhadap perbedaan posisi dan jarak kamera. Hasilnya adalah sekuens vektor fitur berdimensi tetap yang merepresentasikan dinamika gestur dalam domain spasial-temporal.

== Model

#figure(
  image("proposed.pdf", width: 100%),
  caption: "Arsitektur Model Hibrida Conv1D–BiGRU dengan Temporal Attention",
) <model-arch>

Arsitektur model yang diusulkan pada @model-arch dirancang secara spesifik untuk memecahkan dilema akurasi dan efisiensi komputasi pada pengenalan gestur dinamis di perangkat bergerak. Model ini mengintegrasikan empat tahapan komputasi utama:

1. *Prapemrosesan Masukan dan Regularisasi Spasial*:
   Masukan model berupa sekuens matriks berukuran $T times D$, di mana $T$ adalah panjang sekuens frame (diseragamkan ke panjang maksimum dengan *zero-padding*) dan $D$ adalah dimensi fitur gabungan koordinat landmark beserta kanal mask validitasnya. Lapisan *Spatial Dropout 1D* (rate 0,2) diterapkan di awal untuk mendrop kanal koordinat secara acak sepanjang sekuens, guna mencegah model mengalami ketergantungan berlebih (*co-adaptation*) pada koordinat sendi tertentu.

2. *Blok Konvolusi 1D Bertingkat (Dua Lapisan Conv1D + MaxPooling 1D)*:
   Model menerapkan dua blok konvolusi temporal bertingkat, di mana setiap blok terdiri atas lapisan `Conv1D(filters=128, kernel_size=5, padding="same")`, `BatchNormalization`, aktivasi `ReLU`, dan `MaxPooling1D(pool_size=2)`. Pemilihan dua lapisan Conv1D bertingkat ini didasari oleh dua alasan teknis fundamental:
   - *Hierarki Kinematika Spasial-Temporal*: Lapisan Conv1D pertama menangkap dinamika mikro lokal (kecepatan sesaat dan perubahan sudut antar-sendi jari) pada rentang 5 frame (~166 ms). Lapisan Conv1D kedua beroperasi pada representasi yang telah direduksi, menghasilkan *effective receptive field* yang berlipat ganda (~10–14 frame atau ~350–450 ms) untuk menangkap trajektori meso pembentukan gestur, sekaligus meredam derau (*jitter*) deteksi MediaPipe.
   - *Kompresi Temporal ($4times$ Downsampling)*: Penerapan dua lapisan MaxPooling1D berturut-turut (masing-masing faktor reduksi 2) memadatkan dimensi waktu sebesar $2 times 2 = 4times$ (misalnya dari 60 frame menjadi 15 langkah waktu). Kompresi ini memangkas iterasi rekuren pada lapisan BiGRU berikutnya sebesar 75%, yang menjadi faktor kunci dalam menekan latensi inferensi di bawah 100 ms pada prosesor mobile ARM.

3. *Lapisan Rekuren Bidirectional GRU (BiGRU)*:
   Fitur temporal yang telah tereduksi kemudian diproses oleh dua lapisan bertumpuk *Bidirectional Gated Recurrent Unit* (BiGRU) dengan 192 unit tersembunyi. GRU dipilih dibanding LSTM karena memiliki struktur *gate* yang lebih ringkas (hanya *reset* dan *update gate* tanpa memori sel terpisah), sehingga menghemat parameter hingga ~25% dan mempercepat inferensi *on-device*. Sifat *bidirectional* memastikan bahwa representasi pada setiap langkah waktu merangkum konteks pergerakan dari arah maju ($arrow.r(h)_t$) dan arah mundur ($arrow.l(h)_t$). Kedua lapisan disetel dengan `return_sequences=True` agar seluruh trajektori temporal tetap terjaga untuk dievaluasi oleh mekanisme atensi.

4. *Lapisan Temporal Attention dan Klasifikasi*:
   Lapisan *Temporal Attention* ditempatkan tepat setelah BiGRU untuk mengagregasi sekuens vektor tersembunyi $[h_1, h_2, dots, h_(T')]$ menjadi satu vektor konteks $c$. Alih-alih hanya mengambil *state* terakhir $h_T$ yang rentan terhadap *recency bias* (karena gestur di akhir video umumnya hanya berupa gerakan tangan kembali istirahat atau *padding*), mekanisme atensi secara otomatis mempelajari bobot kepentingan setiap frame dan memprioritaskan momen puncak formasi gestur (*apex frames*). Vektor konteks $c$ selanjutnya diproses melalui lapisan *Dense* (192 unit, ReLU, L2 regularizer), *Batch Normalization*, *Dropout* (0,3), dan lapisan *Dense* keluaran dengan fungsi *Softmax* untuk menghasilkan distribusi probabilitas terhadap 20 kelas gestur BISINDO Solo.

== Hyperparameter Tuning
Hyperparameter yang dioptimasi dalam penelitian ini meliputi parameter arsitektur dan parameter pelatihan seperti dirangkum pada @tbl-hyperparameter.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    inset: 1em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([Hyperparameter], [Nilai yang Diuji], [Hyperparameter], [Nilai yang Diuji]),
    [Unit GRU], [128, 192, 256], [Blok Conv1D], [1, 2],
    [Kernel Conv1D], [3, 5, 7], [Spatial Dropout], [0,1; 0,3; 0,5],
    [Rate Dropout], [0,2; 0,3; 0,5], [Learning rate], [$10^(-3)$, $10^(-4)$, $10^(-5)$],
    [Batch size], [32, 64, 128], [Epoch], [60, 100, 150],
    [Early Stopping], [10, 15, 20], [Optimizer], [Adam, RMSprop, SGD],
  ),
  caption: "Hyperparameter tuning",
) <tbl-hyperparameter>

== Pelatihan dan Pengujian
Skema pengujian yang digunakan adalah k-fold cross-validation, di mana pada setiap fold satu peraga disisihkan sebagai data uji, sedangkan empat peraga lainnya digunakan sebagai data latih dan validasi. Dengan cara ini, model diuji kemampuan generalisasinya terhadap penanda baru yang tidak pernah muncul pada tahap pelatihan (_Leave-One-Signer-Out_), yang merefleksikan kondisi penggunaan dunia nyata di mana pengguna aplikasi berbeda dari peraga di dataset pelatihan. Ilustrasi skema k-fold cross-validation untuk lima signer disajikan pada @kfold.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    inset: 1em,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,
    table.header([Fold], [Signer 1], [Signer 2], [Signer 3], [Signer 4], [Signer 5]),
    [1],
    table.cell(fill: rgb("#cbe1bd"))[Uji],
    [Latih],
    [Latih],
    [Latih],
    [Latih],
    [2],
    [Latih],
    table.cell(fill: rgb("#cbe1bd"))[Uji],
    [Latih],
    [Latih],
    [Latih],
    [3],
    [Latih],
    [Latih],
    table.cell(fill: rgb("#cbe1bd"))[Uji],
    [Latih],
    [Latih],
    [4],
    [Latih],
    [Latih],
    [Latih],
    table.cell(fill: rgb("#cbe1bd"))[Uji],
    [Latih],
    [5],
    [Latih],
    [Latih],
    [Latih],
    [Latih],
    table.cell(fill: rgb("#cbe1bd"))[Uji],
  ),
  caption: "Skema k-fold cross-validation untuk 5 signer",
) <kfold>

Pelatihan dilakukan dengan maksimum 100 epoch dan ukuran batch 64, menggunakan mekanisme early stopping dengan patience 15 epoch berdasarkan metrik validasi loss untuk mencegah overfitting. Pada setiap fold, data latih dapat dibagi lagi menjadi subset training dan validation (misalnya 80:20) agar proses pemantauan performa selama pelatihan lebih stabil.

Untuk pengujian, model terbaik dari setiap fold dievaluasi pada data signer yang disisihkan (test signer) guna memperoleh metrik akurasi, precision, recall, dan F1‑score per kelas maupun secara makro. Hasil dari seluruh fold k-fold cross-validation kemudian dirata-ratakan untuk menghasilkan estimasi performa model yang lebih robust. Selain pengujian utama, dilakukan analisis tambahan seperti confusion matrix per kelas untuk mengidentifikasi gestur yang sering tertukar.

== Evaluasi Model
Evaluasi performa model dilakukan dengan dua kelompok metrik, yaitu metrik klasifikasi dan metrik deployment. Untuk metrik klasifikasi, penelitian ini menggunakan accuracy, precision, recall, dan F1‑score, baik pada tingkat makro maupun per kelas, untuk menilai kemampuan model dalam mengenali 20 kelas gestur BISINDO Solo. Penggunaan beberapa metrik ini penting untuk menangkap aspek ketidakseimbangan data dan kesalahan klasifikasi pada kelas-kelas tertentu yang mungkin lebih sulit dikenali.

Untuk metrik deployment, penelitian ini mengukur ukuran berkas model TensorFlow Lite setelah proses optimasi serta latensi inference per prediksi pada perangkat Android. Kriteria keberhasilan yang ditetapkan adalah:

+ Akurasi klasifikasi minimal 80% pada skenario k-fold cross-validation.

+ Ukuran model TFLite tidak lebih dari 10 MB agar praktis digunakan di perangkat dengan sumber daya terbatas.

+ Latensi inference rata-rata kurang dari 100 ms per prediksi pada perangkat Android target sehingga memungkinkan responsivitas waktu-nyata saat digunakan secara interaktif.

Kombinasi kriteria ini memastikan bahwa model tidak hanya akurat di laboratorium, tetapi juga cukup ringan dan responsif untuk penggunaan praktis pada perangkat bergerak.

== Implementasi Android
Tahap implementasi dimulai dengan konversi model GRU terbaik ke format TensorFlow Lite yang self-contained, termasuk penanganan operasi masking dan padding sehingga input sekuens dengan panjang berbeda dapat diproses secara konsisten dengan padding nilai NaN kemudian dikonversi menjadi nol sebelum inferensi. Model TFLite ini dikemas bersama logika pra-pemrosesan di sisi aplikasi Android, sehingga pipeline dari akuisisi frame hingga prediksi kelas dapat berjalan sepenuhnya di perangkat.

#figure(
  image("android.pdf", width: 90%),
  caption: "Alur Kerja Android",
) <workflow>

Di sisi Android, sistem diintegrasikan sebagai pipeline inferensi real-time yang menghubungkan akuisisi video, ekstraksi landmark, pembentukan fitur, dan klasifikasi gestur. Seperti ditunjukkan pada @workflow, MediaPipe berperan sebagai komponen prapemrosesan untuk memperoleh representasi landmark yang siap digunakan model, sedangkan TensorFlow Lite menjalankan inferensi langsung di perangkat. Hasil prediksi kemudian dikembalikan ke antarmuka aplikasi sebagai pengenalan gestur seketika, sehingga keseluruhan alur dapat berjalan secara responsif pada platform mobile.

Pengujian implementasi dilakukan pada kondisi lingkungan yang tidak sepenuhnya terkontrol tetapi tetap memiliki pencahayaan yang memadai, untuk menguji robustness sistem terhadap variasi dunia nyata.

Perbandingan dilakukan terhadap metrik akurasi dan konsistensi prediksi per kelas, serta pengukuran latensi rata-rata per inferensi di perangkat. Analisis ini memberikan gambaran seberapa besar penurunan performa ketika model dipindahkan ke lingkungan edge dan apakah penurunan tersebut masih berada dalam batas yang dapat diterima untuk implementasi pengenalan BISINDO Solo secara mandiri di perangkat seluler.

== Jadwal Penelitian
Penelitian ini dilaksanakan dalam delapan tahap selama sembilan bulan, terhitung mulai September 2026 hingga Mei 2027. @tbl-jadwal merinci alokasi waktu setiap tahap dengan blok hijau menandakan bulan pelaksanaan.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    align: left,

    table.header(
      table.cell(rowspan: 2, align: center)[*Kegiatan*],
      table.cell(colspan: 9, align: center)[*Timeline*],
      table.cell(align: center)[*Sep*],
      table.cell(align: center)[*Okt*],
      table.cell(align: center)[*Nov*],
      table.cell(align: center)[*Des*],
      table.cell(align: center)[*Jan*],
      table.cell(align: center)[*Feb*],
      table.cell(align: center)[*Mar*],
      table.cell(align: center)[*Apr*],
      table.cell(align: center)[*Mei*],
    ),

    table.cell(inset: 1em)[Studi literatur dan identifikasi masalah],
    table.cell(fill: rgb("#cbe1bd"))[], [], [], [], [], [], [], [], [],

    table.cell(inset: 1em)[Penyusunan dan seminar proposal],
    [], table.cell(fill: rgb("#cbe1bd"))[], [], [], [], [], [], [], [],

    table.cell(inset: 1em)[Pembangunan dataset (perekaman 500 video)],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    [],
    [],
    [],
    [],
    [],

    table.cell(inset: 1em)[Prapemrosesan dan ekstraksi landmark MediaPipe],
    [],
    [],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    [],
    [],
    [],
    [],

    table.cell(inset: 1em)[Pelatihan dan evaluasi model GRU],
    [],
    [],
    [],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    [],
    [],

    table.cell(inset: 1em)[Konversi TFLite dan implementasi Android],
    [],
    [],
    [],
    [],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    [],
    [],

    table.cell(inset: 1em)[Pengujian real-time Android dan analisis hasil],
    [],
    [],
    [],
    [],
    [],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
    [],

    table.cell(inset: 1em)[Penyusunan laporan akhir dan sidang],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    table.cell(fill: rgb("#cbe1bd"))[],
    table.cell(fill: rgb("#cbe1bd"))[],
  ),
  caption: "Jadwal pelaksanaan penelitian Sep 2026 - Mei 2027",
) <tbl-jadwal>

#bibliography("refs.bib", style: "apa", title: "Daftar Pustaka")


