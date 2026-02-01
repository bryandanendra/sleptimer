# 📦 RestClock Installation Guide

Three ways to install RestClock on your Mac:

---

## ⚡ Option 1: Automatic Install (Recommended)

**Easiest and fastest way!**

```bash
./install_app.sh
```

This will:
1. Build the release version
2. Copy to /Applications automatically
3. Ready to use!

**Time:** ~2-3 minutes

---

## 🛠️ Option 2: Manual Install

### Step 1: Build Release Version
```bash
flutter build macos --release
```

### Step 2: Copy to Applications
```bash
cp -R build/macos/Build/Products/Release/sleptimer.app /Applications/RestClock.app
```

### Step 3: Launch
Open Spotlight (⌘ + Space) → Type "RestClock" → Enter

---

## 🔧 Option 3: Debug Build (For Development)

**Use this if you want to keep developing:**

```bash
flutter build macos
```

The app will be at: `build/macos/Build/Products/Debug/sleptimer.app`

You can:
- Double-click to run
- Or drag to /Applications

**Note:** Debug builds are larger and slower

---

## 🚀 First Launch

When you first open RestClock:

1. **macOS Gatekeeper Warning**
   - Click "Open" (the app is safe, it's yours!)
   
2. **Permissions**
   - Sleep/Shutdown: Grant permissions if asked
   - Menu Bar: Allow to run in background

3. **Enjoy!**
   - App will appear in menu bar
   - Click to open/close window

---

## 📍 File Locations

### Release Build:
```
build/macos/Build/Products/Release/sleptimer.app
```

### Debug Build:
```
build/macos/Build/Products/Debug/sleptimer.app
```

### Installed App:
```
/Applications/RestClock.app
```

---

## 🗑️ Uninstall

To remove RestClock:

```bash
rm -rf /Applications/RestClock.app
```

Or just drag it to Trash from Applications folder.

---

## 🔄 Update

To update to new version:

```bash
# Pull latest changes (if from git)
git pull

# Run install script again
./install_app.sh
```

The old version will be automatically replaced.

---

## ⚠️ Troubleshooting

### "Command not found: flutter"
Install Flutter first: https://docs.flutter.dev/get-started/install/macos

### "Permission denied"
Make the script executable:
```bash
chmod +x install_app.sh
```

### "App is damaged"
This happens if downloaded from internet. Fix:
```bash
xattr -cr /Applications/RestClock.app
```

### App won't open
Check macOS Security & Privacy:
- System Settings → Privacy & Security
- Click "Open Anyway"

---

## 💡 Pro Tips

**Auto-start on login:**
1. System Settings → Login Items
2. Click "+"
3. Add RestClock
4. App will start automatically!

**Remove from Dock:**
- RestClock is a menu bar app
- No need for Dock icon
- Just look at top menu bar!

---

## ✨ Features

- ⏰ Sleep timer
- 🕐 Time-based scheduler  
- 🌙 Sleep or shutdown Mac
- 📊 System activity history
- 💎 Beautiful glassmorphism UI
- 🔋 Low resource usage

---

## 📝 App Info

- **Name:** RestClock
- **Version:** 1.0
- **Platform:** macOS 10.14+
- **Size:** ~15-20 MB
- **Author:** You!

---

**Enjoy your sleep timer! 😴✨**
