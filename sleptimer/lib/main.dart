import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Configure window settings
  await windowManager.setMinimumSize(const Size(550, 500));
  await windowManager.setSize(const Size(550, 500));
  await windowManager.setTitle('RestClock');
  await windowManager.setResizable(true);
  
  // Initialize tray manager
  try {
    await trayManager.setIcon('assets/icon.png');
  } catch (e) {
    print('Failed to set tray icon in main: $e');
    // Continue without custom icon
  }
  
  runApp(const SleepTimerApp());
}

class SleepTimerApp extends StatelessWidget {
  const SleepTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const SleepTimerHome(),
    );
  }
}

class SleepTimerHome extends StatefulWidget {
  const SleepTimerHome({super.key});

  @override
  State<SleepTimerHome> createState() => _SleepTimerHomeState();
}

class _SleepTimerHomeState extends State<SleepTimerHome>
    with TickerProviderStateMixin, TrayListener, WidgetsBindingObserver {
  int _hours = 0;
  int _minutes = 25;
  int _seconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isSleepMode = true;
  bool _isTimeMode = false; // Mode waktu jam
  Timer? _timer;
  Timer? _logTimer; // Timer untuk update log otomatis
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mac system log history
  List<Map<String, String>> _historyEvents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _calculateTotalSeconds();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Initialize tray manager
    trayManager.addListener(this);
    _initTray();
    
    // Configure window behavior for macOS
    _configureWindow();
    
    // Listen for window events
    _setupWindowListeners();
    
    // Load Mac system logs (last 3 activities)
    _loadMacSystemLogs();
    
    // Auto refresh logs every 60 seconds
    _logTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _loadMacSystemLogs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _logTimer?.cancel();
    _animationController.dispose();
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh logs when app comes to foreground -> likely after wake
      _loadMacSystemLogs();
    }
  }

  // Initialize tray
  void _initTray() async {
    try {
      // Try to set custom icon, fallback to default if fails
      try {
        await trayManager.setIcon('assets/icon.png');
      } catch (e) {
        print('Failed to set custom icon, using default: $e');
        // Don't set icon, let it use default
      }
      
      await trayManager.setToolTip('RestClock');
      await trayManager.setContextMenu(Menu(
        items: [
          MenuItem(
            key: 'show',
            label: 'Show App',
          ),
          MenuItem(
            key: 'hide',
            label: 'Hide App',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'start',
            label: 'Start Timer',
          ),
          MenuItem(
            key: 'stop',
            label: 'Stop Timer',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'quit',
            label: 'Quit App',
          ),
        ],
      ));
    } catch (e) {
      print('Error initializing tray: $e');
    }
  }

  // Configure window behavior for macOS
  void _configureWindow() async {
    try {
      // Set window to not show in dock when minimized
      await windowManager.setSkipTaskbar(true);
      await windowManager.setAlwaysOnTop(false);
    } catch (e) {
      print('Error configuring window: $e');
    }
  }

  // Setup window event listeners
  void _setupWindowListeners() async {
    try {
      // Allow window to close normally
      await windowManager.setPreventClose(false);
    } catch (e) {
      print('Error setting up window listeners: $e');
    }
  }

  void _calculateTotalSeconds() {
    if (_isTimeMode) {
      // Hitung waktu target untuk sleep/shutdown
      final now = DateTime.now();
      final targetTime = DateTime(now.year, now.month, now.day, _hours, _minutes, _seconds);
      
      // Jika waktu target sudah lewat hari ini, set untuk besok
      if (targetTime.isBefore(now)) {
        final tomorrow = now.add(const Duration(days: 1));
        final targetTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, _hours, _minutes, _seconds);
        _totalSeconds = targetTomorrow.difference(now).inSeconds;
      } else {
        _totalSeconds = targetTime.difference(now).inSeconds;
      }
    } else {
      // Mode timer biasa
      _totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    }
  }

  void _startTimer() {
    if (_totalSeconds <= 0) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_totalSeconds > 0) {
          _totalSeconds--;
          _updateTimeDisplay();
        } else {
          _timer?.cancel();
          _isRunning = false;
          _executeAction();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _calculateTotalSeconds();
    });
  }

  void _toggleTimeMode() {
    setState(() {
      _isTimeMode = !_isTimeMode;
      if (_isTimeMode) {
        // Set waktu saat ini saat beralih ke mode waktu
        final now = DateTime.now();
        _hours = now.hour;
        _minutes = now.minute;
        _seconds = 0;
      } else {
        // Reset ke timer default saat beralih ke mode timer
        _hours = 0;
        _minutes = 25;
        _seconds = 0;
      }
      _calculateTotalSeconds();
    });
  }

  void _updateTimeDisplay() {
    _hours = _totalSeconds ~/ 3600;
    _minutes = (_totalSeconds % 3600) ~/ 60;
    _seconds = _totalSeconds % 60;
  }

  void _executeAction() async {
    try {
      if (_isSleepMode) {
        await Process.run('pmset', ['sleepnow']);
      } else {
        // Menggunakan AppleScript untuk shutdown tanpa sudo (aman untuk GUI app)
        await Process.run('osascript', ['-e', 'tell application "System Events" to shut down']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(int hours, int minutes, int seconds) {
    if (_isTimeMode) {
      // Format waktu untuk mode jam
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Format timer biasa
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _getTargetTimeString() {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, _hours, _minutes, _seconds);
    
    if (targetTime.isBefore(now)) {
      final tomorrow = now.add(const Duration(days: 1));
      final targetTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, _hours, _minutes, _seconds);
      return '${targetTomorrow.hour.toString().padLeft(2, '0')}:${targetTomorrow.minute.toString().padLeft(2, '0')} (Tomorrow)';
    } else {
      return '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')} (Today)';
    }
  }

  // Read Mac system logs for last 3 activities
  Future<void> _loadMacSystemLogs() async {
    try {
      // Run pmset -g log to get sleep/wake history
      // Run pmset -g log to get sleep/wake history
      // Filter for relevant events first using grep, then take last 100 relevant lines
      final result = await Process.run('bash', ['-c', 'pmset -g log | grep -E "Sleep|Wake|Shutdown|Start" | tail -n 1000']);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final events = _parseSleepWakeEvents(output);
        
        if (mounted) { // Always update, events might be empty or changed
          setState(() {
            // Store events for scrollable list display
            _historyEvents = events;
          });
        }
      }
    } catch (e) {
      print('Error reading system logs: $e');
    }
  }
  
  List<Map<String, String>> _parseSleepWakeEvents(String logOutput) {
    final events = <Map<String, String>>[];
    final lines = logOutput.split('\n');
    
    for (var line in lines) {
      try {
        // More specific patterns for actual sleep/wake events
        String eventType = '';
        
        // Look for specific pmset log patterns
        // Sleep: only system sleep, not display sleep
        if (line.contains('Entering Sleep state') ||
            (line.contains('Sleep') && line.contains('due to') && !line.contains('Display'))) {
          eventType = 'Sleep';
        } 
        // Wake: actual system wake
        else if (line.contains('Wake from Normal Sleep') ||
                 line.contains('WakeFromNormalSleep') ||
                 (line.contains('Wake') && !line.contains('Display') && !line.contains('DarkWake'))) {
          eventType = 'Wake';
        } 
        // Shutdown
        else if (line.contains('Shutdown cause:')) {
          eventType = 'Shutdown';
        } 
        // Boot
        else if (line.contains('Boot') && line.contains('args:')) {
          eventType = 'Boot';
        }
        
        if (eventType.isNotEmpty) {
          // Try to extract time from log line
          // pmset log format: YYYY-MM-DD HH:MM:SS
          final timeMatch = RegExp(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})').firstMatch(line);
          
          if (timeMatch != null) {
            final dateStr = timeMatch.group(1)!;
            final timeStr = timeMatch.group(2)!;
            
            try {
              final dateTime = DateTime.parse('$dateStr $timeStr');
              final now = DateTime.now();
              
              String formattedTime;
              if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
                formattedTime = 'Today, ${DateFormat('h:mm a').format(dateTime)}';
              } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
                formattedTime = 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
              } else {
                formattedTime = DateFormat('MMM d, h:mm a').format(dateTime);
              }
              
              events.add({
                'type': eventType,
                'time': formattedTime,
                'timestamp': dateTime.millisecondsSinceEpoch.toString(),
              });
            } catch (e) {
              // Skip if can't parse date
            }
          }
        }
      } catch (e) {
        // Skip malformed lines
      }
    }
    
    // Sort by timestamp (newest first) and remove duplicates
    events.sort((a, b) => int.parse(b['timestamp']!).compareTo(int.parse(a['timestamp']!)));
    
    // Remove duplicate events (same type within 1 second)
    final uniqueEvents = <Map<String, String>>[];
    int? lastTimestamp;
    String? lastType;
    
    for (var event in events) {
      final timestamp = int.parse(event['timestamp']!);
      final type = event['type']!;
      
      // Filter logic:
      // 1. Always keep if it's the first item processed (First = Newest).
      // 2. Always keep if the Type is different from the last one (e.g. Sleep -> Wake).
      // 3. If Type is SAME, only keep if the time gap is huge (> 2 minutes).
      //    This handles "Kernel Wake" then "User Wake" appearing within seconds -> we keep only the Newest one.
      if (lastTimestamp == null || 
          type != lastType ||
          (timestamp - lastTimestamp).abs() > 90000) { // 90 seconds threshold
        uniqueEvents.add(event);
        lastTimestamp = timestamp;
        lastType = type;
      }
    }
    
    return uniqueEvents;
  }

  // Tray listener methods
  @override
  void onTrayIconMouseDown() async {
    // Show window when tray icon is clicked
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Right click shows context menu
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'hide':
        await windowManager.hide();
        break;
      case 'start':
        if (!_isRunning) {
          _startTimer();
        }
        break;
      case 'stop':
        if (_isRunning) {
          _stopTimer();
        }
        break;
      case 'quit':
        exit(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Modern gradient background (dark base)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF242424), // Deep gray
              Color(0xFF000000), // Pure black
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Top Content Group
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header dengan title dan toggle button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'RestClock',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          // Toggle button di pojok kanan
                          MouseRegion(
                            cursor: _isRunning ? SystemMouseCursors.basic : SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _isRunning ? null : _toggleTimeMode,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  // Glass effect for toggle button
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isRunning 
                                      ? [
                                          Colors.white.withOpacity(0.02),
                                          Colors.white.withOpacity(0.01),
                                        ]
                                      : (_isTimeMode 
                                        ? [
                                            Color(0xFF1e3a8a).withOpacity(0.5),
                                            Color(0xFF0f1e42).withOpacity(0.3),
                                          ]
                                        : [
                                            Colors.white.withOpacity(0.05),
                                            Colors.white.withOpacity(0.02),
                                          ]),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isRunning
                                      ? Colors.white.withOpacity(0.05)
                                      : (_isTimeMode 
                                        ? Color(0xFF3b82f6).withOpacity(0.5)
                                        : Colors.white.withOpacity(0.1)),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _isTimeMode ? Icons.access_time : Icons.timer,
                                  color: _isRunning 
                                    ? Colors.white.withOpacity(0.3)
                                    : (_isTimeMode ? Colors.white : Colors.white70),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Timer Display dengan input manual - Glassmorphism
                      GestureDetector(
                        onTap: () => _showTimerInputDialog(context),
                        child: RepaintBoundary(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  // macOS Sequoia ultra-transparent glass
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.02),
                                      Colors.white.withOpacity(0.01),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _formatTime(_hours, _minutes, _seconds),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (_isTimeMode && _isRunning) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Target: ${_getTargetTimeString()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Time Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimeSpinner('Hours', _hours, (value) {
                            setState(() {
                              _hours = value;
                              _calculateTotalSeconds();
                            });
                          }, 0, 23),
                          _buildTimeSpinner('Minutes', _minutes, (value) {
                            setState(() {
                              _minutes = value;
                              _calculateTotalSeconds();
                            });
                          }, 0, 59),
                          _buildTimeSpinner('Seconds', _seconds, (value) {
                            setState(() {
                              _seconds = value;
                              _calculateTotalSeconds();
                            });
                          }, 0, 59),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // All Buttons in One Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildModeButton(
                            'Sleep',
                            Icons.bedtime,
                            _isSleepMode,
                            () => setState(() => _isSleepMode = true),
                          ),
                          const SizedBox(width: 12),
                          _buildModeButton(
                            'Shutdown',
                            Icons.power_settings_new,
                            !_isSleepMode,
                            () => setState(() => _isSleepMode = false),
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            'Start',
                            Icons.play_arrow,
                            Colors.green,
                            _startTimer,
                          ),
                          if (_isRunning) ...[
                            const SizedBox(width: 12),
                            _buildActionButton(
                              'Stop',
                              Icons.stop,
                              Colors.red,
                              _stopTimer,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              'Reset',
                              Icons.refresh,
                              Colors.orange,
                              _resetTimer,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  // Footer - Sticky History Log
                  if (_historyEvents.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        // No fixed height, fills remaining space
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.015),
                              Colors.white.withOpacity(0.005),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 0.5,
                          ),
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.1, 0.9, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _historyEvents.length,
                            itemBuilder: (context, index) {
                              final event = _historyEvents[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${event['type']}: ${event['time']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontFamily: 'monospace',
                                    height: 1.6,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSpinner(String label, int value, Function(int) onChanged, int min, int max) {
    return Column(
      children: [
            Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            // Fake glassmorphism - lightweight gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol kiri (kurang) - hanya panah tanpa box
              IconButton(
                icon: Icon(
                  Icons.arrow_left,
                  color: value > min ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 24,
                ),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                padding: const EdgeInsets.all(8),
              ),
              // Display nilai di tengah - Horizontal dengan input manual
              GestureDetector(
                onTap: () => _showNumberInputDialog(context, label, value, onChanged, min, max),
                child: Container(
                  width: 50,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
              // Tombol kanan (tambah) - hanya panah tanpa box
              IconButton(
                icon: Icon(
                  Icons.arrow_right,
                  color: value < max ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 24,
                ),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Glass effect for mode buttons - clean, no shadow
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected 
              ? [
                  Color(0xFF1e3a8a).withOpacity(0.25),
                  Color(0xFF0f1e42).withOpacity(0.15),
                ]
              : [
                  Colors.white.withOpacity(0.015),
                  Colors.white.withOpacity(0.005),
                ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
              ? Color(0xFF3b82f6).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF1e3a8a) : Colors.white70,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          // Glass effect with color tint - clean, no glow
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }

  // Dialog untuk input manual spinner (Hours, Minutes, Seconds)
  void _showNumberInputDialog(BuildContext context, String label, int currentValue, Function(int) onChanged, int min, int max) {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2C2C2E).withOpacity(0.5),
                        const Color(0xFF000000).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set $label',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Enter $label ($min-$max)',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                final int? newValue = int.tryParse(controller.text);
                                if (newValue != null && newValue >= min && newValue <= max) {
                                  onChanged(newValue);
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please enter a valid number between $min and $max'),
                                      backgroundColor: Colors.red.withOpacity(0.8),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Set',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog untuk input manual timer display
  void _showTimerInputDialog(BuildContext context) {
    final TextEditingController hoursController = TextEditingController(text: _hours.toString());
    final TextEditingController minutesController = TextEditingController(text: _minutes.toString());
    final TextEditingController secondsController = TextEditingController(text: _seconds.toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2C2C2E).withOpacity(0.5),
                        const Color(0xFF000000).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Timer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: hoursController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Hours',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(':', style: TextStyle(color: Colors.white, fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: minutesController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Minutes',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(':', style: TextStyle(color: Colors.white, fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: secondsController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Seconds',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                final int? hours = int.tryParse(hoursController.text);
                                final int? minutes = int.tryParse(minutesController.text);
                                final int? seconds = int.tryParse(secondsController.text);
                                
                                if (hours != null && minutes != null && seconds != null &&
                                    hours >= 0 && hours <= 23 &&
                                    minutes >= 0 && minutes <= 59 &&
                                    seconds >= 0 && seconds <= 59) {
                                  setState(() {
                                    _hours = hours;
                                    _minutes = minutes;
                                    _seconds = seconds;
                                    _calculateTotalSeconds();
                                  });
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please enter valid time values'),
                                      backgroundColor: Colors.red.withOpacity(0.8),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Set',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
