# 🖼️ Window Size Configuration - Sleep Timer App

## 📍 **Lokasi untuk Mengatur Ukuran Window:**

### **1. File Utama: `macos/Runner/Base.lproj/MainMenu.xib`**

File ini berisi konfigurasi window utama aplikasi. Berikut adalah bagian yang bisa Anda ubah:

```xml
<!-- Baris 332-340 dalam MainMenu.xib -->
<window title="APP_NAME" allowsToolTipsWhenApplicationIsInactive="NO" 
        autorecalculatesKeyViewLoop="NO" releasedWhenClosed="NO" 
        animationBehavior="default" id="QvC-M9-y7g" 
        customClass="MainFlutterWindow" customModule="Runner" 
        customModuleProvider="target">
    
    <!-- Window Style -->
    <windowStyleMask key="styleMask" titled="YES" closable="YES" 
                     miniaturizable="YES" resizable="YES"/>
    
    <!-- Window Size dan Position -->
    <rect key="contentRect" x="335" y="390" width="800" height="600"/>
    <rect key="screenRect" x="0.0" y="0.0" width="2560" height="1577"/>
    
    <!-- Content View -->
    <view key="contentView" wantsLayer="YES" id="EiT-Mj-1SZ">
        <rect key="frame" x="0.0" y="0.0" width="800" height="600"/>
        <autoresizingMask key="autoresizingMask"/>
    </view>
</window>
```

## 🎯 **Parameter yang Bisa Diubah:**

### **1. Window Size (contentRect):**
```xml
<rect key="contentRect" x="335" y="390" width="800" height="600"/>
```
- **width="800"**: Lebar window dalam pixel
- **height="600"**: Tinggi window dalam pixel
- **x="335"**: Posisi horizontal window dari kiri
- **y="390"**: Posisi vertikal window dari atas

### **2. Content View Size (frame):**
```xml
<rect key="frame" x="0.0" y="0.0" width="800" height="600"/>
```
- **width="800"**: Lebar content area
- **height="600"**: Tinggi content area

### **3. Window Style (styleMask):**
```xml
<windowStyleMask key="styleMask" titled="YES" closable="YES" 
                 miniaturizable="YES" resizable="YES"/>
```
- **titled="YES"**: Menampilkan title bar
- **closable="YES"**: Tombol close (merah)
- **miniaturizable="YES"**: Tombol minimize (kuning)
- **resizable="YES"**: Window bisa di-resize

## 🔧 **Cara Mengubah Ukuran Window:**

### **Untuk Window yang Lebih Kecil:**
```xml
<!-- Ukuran compact untuk Sleep Timer -->
<rect key="contentRect" x="400" y="300" width="450" height="350"/>
<rect key="frame" x="0.0" y="0.0" width="450" height="350"/>
```

### **Untuk Window yang Lebih Besar:**
```xml
<!-- Ukuran besar -->
<rect key="contentRect" x="200" y="200" width="1000" height="800"/>
<rect key="frame" x="0.0" y="0.0" width="1000" height="800"/>
```

### **Untuk Window Fixed Size (Tidak Bisa Di-resize):**
```xml
<windowStyleMask key="styleMask" titled="YES" closable="YES" 
                 miniaturizable="YES" resizable="NO"/>
```

## 📱 **Rekomendasi Ukuran untuk Sleep Timer:**

### **Compact Size (Recommended):**
```xml
<rect key="contentRect" x="400" y="300" width="550" height="450"/>
<rect key="frame" x="0.0" y="0.0" width="550" height="450"/>
```

### **Medium Size:**
```xml
<rect key="contentRect" x="350" y="250" width="550" height="450"/>
<rect key="frame" x="0.0" y="0.0" width="550" height="450"/>
```

### **Large Size:**
```xml
<rect key="contentRect" x="300" y="200" width="650" height="550"/>
<rect key="frame" x="0.0" y="0.0" width="650" height="550"/>
```

## 🎯 **Langkah-langkah Mengubah Ukuran:**

### **1. Buka File MainMenu.xib:**
```bash
open macos/Runner/Base.lproj/MainMenu.xib
```

### **2. Cari Bagian Window Configuration:**
- Cari tag `<window>` dengan `id="QvC-M9-y7g"`
- Ubah nilai `width` dan `height` pada `contentRect` dan `frame`

### **3. Build Ulang Aplikasi:**
```bash
flutter clean
flutter build macos
```

### **4. Test Aplikasi:**
```bash
open build/macos/Build/Products/Release/sleptimer.app
```

## 🔍 **Tips Pengaturan Window:**

### **1. Responsive Design:**
- Pastikan content aplikasi tetap terlihat baik di ukuran window yang berbeda
- Gunakan `autoresizingMask` untuk layout yang fleksibel

### **2. Optimal Size:**
- Untuk Sleep Timer, ukuran 550x450 pixel sudah optimal
- Tidak terlalu besar sehingga tidak mengganggu aplikasi lain
- Tidak terlalu kecil sehingga semua elemen tetap mudah diakses

### **3. Position:**
- `x` dan `y` menentukan posisi window saat pertama kali dibuka
- Gunakan nilai yang menempatkan window di tengah layar

### **4. Screen Resolution:**
- `screenRect` menunjukkan resolusi layar
- Sesuaikan posisi window dengan resolusi layar pengguna

## 📋 **Testing Checklist:**

- [ ] Window size sesuai dengan kebutuhan
- [ ] Content tetap terlihat dengan baik
- [ ] Window position optimal
- [ ] Resizable behavior sesuai keinginan
- [ ] Window style (title bar, buttons) berfungsi
- [ ] Aplikasi responsive pada ukuran window yang berbeda

## 🎨 **Best Practices:**

1. **Consistent Sizing**: Gunakan ukuran yang konsisten dengan aplikasi serupa
2. **User Experience**: Pastikan semua elemen UI tetap mudah diakses
3. **Performance**: Ukuran window yang optimal untuk performa yang baik
4. **Accessibility**: Pertimbangkan kebutuhan pengguna dengan keterbatasan visual
