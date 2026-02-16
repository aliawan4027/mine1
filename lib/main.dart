import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoveGameApp());
}

class LoveGameApp extends StatelessWidget {
  const LoveGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 1, 243, 14),
          brightness: Brightness.light,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state
  bool _isGameStarted = false;
  bool _isGameOver = false;
  int _noClickCount = 0;

  // Animation controllers
  late AnimationController _heartController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;

  // Confetti controller
  late ConfettiController _confettiController;

  // Button positions and sizes
  double _yesButtonScale = 1.0;
  double _noButtonScale = 1.0;
  Offset _noButtonPosition = Offset.zero;
  bool _isNoButtonMoving = false;

  // Funny messages for No button
  final List<String> _noMessages = [
    "Are you sure? �",
    "Really? �",
    "Think about it 🍕",
    "Food is always good �",
    "Just dinner, nothing serious",
    "Try again �",
    "Please say yes 🍝",
    "I know good places 🥘",
    "Give it a chance 🍱",
    "My treat! 🍗",
    "Just one meal �",
    "Pretty please 🙏",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Heart floating animation
    _heartController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Bounce animation for Yes button
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Shake animation for No button
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Simple email function that saves data locally
  Future<void> _sendEmail() async {
    try {
      // Save to local storage first
      await _saveClickCount();

      // Try to send notification
      await _sendSimpleNotification();

      // Show success message to user
      _showNotificationMessage();
    } catch (e) {
      print('Notification failed: $e');
      _saveClickCount(); // Always save locally
      _showNotificationMessage();
    }
  }

  // Save click count to local storage
  Future<void> _saveClickCount() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toString();

    // Save the game result
    await prefs.setString(
      'last_game_result',
      {
        'clicks': _noClickCount.toString(),
        'timestamp': timestamp,
        'result': 'YES',
      }.toString(),
    );

    // Save to history
    final history = prefs.getStringList('game_history') ?? [];
    history.add('Game at $timestamp: $_noClickCount clicks before YES');
    await prefs.setStringList('game_history', history);

    print('Game result saved locally!');
  }

  // Show notification message to user
  void _showNotificationMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Game saved! $_noClickCount clicks before YES'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View Data',
            onPressed: () => _showSavedData(),
          ),
        ),
      );
    }
  }

  // Show saved game data
  void _showSavedData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Game Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last game: $_noClickCount clicks before YES'),
            const SizedBox(height: 10),
            const Text('Send this info to aliawan1170@gmail.com'),
            const Text('Or call: 03467648259'),
            const SizedBox(height: 10),
            Text('Message: "She said YES after $_noClickCount No clicks"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Try simple notification service
  Future<void> _sendSimpleNotification() async {
    try {
      // Using a free notification service
      final response = await http.post(
        Uri.parse('https://api.pushover.net/1/messages.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': 'your_pushover_token', // Get from pushover.net
          'user': 'your_pushover_user_key',
          'message':
              'She said YES to dinner after $_noClickCount No clicks! 🎉',
          'title': 'Dinner Game Result',
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent!');
      }
    } catch (e) {
      print('Push notification failed: $e');
    }
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
    });
  }

  void _handleYesClick() {
    setState(() {
      _isGameOver = true;
    });

    // Start confetti animation
    _confettiController.play();

    // Send email notification
    _sendEmail();

    // Play success animation
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  void _handleNoClick() {
    setState(() {
      _noClickCount++;

      // Scale buttons
      _yesButtonScale = math.min(1.0 + (_noClickCount * 0.1), 2.5);
      _noButtonScale = math.max(1.0 - (_noClickCount * 0.08), 0.3);

      // After 11-12 clicks, make No button move randomly
      if (_noClickCount >= 11) {
        _isNoButtonMoving = true;
        _moveNoButtonRandomly();
      }
    });

    // Shake animation
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _moveNoButtonRandomly() {
    if (!_isNoButtonMoving) return;

    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      _noButtonPosition = Offset(
        random.nextDouble() * (screenWidth - 100),
        random.nextDouble() * (screenHeight - 200) + 100,
      );
    });
  }

  String _getCurrentNoMessage() {
    if (_noClickCount == 0) return "No";
    return _noMessages[math.min(_noClickCount - 1, _noMessages.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00FF00), Color(0xFF90EE90), Color(0xFFFFFF00)],
          ),
        ),
        child: Stack(
          children: [
            // Floating lightning bolts background
            if (_isGameStarted && !_isGameOver)
              ...List.generate(5, (index) => _buildFloatingLightning(index)),

            // Main content
            SafeArea(child: Center(child: _buildCurrentScreen())),

            // Confetti
            if (_isGameOver)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.yellow,
                    Colors.white,
                    Colors.lime,
                    Colors.lightGreen,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (!_isGameStarted) {
      return _buildHomeScreen();
    } else if (_isGameOver) {
      return _buildGameOverScreen();
    } else {
      return _buildGameScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Please play till the end…',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.pink,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
          ),
          child: const Text(
            'Start',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        // Question
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              'Would you like to grab dinner sometime next week?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Yes Button
        if (!_isNoButtonMoving)
          Positioned(
            bottom: 200,
            left: 50,
            child: AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _yesButtonScale * (1 + _bounceController.value * 0.1),
                  child: ElevatedButton(
                    onPressed: _handleYesClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 15,
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Yes Button (centered when No button is moving)
        if (_isNoButtonMoving)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _yesButtonScale * (1 + _bounceController.value * 0.1),
                    child: ElevatedButton(
                      onPressed: _handleYesClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 20,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // No Button
        if (!_isNoButtonMoving)
          Positioned(
            bottom: 200,
            right: 50,
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeController.value *
                        10 *
                        (Random().nextBool() ? 1 : -1),
                    0,
                  ),
                  child: Transform.scale(
                    scale: _noButtonScale,
                    child: ElevatedButton(
                      onPressed: _handleNoClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 15,
                      ),
                      child: Text(
                        _getCurrentNoMessage(),
                        style: TextStyle(
                          fontSize: math.max(
                            16,
                            (20 - _noClickCount) as double,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Moving No Button
        if (_isNoButtonMoving)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            left: _noButtonPosition.dx,
            top: _noButtonPosition.dy,
            child: Transform.scale(
              scale: _noButtonScale,
              child: ElevatedButton(
                onPressed: () {
                  _handleNoClick();
                  // Move again immediately after click
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _moveNoButtonRandomly();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                ),
                child: Text(
                  _getCurrentNoMessage(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Click counter
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'No clicks: $_noClickCount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.flash_on, size: 100, color: Colors.yellow),
        const SizedBox(height: 30),
        const Text(
          'Game Over! ⚡️',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'She said YES to dinner! 🎉',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'You clicked No $_noClickCount times before saying Yes to dinner!',
          style: const TextStyle(fontSize: 18, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isGameStarted = false;
              _isGameOver = false;
              _noClickCount = 0;
              _yesButtonScale = 1.0;
              _noButtonScale = 1.0;
              _isNoButtonMoving = false;
              _noButtonPosition = Offset.zero;
            });
            _confettiController.stop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 10,
          ),
          child: const Text(
            'Play Again',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingLightning(int index) {
    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, child) {
        final offset = (index * 0.2) % 1.0;
        final y = (_heartController.value + offset) % 1.0;

        return Positioned(
          left: 50.0 + (index * 60.0),
          bottom: -50 + (y * (MediaQuery.of(context).size.height + 100)),
          child: Opacity(
            opacity: 0.3 + (0.3 * math.sin(y * math.pi)),
            child: Icon(
              Icons.flash_on,
              size: 20 + (index * 5),
              color: Colors.yellow.withOpacity(0.8),
            ),
          ),
        );
      },
    );
  }
}
