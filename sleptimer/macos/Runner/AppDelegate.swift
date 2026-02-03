import Cocoa
import FlutterMacOS
import QuartzCore

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let window = mainFlutterWindow, 
       let controller = window.contentViewController as? FlutterViewController {
         let registrar = controller.registrar(forPlugin: "MenuBarManager")
         MenuBarManager.shared.setup(with: registrar)
    }
    super.applicationDidFinishLaunching(aNotification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

class MenuBarManager: NSObject {
    static let shared = MenuBarManager()
    private var statusItem: NSStatusItem!
    private var islandView: IslandView!
    private var channel: FlutterMethodChannel?
    
    // Config
    private let compactWidth: CGFloat = 28.0 // Standard MenuBar Item width
    private let height: CGFloat = 22.0
    
    // Assets
    private var idleIcon: NSImage?
    
    override init() {
        super.init()
        // Load custom icon from Assets
        if let image = NSImage(named: "MenuBarIcon") {
            image.isTemplate = true // Adapt to system theme (White on Dark, Black on Light)
            // Resize to standard menu bar size (usually 18x18 or 22x22 max)
            let newSize = NSSize(width: 18, height: 18)
            let resizedImage = NSImage(size: newSize)
            
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize),
                       from: NSRect(origin: .zero, size: image.size),
                       operation: .copy,
                       fraction: 1.0)
            resizedImage.unlockFocus()
            
            resizedImage.isTemplate = true // Ensure resized copy is also template
            idleIcon = resizedImage
        } else {
            // Fallback
            if #available(macOS 11.0, *) {
                idleIcon = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            } else {
                idleIcon = NSImage(named: NSImage.touchBarAlarmTemplateName)
            }
            idleIcon?.isTemplate = true
        }
        setupStatusItem()
    }
    
    func setup(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.bryandanendra.sleptimer/island", binaryMessenger: registrar.messenger)
        channel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Initial Idle State: Show standard Icon
        if let button = statusItem.button {
            button.image = idleIcon
            button.imagePosition = .imageOnly
            button.isBordered = false 
            
            // Handle Clicks
            button.target = self
            button.action = #selector(handleIconClick)
            
            // Enable right-click (context menu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            // Critical Fix: Remove the rectangular shadow box
            button.window?.hasShadow = false 
            
            // Ensure transparency
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.clear.cgColor
        }
        
        islandView = IslandView(frame: NSRect(x: 0, y: 0, width: compactWidth, height: height))
        islandView.isHidden = true 
        
        islandView.onContextMenu = { [weak self] in self?.showContextMenu() }
        islandView.onToggle = { [weak self] in self?.toggleWindow() }
        
        if let button = statusItem.button {
            button.addSubview(islandView)
        }
    }
    
    @objc private func handleIconClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        // Right-click: Show context menu
        if event.type == .rightMouseUp {
            showContextMenu()
            return
        }
        
        // Left-click: Only toggle if island is hidden (Standard mode)
        // If island is active, IslandView's mouseDown handles it
        if islandView.isHidden {
            toggleWindow()
        }
    }
    
    private func toggleWindow() {
        NSApp.activate(ignoringOtherApps: true)
        
        guard let window = NSApp.windows.first else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.level = .floating // Temporarily bring to front if needed
            window.level = .normal
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startTimer":
            DispatchQueue.main.async {
                self.startIslandMode()
            }
        case "stopTimer":
            DispatchQueue.main.async {
                self.stopIslandMode()
            }
        case "updateTimer":
            if let timeString = call.arguments as? String {
                DispatchQueue.main.async {
                    self.islandView.updateText(timeString)
                    if !self.islandView.isHidden {
                         self.animateLayout(isUpdate: true)
                    }
                }
            }
        default:
            result(FlutterMethodNotImplemented)
            return
        }
        result(nil)
    }
    
    private func startIslandMode() {
        // Switch from Icon to Island
        statusItem.button?.image = nil
        
        // Setup initial state - start compact
        islandView.frame = NSRect(x: 0, y: 0, width: compactWidth, height: height)
        islandView.isHidden = false
        islandView.alphaValue = 1
        islandView.currentMode = .active
        
        // Animate expansion from center
        animateLayout(isUpdate: false)
    }
    
    private func stopIslandMode() {
        // Simple fade + shrink animation
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            
            // Fade and shrink simultaneously
            self.islandView.animator().alphaValue = 0
            self.islandView.animator().frame.size.width = self.compactWidth
            
        }) {
            self.islandView.isHidden = true
            
            // Restore Idle State
            self.statusItem.button?.image = self.idleIcon
            self.islandView.currentMode = .idle
            
            // Reset System Window Size
            self.statusItem.length = NSStatusItem.variableLength
            self.islandView.frame = NSRect(x: 0, y: 0, width: 0, height: self.height)
            
            // Restore alpha for next usage
            self.islandView.alphaValue = 1
            
            // Reset content positions
            self.islandView.resetForIdle()
        }
    }
    
    private func animateLayout(isUpdate: Bool) {
        let desiredWidth = islandView.calculateDesiredWidth()
        animateToState(width: desiredWidth, isUpdate: isUpdate)
    }
    
    private func animateToState(width: CGFloat, isUpdate: Bool, completion: (() -> Void)? = nil) {
        // Set status bar length immediately
        self.statusItem.length = width
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            
            // Animate View Frame - expand from center
            self.islandView.animator().frame = NSRect(x: 0, y: 0, width: width, height: self.height)
            
            // Content Animation
            self.islandView.animateContents(width: width, isUpdate: isUpdate)
            
        }) {
            completion?()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        let showItem = NSMenuItem(title: "Show RestClock", action: #selector(showApp), keyEquivalent: "o")
        showItem.target = self
        menu.addItem(showItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func showApp() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - IslandView
class IslandView: NSView {
    enum Mode { case idle, active }
    
    var onContextMenu: (() -> Void)?
    var onToggle: (() -> Void)?
    
    var currentMode: Mode = .idle
    
    private let timeLabel = NSTextField(labelWithString: "")
    private let iconDot = NSView() // The orange dot
    private let backgroundLayer = CALayer()
    private let borderLayer = CALayer()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = true
        layer?.cornerRadius = 11
        if #available(macOS 10.15, *) {
            layer?.cornerCurve = .continuous
        }
        layer?.drawsAsynchronously = true // Performance optimization
        
        // Background Pill - fully opaque, masked by parent
        backgroundLayer.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor
        backgroundLayer.cornerRadius = 11
        backgroundLayer.masksToBounds = true
        if #available(macOS 10.15, *) {
            backgroundLayer.cornerCurve = .continuous
        }
        backgroundLayer.actions = ["frame": NSNull(), "bounds": NSNull(), "position": NSNull()]
        layer?.addSublayer(backgroundLayer)
        
        // Border (Glow)
        borderLayer.borderWidth = 0.0 // Border Disabled
        borderLayer.borderColor = NSColor.clear.cgColor
        borderLayer.cornerRadius = 11
        if #available(macOS 10.15, *) {
            borderLayer.cornerCurve = .continuous
        }
        borderLayer.opacity = 0
        borderLayer.actions = ["frame": NSNull(), "bounds": NSNull()]
        layer?.addSublayer(borderLayer)
        
        // Icon Dot (Orange Indicator)
        iconDot.wantsLayer = true
        iconDot.layer?.backgroundColor = NSColor(srgbRed: 1.0, green: 0.55, blue: 0.0, alpha: 1.0).cgColor
        iconDot.layer?.cornerRadius = 3
        addSubview(iconDot)
        
        // Timer Text
        timeLabel.textColor = .white
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        timeLabel.alignment = .right 
        timeLabel.drawsBackground = false
        timeLabel.isBordered = false
        timeLabel.isEditable = false
        timeLabel.isSelectable = false
        addSubview(timeLabel)
    }

    func calculateDesiredWidth() -> CGFloat {
        let textWidth = timeLabel.attributedStringValue.size().width
        return textWidth + 14 + 24
    }
    
    func updateText(_ text: String) {
        timeLabel.stringValue = text
    }
    
    // Resets layers to (0,0) for the compact state after animation
    func resetLayersForCompact() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = bounds
        borderLayer.frame = bounds
        CATransaction.commit()
    }
    
    // SPECIALIZED Close Animation
    func animateClose(compactWidth: CGFloat, completion: @escaping () -> Void) {
        // We do NOT resize self.frame here. We keep the wide frame.
        // We animate the Background Layer to shrink towards the RIGHT.
        // Current Width: 100 via bounds.width
        // Final Pill: 28px width, aligned Right. -> x = 100 - 28 = 72.
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.45
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 1.0, 0.25, 1.0)
            
            // 1. Text Collapse (NSView animation)
            let centerY = bounds.height / 2
            let targetDotX = bounds.width - 14 // Padding
            let targetTextFrame = CGRect(x: targetDotX, y: centerY - 8, width: 0, height: 16)
            
            timeLabel.animator().frame = targetTextFrame
            timeLabel.animator().alphaValue = 0
            
            // 2. Layer Animation (Core Animation)
            let shrinkTargetX = bounds.width - compactWidth
            let targetLayerFrame = CGRect(x: shrinkTargetX, y: 0, width: compactWidth, height: bounds.height)
            
            // Explicitly animate Layer Frames
            let frameAnim = CABasicAnimation(keyPath: "frame")
            frameAnim.fromValue = backgroundLayer.frame
            frameAnim.toValue = targetLayerFrame
            frameAnim.duration = 0.45
            frameAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 1.0, 0.25, 1.0)
            
            // Apply to background
            backgroundLayer.frame = targetLayerFrame // Set final value
            backgroundLayer.add(frameAnim, forKey: "frame")
            
            // Apply to border
            borderLayer.frame = targetLayerFrame
            borderLayer.add(frameAnim, forKey: "frame")
            
            // Fade out border
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.fromValue = borderLayer.presentation()?.opacity ?? borderLayer.opacity
            fadeAnim.toValue = 0
            fadeAnim.duration = 0.3
            borderLayer.opacity = 0
            borderLayer.add(fadeAnim, forKey: "opacity")
            
        }) {
            completion()
        }
    }
    
    override func layout() {
        super.layout()
        if NSAnimationContext.current.duration > 0 { return }
        
        backgroundLayer.frame = bounds
        borderLayer.frame = bounds
        
        let dotSize: CGFloat = 6
        let rightPadding: CGFloat = 14
        let centerY = bounds.height / 2
        
        if currentMode == .idle {
             // Idle: dot centered
             let centerX = (bounds.width - dotSize) / 2
             iconDot.frame = CGRect(x: centerX, y: centerY - 3, width: dotSize, height: dotSize)
             timeLabel.alphaValue = 0
             borderLayer.opacity = 0
        } else {
             // Active: Dot on LEFT, text on RIGHT (expand from center outward)
             let leftPadding: CGFloat = 10
             iconDot.frame = CGRect(x: leftPadding, y: centerY - 3, width: dotSize, height: dotSize)
             
             let textWidth = timeLabel.attributedStringValue.size().width
             let textX = leftPadding + dotSize + 6
             timeLabel.frame = CGRect(x: textX, y: centerY - 8, width: textWidth + 4, height: 16)
             
             timeLabel.alphaValue = 1
             borderLayer.opacity = 1
        }
    }
    
    func animateContents(width: CGFloat, isUpdate: Bool) {
        let centerY = bounds.height / 2
        let dotSize: CGFloat = 6
        let leftPadding: CGFloat = 10
        
        // Dot on LEFT side
        let targetDotFrame = CGRect(x: leftPadding, y: centerY - 3, width: dotSize, height: dotSize)
        
        // Text appears to the RIGHT of dot
        let textWidth = timeLabel.attributedStringValue.size().width
        let targetTextX = leftPadding + dotSize + 6
        let targetTextFrame = CGRect(x: targetTextX, y: centerY - 8, width: textWidth + 4, height: 16)
        
        // Use inherited timing from parent NSAnimationContext
        iconDot.animator().frame = targetDotFrame
        timeLabel.animator().frame = targetTextFrame
        timeLabel.animator().alphaValue = 1
        
        // Update layer frames immediately
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: width, height: 22)
        borderLayer.frame = CGRect(x: 0, y: 0, width: width, height: 22)
        borderLayer.opacity = 1
        CATransaction.commit()
    }
    
    // Reset view for idle state (after animation completes)
    func resetForIdle() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let dotSize: CGFloat = 6
        let centerY = bounds.height / 2
        
        // Dot centered
        let centerX = (bounds.width - dotSize) / 2
        iconDot.frame = CGRect(x: centerX, y: centerY - 3, width: dotSize, height: dotSize)
        timeLabel.alphaValue = 0
        timeLabel.frame = .zero
        
        backgroundLayer.frame = bounds
        borderLayer.frame = bounds
        borderLayer.opacity = 0
        
        CATransaction.commit()
    }
    
    override func mouseDown(with event: NSEvent) {
        onToggle?()
    }
    
    override func rightMouseDown(with event: NSEvent) {
        onContextMenu?()
    }
}
