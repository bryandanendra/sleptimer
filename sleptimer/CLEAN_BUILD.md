# Clean Build Guide - RestClock

## 🧹 **Membersihkan Build Folder**

### ✅ **Folder `build` Bisa Dihapus!**

Folder `build` adalah folder temporary yang berisi build artifacts dan bisa dihapus untuk menghemat ruang disk.

## 📊 **Build Folder Analysis**

### **Current Size: 989MB**
```
build/
├── macos/           # macOS build artifacts
└── native_assets/   # Native assets
```

### **What's Inside:**
- Compiled binaries
- Build cache
- Temporary files
- Generated code
- Build artifacts

## 🗑️ **Cara Menghapus Build Folder**

### **Option 1: Flutter Clean (Recommended)**
```bash
flutter clean
```
**Keuntungan:**
- ✅ Membersihkan semua build artifacts
- ✅ Membersihkan cache
- ✅ Aman dan terstruktur
- ✅ Flutter akan rebuild dari awal

### **Option 2: Manual Delete**
```bash
rm -rf build/
```
**Keuntungan:**
- ✅ Langsung menghapus folder
- ✅ Hemat waktu
- ✅ Bebas dari Flutter cache

### **Option 3: Clean All**
```bash
flutter clean
rm -rf .dart_tool/
rm -rf .flutter-plugins-dependencies
```
**Keuntungan:**
- ✅ Clean slate total
- ✅ Menghapus semua cache
- ✅ Fresh start

## 🔄 **Regenerate Build Folder**

### **Build untuk Development:**
```bash
flutter build macos
```

### **Build untuk Production:**
```bash
flutter build macos --release
```

### **Build dengan Clean:**
```bash
flutter clean
flutter pub get
flutter build macos --release
```

## 📈 **Size Comparison**

### **Before Clean:**
- **Build Folder**: 989MB
- **Total Project**: ~1GB

### **After Clean:**
- **Build Folder**: 0MB
- **Total Project**: ~50MB

### **After Rebuild:**
- **Build Folder**: 49MB (app size)
- **Total Project**: ~100MB

## 🎯 **When to Clean Build**

### **✅ Recommended Times:**
- **Disk Space Low**: Ketika ruang disk penuh
- **Build Issues**: Ketika ada masalah build
- **Dependency Changes**: Setelah update dependencies
- **Clean Start**: Ingin fresh build
- **Before Distribution**: Sebelum distribusi

### **⚠️ Not Recommended:**
- **During Development**: Saat sedang develop aktif
- **Frequent Builds**: Jika sering build
- **CI/CD**: Dalam environment CI/CD

## 🚀 **Clean Build Workflow**

### **Complete Clean & Rebuild:**
```bash
# 1. Clean everything
flutter clean

# 2. Remove additional cache
rm -rf .dart_tool/
rm -rf .flutter-plugins-dependencies

# 3. Get dependencies
flutter pub get

# 4. Build for production
flutter build macos --release

# 5. Install app
./install_app.sh

# 6. Create DMG
./create_dmg.sh
```

### **Quick Clean & Rebuild:**
```bash
# 1. Clean build
flutter clean

# 2. Build and install
flutter build macos --release
./install_app.sh
```

## 💾 **Disk Space Savings**

### **Space Saved:**
- **Before**: 989MB
- **After**: 0MB
- **Savings**: 989MB (99% reduction)

### **Regenerated Size:**
- **New Build**: 49MB
- **Net Savings**: 940MB

## 🔍 **Verification**

### **Check Build Folder:**
```bash
# Check if build folder exists
ls -la build/

# Check size
du -sh build/

# Check if app still works
open /Users/a1234/Applications/RestClock/sleptimer.app
```

### **Verify App Functionality:**
- ✅ App launches correctly
- ✅ All features work
- ✅ Icons display properly
- ✅ Menu bar integration works

## 📋 **Best Practices**

### **✅ Do:**
- Clean build sebelum distribusi
- Clean build ketika ada masalah
- Clean build untuk menghemat disk space
- Backup sebelum clean (jika perlu)

### **❌ Don't:**
- Clean build terlalu sering
- Clean build saat development aktif
- Clean build tanpa backup (jika ada custom changes)

## 🎯 **Automated Clean Script**

### **Create Clean Script:**
```bash
#!/bin/bash
echo "🧹 Cleaning RestClock build..."

# Clean Flutter
flutter clean

# Remove additional cache
rm -rf .dart_tool/
rm -rf .flutter-plugins-dependencies

# Get dependencies
flutter pub get

echo "✅ Clean completed!"
echo "🚀 To rebuild: flutter build macos --release"
```

### **Save as `clean_build.sh`:**
```bash
chmod +x clean_build.sh
./clean_build.sh
```

## ✅ **Conclusion**

### **Folder `build` Aman Dihapus:**
- ✅ **Regeneratable**: Bisa dibuat ulang
- ✅ **Temporary**: Hanya cache dan artifacts
- ✅ **Space Saving**: Hemat 989MB disk space
- ✅ **Safe**: Tidak mempengaruhi source code

### **Recommended Action:**
```bash
flutter clean
```

Ini akan membersihkan build folder dengan aman dan terstruktur! 🧹✨
