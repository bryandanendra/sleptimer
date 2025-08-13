# Cara Install dan Jalankan Sleep Timer

## Prerequisites
- Flutter SDK terinstall
- Xcode terinstall (untuk macOS development)

## Langkah Instalasi

1. **Clone dan Setup**
   ```bash
   cd sleptimer
   flutter pub get
   ```

2. **Build Aplikasi**
   ```bash
   flutter build macos
   ```

3. **Jalankan Aplikasi**
   ```bash
   ./run_app.sh
   ```

## Troubleshooting

Jika ada masalah dengan permission:
- Pastikan Xcode command line tools terinstall
- Jalankan `sudo xcode-select --install`

## Fitur Aplikasi

- Timer dengan format 00:25:00
- Mode Sleep dan Shutdown
- UI minimalis dengan dark theme
- Gradient background biru-ungu
- Rounded corners design
