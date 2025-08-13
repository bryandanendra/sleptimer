# Window Size Configuration - Sleep Timer

## Konfigurasi Window Terbaru

### ✅ **Ukuran Window yang Diperbarui**
- **Default Size**: 550x450 pixels
- **Minimum Size**: 550x450 pixels (tidak bisa lebih kecil)
- **Resizable**: User dapat mengatur ukuran window
- **Aspect Ratio**: Lebih lebar dari tinggi (landscape orientation)

### 🎯 **Perubahan Layout**
- **AppBar dihilangkan** - Interface lebih bersih tanpa title bar custom
- **Judul di dalam body** - "Sleep Timer" dengan font size 32px
- **Full screen content** - Konten menggunakan seluruh area window
- **SafeArea tetap** - Padding otomatis untuk area yang aman

### 🔧 **Konfigurasi Window Manager**
```dart
await windowManager.setMinimumSize(const Size(550, 450));
await windowManager.setSize(const Size(550, 450));
await windowManager.setResizable(true);
```

### 📱 **Tombol Window Control macOS**
- **Tombol Merah (Close)** - Menyembunyikan ke menu bar
- **Tombol Kuning (Minimize)** - Menyembunyikan ke menu bar
- **Tombol Hijau (Maximize)** - Maximize window
- **Drag corner/edge** - Resize window sesuai keinginan user

## Keuntungan Perubahan

- ✅ **Interface lebih bersih** - Tidak ada AppBar yang mengganggu
- ✅ **Ukuran optimal** - 550x450 ideal untuk timer interface
- ✅ **User control** - User dapat mengatur ukuran sesuai preferensi
- ✅ **Responsive design** - Layout menyesuaikan ukuran window
- ✅ **macOS native** - Menggunakan window control standar

## Layout Baru

```
┌─────────────────────────────────────┐
│ Sleep Timer (32px, bold, white)     │
│                                     │
│        [Timer Display]              │
│                                     │
│  [Hours] [Minutes] [Seconds]        │
│                                     │
│  [Sleep] [Shutdown] [Start] [Stop]  │
│                                     │
└─────────────────────────────────────┘
```

## Responsive Behavior

- **Window diperbesar** - Konten tetap center dan proporsional
- **Window diperkecil** - Konten tetap readable sampai minimum size
- **Aspect ratio** - Layout tetap optimal untuk landscape orientation

## Technical Details

- **Minimum Width**: 550px
- **Minimum Height**: 450px
- **Default Width**: 550px
- **Default Height**: 450px
- **Resizable**: true
- **Title**: "Sleep Timer" (di window title bar)
- **Background**: Dark theme dengan transparansi
