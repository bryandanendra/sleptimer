# Sleep Timer - macOS Flutter App

Aplikasi Flutter untuk macOS yang menyediakan fitur timer untuk sleep dan shutdown dengan UI minimalis dan dark theme.

## Fitur Utama

- **Timer Display**: Tampilan digital timer besar dengan format 00:25:00
- **Time Controls**: Spinner untuk mengatur jam, menit, dan detik
- **Action Modes**: 
  - Sleep Mode: Menidurkan sistem setelah timer selesai
  - Shutdown Mode: Mematikan sistem setelah timer selesai
- **Control Buttons**: Start, Stop, dan Reset timer
- **Modern UI**: Dark theme dengan gradient background dan rounded corners

## Screenshots

Aplikasi memiliki interface yang elegan dengan:
- Gradient background biru-ungu
- Timer display yang besar dan mudah dibaca
- Kontrol waktu yang intuitif
- Tombol aksi yang jelas dan mudah diakses

## Cara Penggunaan

1. **Set Timer**: Gunakan spinner untuk mengatur waktu yang diinginkan
2. **Pilih Mode**: Pilih antara Sleep atau Shutdown
3. **Start Timer**: Klik tombol Start untuk memulai countdown
4. **Kontrol**: Gunakan Stop untuk menghentikan atau Reset untuk mengatur ulang

## Requirements

- macOS 10.14 atau lebih baru
- Flutter SDK
- Xcode (untuk development)

## Installation

1. Clone repository ini
2. Jalankan `flutter pub get`
3. Jalankan `flutter run -d macos`

## Build untuk Production

```bash
flutter build macos
```

## Permissions

Aplikasi memerlukan permission untuk:
- Menjalankan perintah sistem (sleep/shutdown)
- Akses ke terminal commands

## Teknologi

- Flutter 3.x
- Dart
- macOS native APIs
- process_run package untuk eksekusi perintah sistem

## License

MIT License
