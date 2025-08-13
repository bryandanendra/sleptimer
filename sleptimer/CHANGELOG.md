# Changelog - Sleep Timer App

## Versi 1.2.0 - Menu Bar Support

### ✨ Fitur Menu Bar macOS:

#### 1. **Menu Bar Integration**
- Icon aplikasi muncul di menu bar macOS
- Klik icon untuk menampilkan/menyembunyikan window
- Right-click untuk menampilkan context menu

#### 2. **Context Menu Lengkap**
- **Show App**: Menampilkan window aplikasi
- **Hide App**: Menyembunyikan window aplikasi
- **Start Timer**: Memulai timer dari menu bar
- **Stop Timer**: Menghentikan timer dari menu bar
- **Quit**: Keluar dari aplikasi

#### 3. **Background Operation**
- Window dapat diminimize ke menu bar
- Close button menyembunyikan ke menu bar (tidak menutup aplikasi)
- Timer tetap berjalan di background
- Aplikasi tetap accessible melalui menu bar

#### 4. **Window Management**
- AppBar dengan minimize dan close buttons
- Window behavior yang sesuai dengan aplikasi macOS native
- Professional user experience

### 🔧 Technical Implementation:

- Added `window_manager: ^0.5.1` dependency
- Added `tray_manager: ^0.5.0` dependency
- Implemented TrayListener interface
- Added window management functionality
- Updated Info.plist dengan LSUIElement support

### 📱 User Experience:

- **Always Accessible**: Aplikasi selalu tersedia di menu bar
- **Background Operation**: Timer berjalan tanpa window terbuka
- **Quick Actions**: Akses cepat ke semua fungsi
- **Clean Desktop**: Tidak mengganggu workspace
- **Professional Feel**: Sesuai dengan aplikasi macOS native

---

## Versi 1.1.0 - UI Improvements

### ✨ Perubahan yang Telah Dibuat:

#### 1. **Button Start Selalu Muncul**
- Start button sekarang selalu terlihat di interface
- Tidak lagi tersembunyi saat timer berjalan
- Layout button yang lebih konsisten

#### 2. **Spinner Control Horizontal (Kanan-Kiri)**
- **Sebelumnya**: Tombol + dan - (atas-bawah)
- **Sekarang**: Tombol arrow kiri dan kanan (horizontal)
- **Tombol Kiri**: Arrow left (←) untuk mengurangi nilai
- **Tombol Kanan**: Arrow right (→) untuk menambah nilai
- **Visual**: Tombol dengan background biru dan rounded corners

#### 3. **Layout Horizontal Sejajar**
- **Sebelumnya**: Angka ditampilkan atas-bawah (dua baris)
- **Sekarang**: Angka dalam satu baris horizontal yang sejajar
- **Container**: Background hitam transparan dengan border radius
- **Alignment**: Semua elemen sejajar sempurna dengan spacing konsisten

#### 4. **New Color Palette**
- **Sebelumnya**: Warna biru-ungu yang cerah
- **Sekarang**: Color palette modern dengan Light Black, Grity Gray, Plect Blue, dan Dath Blue
- **Background**: Gradient yang lebih sophisticated dan profesional
- **UI Elements**: Warna yang konsisten dan kontras optimal

#### 5. **Compact Design & Solid Background**
- **Background**: Dari gradient menjadi solid Light Black
- **Arrow Buttons**: Menghilangkan background box, hanya icon arrow putih
- **Layout**: Ukuran frame dan komponen lebih compact
- **Spacing**: Padding dan margin yang lebih efisien
- **Typography**: Font size yang dioptimalkan untuk compact layout

#### 3. **Improved Button Design**
- Tombol spinner dengan ukuran 40x40 pixel
- Background color yang berbeda untuk tombol aktif/non-aktif
- Border radius 8px untuk tampilan yang lebih modern
- Icon arrow yang jelas dan mudah dipahami

### 🎯 Fitur yang Diperbaiki:

1. **Timer Controls**: 
   - Hours: 0-23 dengan tombol kiri/kanan
   - Minutes: 0-59 dengan tombol kiri/kanan  
   - Seconds: 0-59 dengan tombol kiri/kanan

2. **Button Layout**:
   - Start button selalu visible
   - Stop dan Reset muncul saat timer berjalan
   - Spacing yang konsisten antar button

3. **User Experience**:
   - Kontrol yang lebih intuitif (kiri = kurang, kanan = tambah)
   - Visual feedback yang lebih jelas
   - Interface yang lebih user-friendly

### 🔧 Technical Changes:

- Updated `_buildTimeSpinner` function
- Modified button visibility logic
- Enhanced UI components styling
- Improved button state management

### 📱 Screenshot Changes:

- Spinner controls sekarang menggunakan arrow kiri/kanan
- Start button selalu terlihat
- Layout yang lebih rapi dan konsisten

---

## Versi 1.0.0 - Initial Release

### Fitur Dasar:
- Timer display digital dengan format 00:25:00
- Time controls dengan spinner
- Sleep dan Shutdown modes
- Dark theme dengan gradient background
- Rounded corners design
- macOS native integration
