import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // 用于震动

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '致仲雨璐宝宝',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFAFAF5),
      ),
      home: const CoverPage(),
    );
  }
}

// ---------- 封面 ----------
class CoverPage extends StatefulWidget {
  const CoverPage({super.key});

  @override
  State<CoverPage> createState() => _CoverPageState();
}

class _CoverPageState extends State<CoverPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  void _goToNext() {
    _fadeController.forward().then((_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CatchButtonGame(),
          transitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToNext,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF0F5), Color(0xFFFAFAF5)],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // 花瓣粒子（简单模拟）
                ...List.generate(12, (index) {
                  final random = Random(index);
                  return Positioned(
                    left: random.nextDouble() * MediaQuery.of(context).size.width,
                    top: random.nextDouble() * MediaQuery.of(context).size.height,
                    child: const Icon(Icons.favorite, size: 10, color: Color(0x55FFB6C1)),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '致 仲雨璐宝宝',
                        style: GoogleFonts.caveat(
                          fontSize: 40,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '来自榆木脑袋向雯琪 🤍',
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '520 · 一份笨拙但认真的礼物',
                        style: GoogleFonts.caveat(
                          fontSize: 16,
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- 第一关：逃跑的按钮 ----------
class CatchButtonGame extends StatefulWidget {
  const CatchButtonGame({super.key});

  @override
  State<CatchButtonGame> createState() => _CatchButtonGameState();
}

class _CatchButtonGameState extends State<CatchButtonGame>
    with TickerProviderStateMixin {
  double buttonX = 0;
  double buttonY = 0;
  int escapeCount = 0;
  int catchCount = 0;
  String buttonText = '点击这里 想你了';
  bool gameWon = false;
  late AnimationController _popController;
  late AnimationController _celebrateController;

  final double buttonWidth = 160;
  final double buttonHeight = 56;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resetButtonPosition();
  }

  void _resetButtonPosition() {
    final size = MediaQuery.of(context).size;
    buttonX = (size.width - buttonWidth) / 2;
    buttonY = size.height * 0.6;
  }

  void _moveButtonRandomly() {
    final size = MediaQuery.of(context).size;
    final random = Random();
    double newX, newY;
    do {
      newX = random.nextDouble() * (size.width - buttonWidth - 40) + 20;
      newY = random.nextDouble() * (size.height - buttonHeight - 120) + 100;
    } while ((newX - buttonX).abs() < 100 && (newY - buttonY).abs() < 100);
    setState(() {
      buttonX = newX;
      buttonY = newY;
    });
  }

  void _onButtonPressed() {
    if (gameWon) return;
    setState(() {
      escapeCount++;
      catchCount++;
      if (catchCount < 3) {
        buttonText = catchCount == 1 ? '哎呀，被你抓到了' : '再来一次嘛';
        _moveButtonRandomly();
      } else {
        // 第三次抓住
        gameWon = true;
        buttonText = '好吧好吧，我带你去找璐璐💌';
        _popController.forward();
        _celebrateController.forward().then((_) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const QuizPage(),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // 网格背景
            CustomPaint(
              painter: GridPainter(),
              size: MediaQuery.of(context).size,
            ),
            // 计数器
            Positioned(
              top: 60,
              left: 20,
              child: Text(
                '逃跑次数：$escapeCount',
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              ),
            ),
            // 按钮
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              left: buttonX,
              top: buttonY,
              child: GestureDetector(
                onTap: gameWon ? null : _onButtonPressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: gameWon ? 200 : buttonWidth,
                  height: gameWon ? 70 : buttonHeight,
                  decoration: BoxDecoration(
                    color: gameWon ? const Color(0xFFFFB6C1) : const Color(0xFFFADADD),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: GoogleFonts.caveat(
                        fontSize: gameWon ? 24 : 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 爱心爆炸（胜利后）
            if (gameWon)
              ...List.generate(12, (index) {
                final random = Random(index);
                return Positioned(
                  left: buttonX + buttonWidth / 2,
                  top: buttonY + buttonHeight / 2,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(
                          (random.nextDouble() - 0.5) * 200 * value,
                          (random.nextDouble() - 0.5) * 200 * value,
                        ),
                        child: Opacity(
                          opacity: 1 - value,
                          child: const Icon(Icons.favorite, color: Colors.pink, size: 20),
                        ),
                      );
                    },
                  ),
                );
              }),
            // 提示文字
            if (catchCount == 1)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text('还差 2 次哦', style: TextStyle(color: Color(0xFF9E9E9E))),
                ),
              ),
            if (catchCount == 2)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text('差一点点！', style: TextStyle(color: Color(0xFF9E9E9E))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 网格背景画笔
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0D9E9E9E)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------- 第二关：问答 ----------
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  String feedbackText = '';
  String alsoText = '';

  final List<Map<String, dynamic>> questions = [
    {
      'question': '我最喜欢叫她什么？',
      'options': ['宝宝', '老婆', '璐璐', '雨璐'],
      'feedback': '不管叫哪个，你都是我的宝宝呀💗',
    },
    {
      'question': '我最喜欢她哪一点？',
      'options': ['全部', '性格', '外表', '陪伴'],
      'feedback': '你的一切我都喜欢，但选“全部”最准确🤍',
    },
    {
      'question': '520这天，我最想听到宝宝对我说什么？',
      'options': ['520快乐', '爱你宝宝', '我想你了', '全部'],
      'feedback': '只要是你说的话，每一句都是礼物🎁',
    },
  ];

  void _selectOption(String option) {
    setState(() {
      feedbackText = questions[currentQuestion]['feedback'];
      alsoText = '我也是~';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
          feedbackText = '';
          alsoText = '';
        });
      } else {
        // 所有问题结束
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LetterPage(),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFAFAF5)],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  question['question'],
                  style: const TextStyle(fontSize: 20, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 24),
                ...(question['options'] as List<String>).map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF333333),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _selectOption(option),
                        child: Text(option, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }).toList(),
                if (feedbackText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(feedbackText, style: GoogleFonts.caveat(fontSize: 18, color: const Color(0xFF333333))),
                ],
                if (alsoText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(alsoText, style: GoogleFonts.caveat(fontSize: 20, color: const Color(0xFFFF6B81))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- 情书页 ----------
class LetterPage extends StatefulWidget {
  const LetterPage({super.key});

  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> with TickerProviderStateMixin {
  final String fullText = '''璐璐宝宝：

我是榆木脑袋向雯琪。
可这一次，我这块木头还是想认认真真给你写点什么。

遇见你之后，
春天好像就没走远过。
你笑起来的时候，
比我解出最难的题还让我开心。

520 快乐。
谢谢你总愿意接纳我，
慢慢走，不着急。

这份小礼物是我用脑袋撞了好几次墙才做出来的，
希望你能笑一笑，
那就是我最大的胜利。

今天，奶茶、零食你随便点，
我来负责买单就好。

——永远更想懂你的向雯琪
2026.5.20''';

  late AnimationController _typingController;
  int _charCount = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80 * fullText.length),
    )..addListener(() {
        setState(() {
          _charCount = (_typingController.value * fullText.length).floor();
          if (_charCount >= fullText.length) _isFinished = true;
        });
      });
    _typingController.forward();
  }

  void _skipTyping() {
    _typingController.stop();
    setState(() {
      _charCount = fullText.length;
      _isFinished = true;
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFEF9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0E6D3), width: 1),
                ),
                child: GestureDetector(
                  onTap: _skipTyping,
                  child: Text(
                    fullText.substring(0, _charCount),
                    style: GoogleFonts.caveat(
                      fontSize: 19,
                      color: const Color(0xFF333333),
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ),
            if (_isFinished)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      foregroundColor: const Color(0xFFFF6B81),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const VoucherPage(),
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: const Text('读完了吗？点这里 💌', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- 奶茶零食券 ----------
class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  double sliderValue = 0.0;
  bool redeemed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFFB6C1)],
          ),
        ),
        child: Stack(
          children: [
            // 飘落爱心（简易）
            ...List.generate(20, (index) {
              final random = Random(index);
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                child: const Icon(Icons.favorite, size: 8, color: Color(0x55FFFFFF)),
              );
            }),
            Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 撕开虚线
                    DottedLine(),
                    const SizedBox(height: 16),
                    const Text(
                      '奶茶零食兑换券',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('持此券人：仲雨璐宝宝'),
                    const Text('可兑换：任意奶茶 + 任意零食'),
                    const Text('费用承担：向雯琪（榆木脑袋）'),
                    const Text('价格限制：无上限'),
                    const Text('有效期：今日限定'),
                    const SizedBox(height: 20),
                    // 滑动条
                    if (!redeemed)
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFFFF6B81),
                          inactiveTrackColor: const Color(0xFFEEEEEE),
                          thumbColor: const Color(0xFFFF6B81),
                          overlayColor: const Color(0x55FF6B81),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
                        ),
                        child: Slider(
                          value: sliderValue,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                              if (value >= 0.95 && !redeemed) {
                                redeemed = true;
                                HapticFeedback.mediumImpact(); // 震动反馈
                              }
                            });
                          },
                        ),
                      ),
                    if (redeemed) ...[
                      const Icon(Icons.check_circle, color: Color(0xFFFF6B81), size: 48),
                      const SizedBox(height: 8),
                      Text(
                        '今天全部我来！\n去找雯琪报销吧～',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.caveat(
                          fontSize: 24,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '——永远更想懂你的向雯琪',
                        style: GoogleFonts.caveat(
                          fontSize: 16,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                    if (!redeemed)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('滑动兑换', style: TextStyle(color: Color(0xFF9E9E9E))),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 虚线组件
class DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: DashPainter(),
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x55FF6B81)
      ..strokeWidth = 1;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + 6, 0), paint);
      startX += 12;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
