# App Icon Setup - Sleep Timer

## Icon Baru yang Diterapkan

### 🎨 **Deskripsi Icon**
- **Bentuk**: Persegi dengan sudut membulat
- **Background**: Abu-abu gelap solid
- **Elemen Utama**: 
  - Bulan sabit putih (outline) menghadap kanan
  - Panah putih solid menunjuk ke bawah di dalam cekungan bulan
- **Style**: Minimalis dan bersih dengan kontras tinggi

### 📱 **Lokasi Icon**
- **App Icon**: `assets/icon.png`
- **macOS Icons**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Tray Icon**: Menggunakan icon yang sama

### 🔧 **Ukuran Icon yang Dibuat**
- **16x16** - app_icon_16.png (186 bytes)
- **32x32** - app_icon_32.png (202 bytes)
- **64x64** - app_icon_64.png (289 bytes)
- **128x128** - app_icon_128.png (621 bytes)
- **256x256** - app_icon_256.png (1.7KB)
- **512x512** - app_icon_512.png (5.7KB)
- **1024x1024** - app_icon_1024.png (20KB)

### ⚙️ **Konfigurasi yang Diperbarui**

#### 1. **pubspec.yaml**
```yaml
assets:
  - assets/icon.png
```

#### 2. **Info.plist**
```xml
<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

#### 3. **Tray Manager**
```dart
await trayManager.setIcon('assets/icon.png');
```

## Cara Mengganti Icon

### 1. **Siapkan Icon Baru**
- Format: PNG
- Ukuran: Minimal 1024x1024 pixels
- Background: Transparan atau solid
- Style: Konsisten dengan desain aplikasi

### 2. **Replace Icon Files**
```bash
# Copy icon baru ke assets
cp new_icon.png assets/icon.png

# Resize untuk semua ukuran macOS
sips -z 1024 1024 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
sips -z 512 512 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
sips -z 256 256 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
sips -z 128 128 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
sips -z 64 64 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
sips -z 32 32 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
sips -z 16 16 assets/icon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
```

### 3. **Build dan Test**
```bash
flutter clean
flutter pub get
flutter build macos
./launch_app.command
```

## Icon Usage

### 🖥️ **Desktop App Icon**
- Muncul di Dock (jika tidak di-skip)
- Muncul di Finder
- Muncul di Applications folder

### 📋 **Menu Bar Icon**
- Muncul di menu bar saat aplikasi diminimize
- Klik untuk menampilkan aplikasi
- Klik kanan untuk menu konteks

### 🎯 **Window Title Bar**
- Icon kecil di title bar window
- Konsisten dengan macOS design guidelines

## Best Practices

### ✅ **Icon Design**
- **Simplicity**: Desain sederhana dan mudah dikenali
- **Scalability**: Terlihat baik di semua ukuran
- **Consistency**: Konsisten dengan tema aplikasi
- **Contrast**: Kontras tinggi untuk keterbacaan

### ✅ **Technical Requirements**
- **Format**: PNG dengan transparansi
- **Resolution**: Minimal 1024x1024 untuk kualitas tinggi
- **Aspect Ratio**: 1:1 (square)
- **File Size**: Optimized untuk performa

### ✅ **Testing**
- Test di berbagai ukuran display
- Test di menu bar (kecil)
- Test di dock (sedang)
- Test di finder (besar)

## Troubleshooting

### ❌ **Icon Tidak Muncul**
1. Pastikan file ada di lokasi yang benar
2. Clean dan rebuild aplikasi
3. Periksa ukuran file (tidak boleh 1x1 pixel)
4. Restart aplikasi

### ❌ **Icon Blur atau Pixelated**
1. Gunakan source image dengan resolusi tinggi
2. Pastikan resize menggunakan algoritma yang baik
3. Test di berbagai ukuran display

### ❌ **Tray Icon Tidak Muncul**
1. Periksa path di `trayManager.setIcon()`
2. Pastikan file ada di assets folder
3. Restart aplikasi setelah perubahan
