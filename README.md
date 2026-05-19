# SalonHub

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![NvChad](https://img.shields.io/badge/NvChad-0F111A?style=for-the-badge&logo=neovim&logoColor=57A143)
![Kitty](https://img.shields.io/badge/Kitty_Terminal-111111?style=for-the-badge&logo=kitty&logoColor=white)

SalonHub adalah aplikasi booking barbershop dan salon berbasis Flutter. Aplikasi ini mendukung alur pelanggan, pemilik barbershop, dan superadmin dengan Firebase sebagai backend utama.

## Fitur Utama

- Login, register, forgot password, dan role-based routing.
- Role pengguna: `user`, `admin`, dan `superadmin`.
- Pencarian barbershop, favorit, booking, riwayat booking, dan profil pengguna.
- Dashboard admin untuk mengelola profil barbershop, layanan, stylist, booking, dan laporan.
- Dashboard superadmin untuk memantau user, barbershop, analytics, dan data platform.
- Integrasi Firebase Auth, Cloud Firestore, Storage, Messaging, Analytics, dan Crashlytics.
- Struktur project dibuat dengan pendekatan clean architecture.

## Tech Stack

| Bagian | Teknologi |
| --- | --- |
| Framework | Flutter |
| Bahasa | Dart |
| State management | GetX |
| Backend | Firebase |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Notification | Firebase Cloud Messaging |
| Payment ready | Midtrans SDK |
| Editor | Neovim / NvChad |
| Terminal | Kitty |

## Struktur Project

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   ├── seed/
│   └── services/
├── presentation/
│   ├── controllers/
│   ├── helpers/
│   ├── pages/
│   │   ├── admin/
│   │   ├── auth/
│   │   ├── superadmin/
│   │   └── user/
│   └── widgets/
└── routes/
```

## Persiapan Development

Pastikan sudah tersedia:

- Flutter SDK sesuai versi di `pubspec.yaml`.
- Dart SDK yang kompatibel dengan Flutter.
- Firebase project.
- Android Studio, Xcode untuk iOS, atau toolchain platform yang ingin dipakai.
- Neovim/NvChad dan Kitty bersifat opsional, tetapi digunakan sebagai setup editor/terminal project ini.

## Instalasi

```bash
git clone <repository-url>
cd project_salonhub_windsurf
flutter pub get
```

## Konfigurasi Firebase

Project publik tidak menyertakan file konfigurasi Firebase dan credential lokal. Buat konfigurasi sendiri dari Firebase Console.

1. Buat project di Firebase Console.
2. Aktifkan Authentication dengan provider Email/Password.
3. Aktifkan Cloud Firestore, Firebase Storage, Firebase Messaging, Analytics, dan Crashlytics sesuai kebutuhan.
4. Tambahkan aplikasi Android dan iOS di Firebase.
5. Simpan file konfigurasi lokal:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
6. Jalankan kembali `flutter pub get`.

File konfigurasi Firebase, `.env`, signing key, dan test credential sudah masuk `.gitignore` agar tidak ikut ter-publish.

## Menjalankan Aplikasi

```bash
flutter run
```

Untuk memilih device tertentu:

```bash
flutter devices
flutter run -d <device-id>
```

Build Android release:

```bash
flutter build apk --release
```

## Panduan Pemakaian Aplikasi

### User

1. Register atau login sebagai pengguna.
2. Cari barbershop/salon dari halaman home atau search.
3. Buka detail barbershop, pilih layanan dan stylist.
4. Buat booking sesuai tanggal dan jam yang tersedia.
5. Pantau booking dari halaman riwayat.
6. Simpan barbershop favorit dan kelola data profil.

### Admin

1. Login menggunakan akun admin barbershop.
2. Lengkapi profil barbershop.
3. Tambah atau ubah layanan yang tersedia.
4. Tambah stylist dan data pendukungnya.
5. Kelola booking masuk dari pelanggan.
6. Pantau ringkasan performa dan laporan.

### Superadmin

1. Login menggunakan akun superadmin.
2. Pantau statistik platform dari dashboard analytics.
3. Kelola data user.
4. Kelola data barbershop.
5. Cek kondisi dan aktivitas platform.

## Catatan Keamanan Sebelum Public

- Jangan commit `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, `.env`, signing key, atau file akun testing.
- Jika file secret sudah pernah terlanjur masuk commit di repo private, hapus dari Git tracking dan rotate key/credential sebelum repository dibuat public.
- Gunakan Firebase Security Rules yang ketat untuk role `user`, `admin`, dan `superadmin`.
- Hindari menaruh password test di README publik.

## Perintah Berguna

```bash
flutter pub get
flutter analyze
flutter test
flutter clean
flutter run
```

## Status Platform

| Platform | Status |
| --- | --- |
| Android | Didukung |
| iOS | Didukung dengan konfigurasi Firebase/iOS yang sesuai |
| Web | Eksperimental |
| Desktop | Eksperimental |

## License

Gunakan license sesuai kebutuhan repository. Jika repository dibuat public, tambahkan file `LICENSE` agar aturan penggunaan project jelas.
