# 🎨 Color Palette - Sleep Timer App

## 🌈 Color Scheme Baru

Aplikasi Sleep Timer sekarang menggunakan color palette yang lebih modern dan elegan berdasarkan referensi visual yang Anda berikan.

### **Primary Colors:**

#### 1. **Light Black** - `#1a1a1a`
- **Penggunaan**: Background utama, timer display container
- **Opacity**: 0.9 untuk kontras yang optimal
- **Fungsi**: Memberikan dasar gelap yang elegan

#### 2. **Grity (Dark Gray)** - `#2d2d2d`
- **Penggunaan**: Time controls container, tombol non-aktif
- **Opacity**: 0.6-0.7 untuk transparansi yang seimbang
- **Fungsi**: Memberikan kontras medium untuk elemen sekunder

#### 3. **Plect (Dark Blue)** - `#1e3a8a`
- **Penggunaan**: Tombol aktif, border, accent color
- **Opacity**: 0.8 untuk tombol, 0.3-0.5 untuk border
- **Fungsi**: Warna aksen utama yang modern dan profesional

#### 4. **Dath Blue (Darker Blue)** - `#1e40af`
- **Penggunaan**: Gradient background, elemen highlight
- **Opacity**: 1.0 untuk solid color
- **Fungsi**: Memberikan kedalaman dan variasi pada background

## 🎯 Implementasi Color Palette

### **Background Gradient:**
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1a1a1a), // Light Black
    Color(0xFF2d2d2d), // Grity (Dark Gray)
    Color(0xFF1e3a8a), // Plect (Dark Blue)
    Color(0xFF1e40af), // Dath Blue (Darker Blue)
  ],
)
```

### **UI Elements:**

#### **Timer Display Container:**
- **Background**: Light Black (`#1a1a1a`) dengan opacity 0.9
- **Border**: Plect Blue (`#1e3a8a`) dengan opacity 0.5
- **Border Width**: 2px untuk emphasis yang lebih baik

#### **Time Controls Container:**
- **Background**: Grity Gray (`#2d2d2d`) dengan opacity 0.7
- **Border**: Plect Blue (`#1e3a8a`) dengan opacity 0.3

#### **Spinner Control Buttons:**
- **Active State**: Plect Blue (`#1e3a8a`) dengan opacity 0.8
- **Inactive State**: Grity Gray (`#2d2d2d`) dengan opacity 0.6
- **Border Radius**: 8px untuk tampilan modern

#### **Number Display Container:**
- **Background**: Light Black (`#1a1a1a`) dengan opacity 0.9
- **Border Radius**: 8px untuk konsistensi

#### **Mode Buttons (Sleep/Shutdown):**
- **Selected State**: Plect Blue (`#1e3a8a`) dengan opacity 0.8
- **Unselected State**: Grity Gray (`#2d2d2d`) dengan opacity 0.6
- **Border**: Plect Blue untuk selected state

#### **Action Buttons (Start/Stop/Reset):**
- **Background**: Color dengan opacity 0.3 (ditingkatkan dari 0.2)
- **Border**: Solid color untuk emphasis

## 🎨 Design Principles

### **1. Visual Hierarchy:**
- **Primary**: Light Black untuk elemen utama
- **Secondary**: Grity Gray untuk elemen pendukung
- **Accent**: Plect Blue untuk highlight dan aksi
- **Depth**: Dath Blue untuk variasi background

### **2. Contrast & Readability:**
- **High Contrast**: Text putih pada background gelap
- **Medium Contrast**: Border dan elemen sekunder
- **Low Contrast**: Background transparan untuk depth

### **3. Consistency:**
- **Border Radius**: 8px untuk small elements, 15px untuk medium, 20px untuk large
- **Opacity Levels**: 0.3, 0.5, 0.6, 0.7, 0.8, 0.9 untuk variasi yang seimbang
- **Color Usage**: Konsisten di seluruh komponen UI

## 🔧 Color Variables

Untuk kemudahan maintenance, berikut adalah color constants yang bisa digunakan:

```dart
class AppColors {
  static const Color lightBlack = Color(0xFF1a1a1a);
  static const Color grityGray = Color(0xFF2d2d2d);
  static const Color plectBlue = Color(0xFF1e3a8a);
  static const Color dathBlue = Color(0xFF1e40af);
  
  // Opacity variants
  static Color lightBlack90 = lightBlack.withOpacity(0.9);
  static Color grityGray70 = grityGray.withOpacity(0.7);
  static Color plectBlue80 = plectBlue.withOpacity(0.8);
}
```

## 📱 Visual Impact

### **Sebelum (Old Palette):**
- Warna biru-ungu yang lebih cerah
- Kontras yang kurang optimal
- Transparansi yang tidak konsisten

### **Sesudah (New Palette):**
- Warna yang lebih sophisticated dan modern
- Kontras yang optimal untuk readability
- Transparansi yang seimbang dan konsisten
- Visual hierarchy yang lebih jelas

## 🎯 Benefits

1. **Professional Look**: Color palette yang lebih business-oriented
2. **Better Readability**: Kontras yang optimal untuk text dan UI elements
3. **Modern Aesthetics**: Warna yang sesuai dengan trend design modern
4. **Consistent Experience**: Penggunaan warna yang konsisten di seluruh aplikasi
5. **Accessibility**: Kontras yang memenuhi standar accessibility
