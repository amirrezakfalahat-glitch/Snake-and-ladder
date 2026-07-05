import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_confetti/flutter_confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مار و پله حرفه‌ای',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

// --- صفحه شروع بازی ---
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _player1Controller = TextEditingController(text: "داداچ");
  final _player2Controller = TextEditingController(text: "هوش مصنوعی");
  bool _vsBot = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              color: Colors.black.withOpacity(0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.casino, size: 80, color: Colors.amber),
                    const SizedBox(height: 16),
                    const Text(
                      "بازی مار و پله",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _player1Controller,
                      decoration: InputDecoration(
                        labelText: 'نام بازیکن اول',
                        prefixIcon: const Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("بازی با کامپیوتر (بات)؟", style: TextStyle(color: Colors.white70)),
                        const Spacer(),
                        Switch(
                          value: _vsBot,
                          onChanged: (val) {
                            setState(() {
                              _vsBot = val;
                              if (_vsBot) {
                                _player2Controller.text = "هوش مصنوعی";
                              } else {
                                _player2Controller.text = "بازیکن دوم";
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (!_vsBot) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _player2Controller,
                        decoration: InputDecoration(
                          labelText: 'نام بازیکن دوم',
                          prefixIcon: const Icon(Icons.person, color: Colors.red),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              player1Name: _player1Controller.text,
                              player2Name: _player2Controller.text,
                              vsBot: _vsBot,
                            ),
                          ),
                        );
                      },
                      child: const Text("شروع رقابت 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- صفحه اصلی بازی ---
class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final bool vsBot;

  const GameScreen({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.vsBot,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // نقشه مارها و پله‌ها
  final Map<int, int> snakes = {
    17: 7, 54: 34, 62: 19, 64: 60, 87: 24, 93: 73, 95: 75, 98: 79
  };
  final Map<int, int> ladders = {
    1: 38, 4: 14, 9: 31, 21: 42, 28: 84, 36: 44, 51: 67, 71: 91, 80: 100
  };

  late String p1;
  late String p2;
  int p1Pos = 0;
  int p2Pos = 0;
  int activePlayer = 1; // 1 برای بازیکن اول، 2 برای بازیکن دوم/بات
  int lastDice = 0;
  String gameLog = "بازی شروع شد! تاس بنداز داداچ.";
  bool isRolling = false;
  bool isWinner = false;

  @override
  void initState() {
    super.initState();
    p1 = widget.player1Name;
    p2 = widget.player2Name;
  }

  void rollDice() async {
    if (isRolling || isWinner) return;

    setState(() {
      isRolling = true;
      gameLog = "${activePlayer == 1 ? p1 : p2} در حال تاس ریختن...";
    });

    // افکت چرخش تاس با تاخیر مصنوعی
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    int diceValue = random.nextInt(6) + 1;

    setState(() {
      lastDice = diceValue;
      isRolling = false;
      _movePlayer(diceValue);
    });

    // نوبت ربات
    if (widget.vsBot && activePlayer == 2 && !isWinner) {
      await Future.delayed(const Duration(milliseconds: 1500));
      rollDice();
    }
  }

  void _movePlayer(int steps) {
    int currentPos = (activePlayer == 1) ? p1Pos : p2Pos;
    int targetPos = currentPos + steps;

    String playerLabel = (activePlayer == 1) ? p1 : p2;

    if (targetPos > 100) {
      setState(() {
        gameLog = "🎲 $playerLabel عدد $steps آورد ولی نیاز به خانه دقیق داشت. حرکت نکرد.";
        _switchTurn(steps);
      });
      return;
    }

    // بررسی مار و پله
    String eventLog = "";
    if (snakes.containsKey(targetPos)) {
      int prev = targetPos;
      targetPos = snakes[targetPos]!;
      eventLog = " 🐍 اوه! مار گزید و از $prev سقوط کرد به $targetPos!";
    } else if (ladders.containsKey(targetPos)) {
      int prev = targetPos;
      targetPos = ladders[targetPos]!;
      eventLog = " 🪜 عالیه! از پله بالا رفت و از $prev رسید به $targetPos!";
    }

    setState(() {
      if (activePlayer == 1) {
        p1Pos = targetPos;
      } else {
        p2Pos = targetPos;
      }

      gameLog = "🎲 $playerLabel تاس $steps آورد و به خانه $targetPos رسید.$eventLog";

      if (targetPos == 100) {
        isWinner = true;
        gameLog = "🏆 $playerLabel برنده مسابقه شد! هوراااا 🎉";
        Confetti.launch(context, options: const ConfettiOptions(particleCount: 100, spread: 70));
      } else {
        _switchTurn(steps);
      }
    });
  }

  void _switchTurn(int lastDiceRolled) {
    // قانون تاس ۶: جایزه پرتاب دوباره
    if (lastDiceRolled == 6) {
      gameLog += "\n🔥 جایزه تاس ۶! دوباره بازی کن.";
      return;
    }
    activePlayer = (activePlayer == 1) ? 2 : 1;
  }

  void resetGame() {
    setState(() {
      p1Pos = 0;
      p2Pos = 0;
      activePlayer = 1;
      lastDice = 0;
      gameLog = "بازی از نو شروع شد. تاس بنداز!";
      isWinner = false;
    });
  }

  // گرفتن مختصات سطر و ستون روی برد ۱۰ در ۱۰ مارپیچی
  GridPosition getCellCoordinates(int cellNumber) {
    if (cellNumber == 0) return GridPosition(-1, -1); // بیرون برد

    int index = cellNumber - 1;
    int row = index ~/ 10;
    int col = index % 10;

    // به صورت زیگزاگ بالا رفتن
    if (row % 2 == 1) {
      col = 9 - col;
    }
    // برعکس کردن سطر به خاطر نمایش از پایین به بالا در گرید فلاتر
    row = 9 - row;

    return GridPosition(row, col);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("صفحه مسابقه"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          )
        ],
      ),
      body: Column(
        children: [
          // بخش نمایش نوبت و اطلاعات بازیکنان
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPlayerCard(p1, p1Pos, Colors.blue, activePlayer == 1),
                _buildPlayerCard(p2, p2Pos, Colors.red, activePlayer == 2),
              ],
            ),
          ),

          // برد بازی مار و پله
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[800]!, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // طراحی ساختار خانه‌های جدول
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10,
                        ),
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          // محاسبه شماره خانه واقعی
                          int gridRow = index ~/ 10;
                          int gridCol = index % 10;
                          int displayRow = 9 - gridRow;
                          int displayCol = (displayRow % 2 == 1) ? (9 - gridCol) : gridCol;
                          int cellNum = displayRow * 10 + displayCol + 1;

                          Color cellColor = (displayRow + displayCol) % 2 == 0
                              ? Colors.grey[800]!
                              : Colors.grey[850]!;

                          if (snakes.containsKey(cellNum)) {
                            cellColor = Colors.red.withOpacity(0.2);
                          } else if (ladders.containsKey(cellNum)) {
                            cellColor = Colors.green.withOpacity(0.2);
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: Text(
                                    "$cellNum",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: cellNum == 100 ? Colors.amber : Colors.white60,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // علامت‌گذاری گرافیکی مار و پله
                                if (snakes.containsKey(cellNum))
                                  const Center(child: Text("🐍", style: TextStyle(fontSize: 14))),
                                if (ladders.containsKey(cellNum))
                                  const Center(child: Text("🪜", style: TextStyle(fontSize: 14))),
                              ],
                            ),
                          );
                        },
                      ),

                      // مهره بازیکن اول (آبی)
                      _buildAnimatedToken(p1Pos, Colors.blue, 0),

                      // مهره بازیکن دوم/بات (قرمز)
                      _buildAnimatedToken(p2Pos, Colors.red, 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // بخش پایینی: گزارشات بازی و دکمه پرتاب تاس
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // متن لاگ بازی
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[950],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameLog,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.amberAccent, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // نمایش گرافیکی تاس
                    _buildDiceWidget(lastDice),

                    // دکمه پرتاب
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: (widget.vsBot && activePlayer == 2) || isWinner || isRolling
                          ? null
                          : rollDice,
                      icon: isRolling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.casino),
                      label: const Text("انداختن تاس 🎲", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerCard(String name, int pos, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(color: isActive ? color : Colors.grey[700]!, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          const SizedBox(height: 4),
          Text("موقعیت: $pos", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAnimatedToken(int position, Color color, double offset) {
    if (position == 0) return const SizedBox.shrink();

    final coords = getCellCoordinates(position);
    // تقسیم بندی صفحه به ۱۰ قسمت مساوی
    return LayoutBuilder(
      builder: (context, constraints) {
        final step = constraints.maxWidth / 10;
        final left = coords.col * step + (step / 4) + offset / 3;
        final top = coords.row * step + (step / 4);

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          left: left,
          top: top,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiceWidget(int val) {
    IconData icon;
    switch (val) {
      case 1: icon = Icons.looks_one; break;
      case 2: icon = Icons.looks_two; break;
      case 3: icon = Icons.looks_3; break;
      case 4: icon = Icons.looks_4; break;
      case 5: icon = Icons.looks_5; break;
      case 6: icon = Icons.looks_6; break;
      default: icon = Icons.casino;
    }
    return Icon(icon, size: 50, color: Colors.amberAccent);
  }
}

class GridPosition {
  final int row;
  final int col;
  GridPosition(this.row, this.col);
}
