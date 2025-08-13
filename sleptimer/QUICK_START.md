# 🚀 Quick Start Guide - Sleep Timer

## ⚡ Cara Cepat Menjalankan Aplikasi

### 1. **Double Click Launcher** (Paling Mudah)
```
Double click file: launch_app.command
```

### 2. **Terminal Command**
```bash
./run_app.sh
```

### 3. **Manual Launch**
```bash
open build/macos/Build/Products/Release/sleptimer.app
```

## 🎯 Cara Penggunaan Cepat

### **Step 1: Set Timer**
- Gunakan **tombol kiri (←)** untuk mengurangi nilai
- Gunakan **tombol kanan (→)** untuk menambah nilai
- Set Hours (0-23), Minutes (0-59), Seconds (0-59)

### **Step 2: Pilih Mode**
- **Sleep**: Sistem akan tidur setelah timer selesai
- **Shutdown**: Sistem akan mati setelah timer selesai

### **Step 3: Start Timer**
- Klik tombol **Start** (hijau) untuk memulai countdown
- Timer akan berjalan dan menampilkan waktu tersisa

### **Step 4: Control Timer**
- **Stop**: Hentikan timer (tombol merah)
- **Reset**: Reset timer ke nilai awal (tombol orange)

## 🔧 Troubleshooting

### **Aplikasi Tidak Bisa Dibuka**
```bash
flutter clean
flutter build macos
```

### **Permission Error**
- Pastikan Xcode terinstall
- Jalankan: `sudo xcode-select --install`

### **Build Error**
```bash
flutter doctor
flutter pub get
```

## 📱 Fitur Utama

- ✅ **Timer Display**: 00:25:00 format
- ✅ **Horizontal Controls**: Kiri/kanan untuk set waktu
- ✅ **Start Button**: Selalu terlihat
- ✅ **Sleep/Shutdown**: Mode aksi yang berbeda
- ✅ **Dark Theme**: UI yang modern dan elegan
- ✅ **Rounded Corners**: Design yang minimalis

## 🎨 UI Elements

- **Background**: Gradient biru-ungu
- **Timer**: Box hitam transparan dengan border putih
- **Controls**: Tombol biru dengan arrow icons
- **Buttons**: Warna-warni sesuai fungsinya
- **Text**: Putih dengan kontras tinggi

## ⚠️ Catatan Penting

- Timer akan otomatis eksekusi action setelah selesai
- Pastikan data penting sudah disimpan sebelum menggunakan Shutdown mode
- Aplikasi memerlukan permission untuk menjalankan perintah sistem
