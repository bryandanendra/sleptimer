# Fitur Aplikasi Sleep Timer

## 🎯 Fitur Utama

### 1. Timer Display
- **Format Digital**: Tampilan timer besar dengan format 00:25:00
- **Font Monospace**: Menggunakan font monospace untuk konsistensi
- **Ukuran Besar**: Font size 72px untuk mudah dibaca

### 2. Time Controls
- **Hours Spinner**: Range 0-23 jam
- **Minutes Spinner**: Range 0-59 menit  
- **Seconds Spinner**: Range 0-59 detik
- **Real-time Update**: Timer otomatis update saat diubah

### 3. Action Modes
- **Sleep Mode**: 
  - Icon: 🛏️ (bedtime)
  - Command: `pmset sleepnow`
  - Fungsi: Menidurkan sistem macOS
  
- **Shutdown Mode**:
  - Icon: ⚡ (power)
  - Command: `sudo shutdown -h now`
  - Fungsi: Mematikan sistem macOS

### 4. Control Buttons
- **Start Button**: 
  - Warna: Hijau
  - Icon: ▶️ (play)
  - Fungsi: Memulai countdown timer
  
- **Stop Button**:
  - Warna: Merah
  - Icon: ⏹️ (stop)
  - Fungsi: Menghentikan timer
  
- **Reset Button**:
  - Warna: Orange
  - Icon: 🔄 (refresh)
  - Fungsi: Reset timer ke nilai awal

## 🎨 UI/UX Features

### 1. Dark Theme
- **Background**: Gradient biru-ungu modern
- **Text**: Putih dengan kontras tinggi
- **Borders**: Transparan dengan opacity rendah

### 2. Rounded Corners
- **Timer Display**: Border radius 20px
- **Buttons**: Border radius 15px
- **Spinners**: Border radius 15px

### 3. Animations
- **Fade In**: Animasi fade saat aplikasi dibuka
- **Smooth Transitions**: Transisi halus antar state
- **Hover Effects**: Efek hover pada buttons

### 4. Responsive Design
- **Safe Area**: Menggunakan SafeArea untuk macOS
- **Flexible Layout**: Layout yang menyesuaikan ukuran window
- **Proper Spacing**: Spacing yang konsisten dan proporsional

## 🔧 Technical Features

### 1. State Management
- **Timer State**: Mengelola status timer (running/stopped)
- **Mode State**: Mengelola mode sleep/shutdown
- **Time State**: Mengelola nilai jam, menit, detik

### 2. System Integration
- **macOS APIs**: Menggunakan macOS native commands
- **Process Execution**: Menjalankan perintah sistem
- **Error Handling**: Handling error dengan user feedback

### 3. Performance
- **Efficient Timer**: Timer yang efisien dengan Timer.periodic
- **Memory Management**: Proper disposal of resources
- **Smooth UI**: UI yang responsif dan smooth

## 🚀 Cara Penggunaan

1. **Set Timer**: Gunakan spinner untuk atur waktu
2. **Pilih Mode**: Pilih Sleep atau Shutdown
3. **Start Timer**: Klik Start untuk mulai countdown
4. **Monitor**: Lihat timer berjalan
5. **Control**: Gunakan Stop/Reset sesuai kebutuhan
6. **Action**: Timer akan eksekusi action otomatis

## ⚠️ Permissions Required

- **System Commands**: Akses ke perintah sistem
- **Sleep Command**: Permission untuk sleep system
- **Shutdown Command**: Permission untuk shutdown system
- **Network Access**: Untuk development dan debugging
