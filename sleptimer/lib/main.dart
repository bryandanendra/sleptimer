import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for compute
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart'; // For MethodChannel
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
  // Removed old trayManager code, now using native MenuBarManager
  /*
  try {
    await trayManager.setIcon('assets/icon.png', isTemplate: true);
  } catch (e) {
    print('Failed to set tray icon in main: $e');
    // Continue without custom icon
  }
  */
  
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
    // Initialize native menu bar connection
    _initNativeMenuBar();
    
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
    // trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh logs when app comes to foreground -> likely after wake
      _loadMacSystemLogs();
    }
  }

  // Initialize Native Menu Bar Channel
  static const platform = MethodChannel('com.bryandanendra.sleptimer/island');

  void _initNativeMenuBar() {
    // Initial state setup if needed
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

  // Target end time for drift-proof counting
  DateTime? _endTime;

  void _startTimer() {
    if (_totalSeconds <= 0) return;
    
    // Prevent multiple timers and fix "jumping"
    _timer?.cancel(); 

    setState(() {
      _isRunning = true;
      // Calculate target end time based on current total seconds
      _endTime = DateTime.now().add(Duration(seconds: _totalSeconds));
      
      // Tell native to expand and show timer
      platform.invokeMethod('startTimer');
    });

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      // Use shorter interval (e.g. 200ms) for smoother updates, 
      // but only update seconds when changed.
      
      final now = DateTime.now();
      if (_endTime == null) {
         timer.cancel();
         return;
      }
      
      final remaining = _endTime!.difference(now).inSeconds;
      
      if (remaining != _totalSeconds && remaining >= 0) {
        setState(() {
          _totalSeconds = remaining;
          _updateTimeDisplay();
          platform.invokeMethod('updateTimer', _formatCompactTime(_hours, _minutes, _seconds));
        });
      }

      if (remaining <= 0) {
        timer.cancel();
        setState(() {
           _totalSeconds = 0;
           _isRunning = false;
           _endTime = null;
           _updateTimeDisplay();
        });
        platform.invokeMethod('stopTimer');
        _executeAction();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _endTime = null;
    setState(() {
      _isRunning = false;
      platform.invokeMethod('stopTimer');
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _endTime = null;
    setState(() {
      _isRunning = false;
      platform.invokeMethod('stopTimer');
      _calculateTotalSeconds(); // Reset to original inputs (roughly, or logic needs to track 'original')
      // Actually _calculateTotalSeconds relies on _hours/_minutes spinners. 
      // If we counted down, _totalSeconds is 0. We might want to restore inputs?
      // For now, standard behavior: recalculate from current spinners.
      _updateTimeDisplay(); // Ensure display reflects spinners
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

  // Format waktu untuk Dynamic Island (Compact: 1h 20m, 15m 30s)
  String _formatCompactTime(int hours, int minutes, int seconds) {
    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
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
      // Note: grep case insensitive (-i) and extended regex (-E)
      // Increased to 5000 lines to cover more days (1000 lines only covered ~24h due to heavy system logs)
      final result = await Process.run('bash', ['-c', 'pmset -g log | grep -iE "Sleep|Wake|Shutdown|Start" | tail -n 5000']);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        
        // OPTIMIZATION: Run parsing in a background isolate using compute()
        // This prevents UI jank when processing 5000+ lines of logs
        final events = await compute(_parseLogsInIsolate, output);
        
        if (mounted) { 
          setState(() {
            _historyEvents = events;
          });
        }
      }
    } catch (e) {
      print('Error reading system logs: $e');
    }
  }

  /*
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
  */


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
                              behavior: HitTestBehavior.opaque,
                              onTap: _isRunning ? null : () {
                                print('Toggle button tapped! isRunning: $_isRunning, isTimeMode: $_isTimeMode');
                                _toggleTimeMode();
                              },
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
                              autofocus: true, // Auto focus for keyboard input
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

// --- TOP LEVEL FUNCTIONS FOR ISOLATE ---

// Fungsi parsing ini dijalankan di background isolate
// Tidak boleh mengakses state UI atau plugin apapun
List<Map<String, String>> _parseLogsInIsolate(String logOutput) {
  final events = <Map<String, String>>[];
  final lines = logOutput.split('\n');
  
  // 1. Cek Boot Time dari Summary Line
  final bootSummaryMatch = RegExp(r'Total Sleep/Wakes since boot at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})').firstMatch(logOutput);
  if (bootSummaryMatch != null) {
    final bootTimeStr = bootSummaryMatch.group(1)!;
    try {
      final bootTime = DateTime.parse(bootTimeStr);
      events.add({
        'type': 'Boot',
        'time': _formatTimeStatic(bootTime),
        'timestamp': bootTime.millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      // Ignore
    }
  }

  for (var line in lines) {
    try {
      String eventType = '';
      
      // 2. Parsing Event Historis
      if (line.contains('Entering Sleep state') ||
          (line.contains('Sleep') && line.contains('due to') && !line.contains('Display'))) {
        eventType = 'Sleep';
      } 
      else if (line.contains('Wake from Normal Sleep') ||
               line.contains('WakeFromNormalSleep') || 
               (line.contains('Wake') && line.contains('due to') && !line.contains('Display') && !line.contains('DarkWake'))) {
        eventType = 'Wake';
      } 
      else if (line.contains('Shutdown cause') || line.contains('SHUTDOWN')) {
        eventType = 'Shutdown';
      } 
      else if (line.contains('Boot') && line.contains('args:')) {
        eventType = 'Boot';
      }
      
      if (eventType.isNotEmpty) {
        final timeMatch = RegExp(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})').firstMatch(line);
        
        if (timeMatch != null) {
          final dateStr = timeMatch.group(1)!;
          final timeStr = timeMatch.group(2)!;
          
          try {
            final dateTime = DateTime.parse('$dateStr $timeStr');
            events.add({
              'type': eventType,
              'time': _formatTimeStatic(dateTime),
              'timestamp': dateTime.millisecondsSinceEpoch.toString(),
            });
          } catch (e) {
            // Skip
          }
        }
      }
    } catch (e) {
      // Skip
    }
  }
  
  // Sort Newest -> Oldest
  events.sort((a, b) => int.parse(b['timestamp']!).compareTo(int.parse(a['timestamp']!)));
  
  // Filter Duplikasi (Strict Alternating)
  final uniqueEvents = <Map<String, String>>[];
  String? lastType;
  
  for (var event in events) {
    final type = event['type']!;
    bool shouldKeep = false;
    
    if (lastType == null) {
      shouldKeep = true;
    } else {
      if (type == 'Boot') {
         shouldKeep = true;
      } else if (type != lastType) {
        shouldKeep = true;
      }
    }

    if (shouldKeep) {
      uniqueEvents.add(event);
      lastType = type;
    }
  }
  
  return uniqueEvents;
}

// Helper formatting statis (karena harus dipanggil dari isolate)
String _formatTimeStatic(DateTime dateTime) {
  final now = DateTime.now();
  // Simple formatting tanpa intl package dependency di isolate jika memungkinkan,
  // tapi compute share memory dengan main isolate jadi intl harusnya oke jika diimport global.
  // We use DateFormat from intl here.
  
  // Note: DateFormat might need initialization inside isolate if it uses locale data.
  // But usually default en_US works fine.
  
  // Custom manual formatting to be safe and fast in isolate
  String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
  }
  
  String formatHour(int hour) {
      int h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "$h";
  }
  
  String amPm(int hour) => hour >= 12 ? "PM" : "AM";
  
  String timeStr = "${formatHour(dateTime.hour)}:${twoDigits(dateTime.minute)} ${amPm(dateTime.hour)}";

  if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
    return 'Today, $timeStr';
  } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
    return 'Yesterday, $timeStr';
  } else {
     const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
     return "${months[dateTime.month - 1]} ${dateTime.day}, $timeStr";
  }
}
