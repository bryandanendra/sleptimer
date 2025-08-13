# RestClock - Sleep Timer for macOS

## 🌙 **RestClock v1.0**

Aplikasi timer cerdas untuk mengatur waktu sleep dan shutdown Mac Anda dengan mudah dan intuitif.

## ✨ **Fitur Utama**

### ⏰ **Timer Mode**
- Set countdown duration (jam, menit, detik)
- Perfect untuk: "Sleep dalam 30 menit"
- Auto-execute sleep/shutdown setelah timer selesai

### 🕐 **Time Mode**
- Set target time untuk sleep/shutdown
- Auto-detect today/tomorrow
- Perfect untuk: "Sleep jam 11 malam"

### 📱 **Menu Bar Integration**
- Icon muncul di menu bar saat diminimize
- Klik icon untuk show/hide aplikasi
- Menu konteks untuk quick actions

### 🎨 **Modern UI**
- Dark theme dengan blue accents
- Clean interface tanpa AppBar
- Resizable window (550x450 default)
- Icon custom dengan tema bulan dan bintang

## 🚀 **Quick Install**

### **Opsi 1: Install Langsung**
```bash
./install_app.sh
```

### **Opsi 2: DMG Installer**
```bash
./create_dmg.sh
# Kemudian double-click RestClock_v1.0.dmg
```

### **Opsi 3: Manual**
```bash
flutter build macos --release
cp -R build/macos/Build/Products/Release/sleptimer.app ~/Applications/RestClock/
```

## 📋 **System Requirements**

- **macOS**: 10.14 (Mojave) atau lebih baru
- **Disk Space**: 50MB
- **RAM**: 4GB minimum, 8GB recommended

## 🎯 **Cara Menggunakan**

### **Timer Mode (Default)**
1. Set durasi: Hours, Minutes, Seconds
2. Pilih mode: Sleep atau Shutdown
3. Klik Start
4. Timer akan countdown dan execute

### **Time Mode**
1. Klik icon jam di pojok kanan atas
2. Set waktu target: Hour, Minute, Second
3. Pilih mode: Sleep atau Shutdown
4. Klik Start
5. App akan sleep/shutdown pada waktu yang ditentukan

### **Menu Bar**
- Minimize app untuk muncul di menu bar
- Klik icon untuk show/hide
- Klik kanan untuk menu konteks

## 🔧 **Troubleshooting**

### **"App can't be opened because it's from an unidentified developer"**
```bash
sudo xattr -rd com.apple.quarantine ~/Applications/RestClock/sleptimer.app
```

### **App tidak muncul di menu bar**
- Pastikan minimize (bukan close)
- Periksa area overflow di menu bar

### **Sleep/Shutdown tidak berfungsi**
- Check system sleep settings
- Pastikan permission untuk system commands

## 📁 **File Structure**

```
RestClock/
├── lib/main.dart              # Main application code
├── assets/icon.png            # Menu bar icon
├── appicon.png                # Custom app icon
├── macos/Runner/Assets.xcassets/  # App icons
├── install_app.sh             # Installation script
├── create_dmg.sh              # DMG creator script
├── RestClock_v1.0.dmg         # DMG installer (22MB)
└── README.md                  # This file
```

## 🎨 **Design Features**

- **Icon**: Custom app icon (appicon.png)
- **Theme**: Dark mode dengan blue accents
- **Layout**: Compact dan responsive
- **Window**: 550x450 pixels, resizable
- **Menu Bar**: Custom icon dengan menu konteks

## 🔄 **Development**

### **Build**
```bash
flutter build macos --release
```

### **Run**
```bash
flutter run -d macos
```

### **Update Icon**
```bash
./update_tray_icon.sh
```

## 📞 **Support**

- **Issues**: Check troubleshooting section
- **Features**: Timer mode, Time mode, Menu bar integration
- **Updates**: Manual update via DMG

## ✅ **Installation Checklist**

- [x] App berhasil di-build
- [x] App terinstall di Applications
- [x] App dapat di-launch
- [x] Menu bar icon muncul
- [x] Timer mode berfungsi
- [x] Time mode berfungsi
- [x] Sleep/Shutdown berfungsi
- [x] Window dapat di-resize
- [x] App dapat di-close normal

## 🎉 **Download**

- **DMG Installer**: `RestClock_v1.0.dmg` (21MB)
- **Direct Install**: Run `./install_app.sh`
- **Source Code**: Full Flutter project included

## 📄 **License**

This project is open source and available under the MIT License.

---

**RestClock v1.0** - Sleep Timer yang cerdas untuk macOS ⏰🌙
