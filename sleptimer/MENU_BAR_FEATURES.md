# 🍎 Menu Bar Features - Sleep Timer App

## 📱 Fitur Menu Bar macOS

Aplikasi Sleep Timer sekarang mendukung menu bar macOS, memungkinkan aplikasi berjalan di background dan dapat diakses melalui menu bar.

### 🎯 **Fitur Menu Bar:**

#### 1. **Menu Bar Icon**
- Icon aplikasi muncul di menu bar macOS
- Klik icon untuk menampilkan/menyembunyikan window
- Right-click untuk menampilkan context menu

#### 2. **Context Menu**
- **Show App**: Menampilkan window aplikasi
- **Hide App**: Menyembunyikan window aplikasi
- **Start Timer**: Memulai timer dari menu bar
- **Stop Timer**: Menghentikan timer dari menu bar
- **Quit**: Keluar dari aplikasi

#### 3. **Window Management**
- Window dapat diminimize ke menu bar
- Close button menyembunyikan ke menu bar (tidak menutup aplikasi)
- Aplikasi tetap berjalan di background

### 🔧 **Technical Implementation:**

#### **Dependencies Added:**
```yaml
dependencies:
  window_manager: ^0.5.1
  tray_manager: ^0.5.0
```

#### **Main Function:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Initialize tray manager
  await trayManager.setIcon('assets/icon.png');
  
  runApp(const SleepTimerApp());
}
```

#### **Tray Initialization:**
```dart
void _initTray() async {
  await trayManager.setIcon('assets/icon.png');
  await trayManager.setToolTip('Sleep Timer');
  await trayManager.setContextMenu(Menu(
    items: [
      MenuItem(key: 'show', label: 'Show App'),
      MenuItem(key: 'hide', label: 'Hide App'),
      MenuItem.separator(),
      MenuItem(key: 'start', label: 'Start Timer'),
      MenuItem(key: 'stop', label: 'Stop Timer'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Quit'),
    ],
  ));
}
```

#### **Tray Event Handlers:**
```dart
@override
void onTrayIconMouseDown() {
  windowManager.show();
  windowManager.focus();
}

@override
void onTrayMenuItemClick(MenuItem menuItem) {
  switch (menuItem.key) {
    case 'show':
      windowManager.show();
      windowManager.focus();
      break;
    case 'hide':
      windowManager.hide();
      break;
    case 'start':
      if (!_isRunning) _startTimer();
      break;
    case 'stop':
      if (_isRunning) _stopTimer();
      break;
    case 'quit':
      exit(0);
      break;
  }
}
```

### 🎨 **UI Changes:**

#### **AppBar Added:**
```dart
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.minimize, color: Colors.white),
    onPressed: () => windowManager.hide(),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => windowManager.hide(),
    ),
  ],
),
```

#### **Info.plist Configuration:**
```xml
<key>LSUIElement</key>
<true/>
```

### 📱 **User Experience:**

#### **Menu Bar Access:**
1. **Klik Icon**: Menampilkan/menyembunyikan window
2. **Right-click**: Menampilkan context menu
3. **Context Menu Options**:
   - Show/Hide window
   - Start/Stop timer
   - Quit aplikasi

#### **Window Behavior:**
- **Minimize**: Window hilang, aplikasi tetap di menu bar
- **Close**: Window hilang, aplikasi tetap di menu bar
- **Quit**: Aplikasi benar-benar keluar

### 🔍 **Features:**

#### **Background Operation:**
- Timer tetap berjalan di background
- Notifikasi saat timer selesai
- Menu bar tetap accessible

#### **Quick Access:**
- Start/Stop timer tanpa membuka window
- Check timer status dari menu bar
- Quick quit dari menu bar

### 📋 **Setup Requirements:**

#### **Icon File:**
- Place icon file di `assets/icon.png`
- Recommended size: 16x16 atau 32x32 pixels
- Format: PNG dengan transparansi

#### **Assets Configuration:**
```yaml
flutter:
  assets:
    - assets/
```

### 🚀 **Usage Instructions:**

#### **First Time Setup:**
1. Build aplikasi: `flutter build macos`
2. Jalankan aplikasi
3. Icon akan muncul di menu bar
4. Right-click untuk akses menu

#### **Daily Usage:**
1. **Start Timer**: Klik icon menu bar → Start Timer
2. **Check Status**: Icon menu bar menunjukkan status
3. **Quick Access**: Right-click untuk semua fungsi
4. **Background**: Aplikasi tetap berjalan saat window ditutup

### 🎯 **Benefits:**

1. **Always Accessible**: Aplikasi selalu tersedia di menu bar
2. **Background Operation**: Timer berjalan tanpa window terbuka
3. **Quick Actions**: Akses cepat ke semua fungsi
4. **Clean Desktop**: Tidak mengganggu workspace
5. **Professional Feel**: Sesuai dengan aplikasi macOS native

### 🔧 **Troubleshooting:**

#### **Icon Not Appearing:**
- Pastikan file `assets/icon.png` ada
- Check `pubspec.yaml` assets configuration
- Rebuild aplikasi: `flutter clean && flutter build macos`

#### **Menu Not Working:**
- Check tray manager initialization
- Verify event handlers
- Check console untuk error messages

#### **Window Not Hiding:**
- Verify window manager setup
- Check Info.plist configuration
- Ensure proper event handling

Aplikasi Sleep Timer sekarang memiliki fitur menu bar yang lengkap untuk pengalaman macOS yang optimal! 🎉
