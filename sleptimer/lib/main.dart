import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Configure window settings
  await windowManager.setMinimumSize(const Size(550, 450));
  await windowManager.setSize(const Size(550, 450));
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
    with TickerProviderStateMixin, TrayListener {
  int _hours = 0;
  int _minutes = 25;
  int _seconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isSleepMode = true;
  bool _isTimeMode = false; // Mode waktu jam
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    trayManager.removeListener(this);
    super.dispose();
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
        await Process.run('sudo', ['shutdown', '-h', 'now']);
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
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a1a), // Solid Light Black background
        ),
                  child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
        child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                            color: _isRunning 
                              ? const Color(0xFF2d2d2d).withOpacity(0.3)
                              : (_isTimeMode 
                                ? const Color(0xFF1e3a8a).withOpacity(0.8)
                                : const Color(0xFF2d2d2d).withOpacity(0.6)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isRunning
                                ? Colors.white.withOpacity(0.1)
                                : (_isTimeMode 
                                  ? const Color(0xFF1e3a8a)
                                  : Colors.white.withOpacity(0.1)),
                              width: 2,
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

                  // Timer Display dengan input manual
                  GestureDetector(
                    onTap: () => _showTimerInputDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1a1a).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF1e3a8a).withOpacity(0.5),
                          width: 1,
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
            color: const Color(0xFF2d2d2d).withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF1e3a8a).withOpacity(0.3),
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
                    color: const Color(0xFF1a1a1a).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF1e3a8a).withOpacity(0.3),
                      width: 1,
                    ),
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
          color: isSelected ? const Color(0xFF1e3a8a).withOpacity(0.8) : const Color(0xFF2d2d2d).withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1e3a8a) : Colors.white.withOpacity(0.1),
            width: 2,
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
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color,
            width: 2,
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
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Text(
            'Set $label',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Enter $label ($min-$max)',
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1e3a8a), width: 2),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                final int? newValue = int.tryParse(controller.text);
                if (newValue != null && newValue >= min && newValue <= max) {
                  onChanged(newValue);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid number between $min and $max'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Set',
                style: TextStyle(color: Color(0xFF1e3a8a), fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: const Text(
            'Set Timer',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a), width: 2),
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
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a), width: 2),
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
                      decoration: const InputDecoration(
                        labelText: 'Seconds',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1e3a8a), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
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
                    const SnackBar(
                      content: Text('Please enter valid time values'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Set',
                style: TextStyle(color: Color(0xFF1e3a8a), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
