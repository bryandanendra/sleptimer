# Installation Guide - RestClock

## 🚀 Cara Download dan Install RestClock

### 📦 **Opsi 1: Install Langsung (Recommended)**

#### **Langkah 1: Jalankan Script Install**
```bash
./install_app.sh
```

#### **Langkah 2: Launch Aplikasi**
- **Via Finder**: Applications > RestClock > RestClock.app
- **Via Terminal**: `open ~/Applications/RestClock/sleptimer.app`

### 📦 **Opsi 2: Buat DMG Installer**

#### **Langkah 1: Buat DMG**
```bash
./create_dmg.sh
```

#### **Langkah 2: Install dari DMG**
1. Double-click `RestClock_v1.0.dmg`
2. Drag `RestClock.app` ke folder Applications
3. Launch dari Applications

### 📦 **Opsi 3: Manual Install**

#### **Langkah 1: Build Aplikasi**
```bash
flutter build macos --release
```

#### **Langkah 2: Copy ke Applications**
```bash
# Copy ke Applications folder
cp -R build/macos/Build/Products/Release/sleptimer.app ~/Applications/RestClock/

# Set permissions
chmod +x ~/Applications/RestClock/sleptimer.app/Contents/MacOS/sleptimer
```

#### **Langkah 3: Launch**
```bash
open ~/Applications/RestClock/sleptimer.app
```

## 🎯 **Fitur RestClock**

### **Timer Mode:**
- Set countdown duration (jam, menit, detik)
- Sleep/shutdown setelah timer selesai
- Perfect untuk: "Sleep dalam 30 menit"

### **Time Mode:**
- Set target time untuk sleep/shutdown
- Auto-detect today/tomorrow
- Perfect untuk: "Sleep jam 11 malam"

### **Menu Bar Integration:**
- Icon muncul di menu bar saat diminimize
- Klik icon untuk show/hide aplikasi
- Menu konteks untuk quick actions

### **Window Management:**
- Ukuran window: 550x450 pixels
- Resizable window
- Clean interface tanpa AppBar

## 📋 **System Requirements**

### **Minimum:**
- macOS 10.14 (Mojave) atau lebih baru
- 50MB free disk space
- 4GB RAM

### **Recommended:**
- macOS 12 (Monterey) atau lebih baru
- 100MB free disk space
- 8GB RAM

## 🔧 **Troubleshooting**

### ❌ **"App can't be opened because it's from an unidentified developer"**

#### **Solusi 1: System Preferences**
1. System Preferences > Security & Privacy
2. Click "Open Anyway" untuk RestClock
3. Confirm installation

#### **Solusi 2: Terminal Command**
```bash
sudo xattr -rd com.apple.quarantine ~/Applications/RestClock/sleptimer.app
```

### ❌ **App tidak muncul di menu bar**
1. Pastikan aplikasi diminimize (bukan close)
2. Periksa area overflow di menu bar
3. Restart aplikasi

### ❌ **Timer tidak berfungsi**
1. Pastikan mode yang benar (Timer/Time)
2. Set waktu yang valid
3. Klik Start button

### ❌ **Sleep/Shutdown tidak berfungsi**
1. Pastikan permission untuk system commands
2. Coba run dengan sudo (untuk shutdown)
3. Check system sleep settings

## 📁 **File Locations**

### **App Bundle:**
```
~/Applications/RestClock/sleptimer.app
```

### **App Contents:**
```
sleptimer.app/
├── Contents/
│   ├── MacOS/sleptimer (executable)
│   ├── Resources/ (assets)
│   └── Info.plist (app info)
```

### **Logs:**
```
~/Library/Logs/sleptimer/
```

## 🎨 **Customization**

### **Icon:**
- App icon: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- Menu bar icon: `assets/icon.png`

### **Window Size:**
- Default: 550x450 pixels
- Minimum: 550x450 pixels
- Resizable: Yes

### **Theme:**
- Dark theme dengan blue accents
- Custom color palette
- Modern UI design

## 🔄 **Updates**

### **Manual Update:**
1. Download versi baru
2. Replace app di Applications
3. Restart aplikasi

### **Auto Update:**
- Belum tersedia
- Check GitHub releases untuk update

## 📞 **Support**

### **Issues:**
- Check troubleshooting section
- Restart aplikasi
- Reinstall jika perlu

### **Features:**
- Timer mode untuk countdown
- Time mode untuk scheduling
- Menu bar integration
- Sleep/Shutdown options

## ✅ **Installation Checklist**

- [ ] App berhasil di-build
- [ ] App terinstall di Applications
- [ ] App dapat di-launch
- [ ] Menu bar icon muncul
- [ ] Timer mode berfungsi
- [ ] Time mode berfungsi
- [ ] Sleep/Shutdown berfungsi
- [ ] Window dapat di-resize
- [ ] App dapat di-close normal

## 🎉 **Enjoy RestClock!**

RestClock siap digunakan untuk mengatur waktu sleep dan shutdown Mac Anda dengan mudah! ⏰🌙
