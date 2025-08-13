# Troubleshooting Sleep Timer

## Masalah: Aplikasi Tidak Muncul

### Solusi 1: Jalankan dengan Script
```bash
./launch_app.command
```

### Solusi 2: Build dan Jalankan Manual
```bash
flutter clean
flutter pub get
flutter build macos
open build/macos/Build/Products/Release/sleptimer.app
```

### Solusi 3: Debug Mode
Jika aplikasi crash, jalankan dalam debug mode untuk melihat error:
```bash
flutter run -d macos
```

## Masalah: Icon Tidak Muncul di Menu Bar

### Penyebab dan Solusi:
1. **Aplikasi belum diminimize** - Klik tombol minimize atau close
2. **Icon tersembunyi** - Periksa area overflow di menu bar
3. **Aplikasi crash** - Restart aplikasi dengan script launch

## Masalah: Aplikasi Crash Saat Startup

### Penyebab:
- Masalah dengan icon tray
- Konfigurasi window manager
- Dependensi yang tidak kompatibel

### Solusi:
1. Jalankan `flutter clean && flutter pub get`
2. Build ulang aplikasi
3. Periksa console untuk error messages

## Cara Menggunakan Menu Bar

1. **Minimize aplikasi** dengan tombol minimize atau close
2. **Icon akan muncul di menu bar** (bagian atas layar)
3. **Klik icon** untuk menampilkan aplikasi
4. **Klik kanan** untuk menu konteks

## Menu Konteks Tray

- **Show App** - Tampilkan aplikasi
- **Hide App** - Sembunyikan aplikasi
- **Start Timer** - Mulai timer
- **Stop Timer** - Hentikan timer
- **Quit** - Keluar dari aplikasi

## Verifikasi Aplikasi Berjalan

```bash
ps aux | grep sleptimer
```

Jika ada output, aplikasi berjalan dengan baik.

## Restart Aplikasi

```bash
pkill -f "sleptimer.app"
./launch_app.command
```
