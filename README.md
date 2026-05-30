HATI HATI SAAT COMMIT

nama-proyek-anda/
├── .github/                  # Konfigurasi GitHub (CI/CD, Issue templates)
├── .gitignore                # File yang diabaikan oleh Git (wajib)
├── README.md                 # Dokumentasi proyek (wajib)
├── pubspec.yaml              # Dependensi Flutter & Database
├── android/                  # Native Android configuration
├── ios/                      # Native iOS configuration
├── web/                      # Native Web configuration (opsional)
├── assets/                   # File gambar, font, atau file DB lokal (.db / .sqlite)
│   ├── images/
│   └── database/
└── lib/                      # Folder utama kode Flutter Anda
    ├── main.dart             # Titik awal aplikasi
    ├── core/                 # Komponen global yang dipakai di seluruh aplikasi
    │   ├── constants/        # Warna, string, tema, atau nama tabel DB
    │   ├── network/          # Setup API client (jika ada)
    │   └── utils/            # Fungsi bantuan (helpers)
    │
    └── src/                  # Arsitektur Fitur (Fitur-driven)
        └── feature_name/     # Contoh fitur: 'auth', 'profile', atau 'tasks'
            ├── data/         # BAGIAN DATABASE & DATA (Backend Lokal)
            │   ├── datasources/ # Sumber data (Local DB atau Remote API)
            │   │   ├── local_db_helper.dart
            │   │   └── remote_api_client.dart
            │   ├── models/   # Konversi JSON/Map dari DB ke objek Dart
            │   └── repositories/ # Implementasi logika pengambilan data
            │
            ├── domain/       # LOGIKA BISNIS (Murni Dart, bebas dari UI/DB)
            │   ├── entities/ # Objek bisnis utama
            │   └── repositories/ # Cetak biru (interface) repository
            │
            └── presentation/ # BAGIAN VISUAL (UI / Frontend)
                ├── controllers/ # State management (Bloc, Provider, Riverpod, dll)
                ├── pages/    # Halaman aplikasi (Screens)
                └── widgets/  # Komponen UI kecil yang bisa digunakan ulang
