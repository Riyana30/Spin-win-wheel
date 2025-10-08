import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpinWheel extends StatefulWidget {
  @override
  _SpinWheelState createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Color> segmentColors = [
    Color.fromARGB(255, 93, 55, 155),
    Color.fromARGB(255, 139, 87, 223),
    Color(0xFFC59AFF),
    Color.fromARGB(255, 140, 104, 197),
    Color(0xFFA26BF8),
  ];

  final List<String> prizes = [
    "🎁 20% OFF",
    "🎉 Mystery Gift",
    "🚚 Free Delivery",
    "😇 Better luck next time ×3",
    "💵 Flat ₹100M Off "
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> canSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSpinTime = prefs.getInt('lastSpinTime') ?? 0;
    final spinCount = prefs.getInt('spinCount') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - lastSpinTime > 3600000) {
      await prefs.setInt('spinCount', 0);
      await prefs.setInt('lastSpinTime', currentTime);
      return true;
    } else if (spinCount < 26) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> recordSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final spinCount = prefs.getInt('spinCount') ?? 0;
    await prefs.setInt('spinCount', spinCount + 1);
    await prefs.setInt('lastSpinTime', DateTime.now().millisecondsSinceEpoch);
  }

  void spinWheel() async {
    if (!await canSpin()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have reached 3 spins per hour!')),
      );
      return;
    }

    await recordSpin();

    final random = Random();
    final segmentCount = prizes.length;
    final segmentAngle = 2 * pi / segmentCount;
    final randomSegment = random.nextInt(segmentCount);
    final randomAngleWithinSegment =
        (randomSegment + 0.3 + random.nextDouble() * 0.4) * segmentAngle;
    final totalRotation = 4 * pi + randomAngleWithinSegment;

    _animation = Tween<double>(begin: 0, end: totalRotation)
        .chain(CurveTween(curve: Curves.easeOutQuart))
        .animate(_animationController);

    _animationController.forward(from: 0).then((_) {
      int prizeIndex = getPrizeIndex(_animation.value, prizes.length);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won ${prizes[prizeIndex]}',style: TextStyle(fontSize: 18),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  int getPrizeIndex(double rotation, int segments) {
    double normalized = rotation % (2 * pi);
    double adjusted = (normalized + pi / 2) % (2 * pi);
    double segmentAngle = 2 * pi / segments;
    int index = segments - 1 - (adjusted / segmentAngle).floor();
    return index % segments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Curved AppBar background
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 96, 63, 132), Color(0xFF2575FC)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // AppBar content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Lucky Turn",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,fontFamily: 'IrishGrover',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Curved body container
          Padding(
            padding: const EdgeInsets.only(top: 120), 
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),

                    // Two texts above the wheel
                    Column(
                      children: const [
                        Text(
                          "Welcome to Lucky Spin!",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Try your luck and win exciting prizes",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Spin Wheel
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateZ(_animation.value),
                              child: CustomPaint(
                                size: Size(325, 325),
                                painter: WheelPainter(segmentColors, prizes),
                              ),
                            );
                          },
                        ),
                        // Location pointer
                        Positioned(
                          top: -30,
                          child: Container(
                            width: 30,
                            height: 60,
                            child: CustomPaint(
                              size: Size(30, 60),
                              painter: LocationPointerPainter(),
                            ),
                          ),
                        ),
                        // Center star
                        Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 46, 25, 142),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: Size(18, 18),
                                painter: StarCenterPainter(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    ElevatedButton(
                      onPressed: spinWheel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 46, 25, 142),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'SPIN',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Curved AppBar clipper
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Location pointer painter
class LocationPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path();
    path.moveTo(width / 2, 0);
    path.lineTo(width, height * 0.7);
    path.lineTo(width * 0.5, height);
    path.lineTo(0, height * 0.7);
    path.close();

    final fillPaint = Paint()
      ..color =Color.fromARGB(255, 46, 25, 142)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawShadow(path, Colors.black.withOpacity(0.5), 3.0, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // inner circle
    final circlePaint = Paint()..color = Color.fromARGB(255, 46, 25, 142);
    canvas.drawCircle(Offset(width / 2, height * 0.35), width * 0.12, circlePaint);
    canvas.drawCircle(
        Offset(width / 2, height * 0.35),
        width * 0.12,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Center star
class StarCenterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    for (int i = 0; i < 5; i++) {
      double angle = i * 2 * pi / 5 - pi / 2;
      double x = cx + r * cos(angle);
      double y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += pi / 5;
      x = cx + r / 2 * cos(angle);
      y = cy + r / 2 * sin(angle);
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wheel painter
class WheelPainter extends CustomPainter {
  final List<Color> colors;
  final List<String> labels;

  WheelPainter(this.colors, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final angle = 2 * pi / colors.length;
    final radius = size.width / 2;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(rect, angle * i, angle, true, paint);
    }

    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < colors.length; i++) {
      double x = radius + radius * cos(angle * i);
      double y = radius + radius * sin(angle * i);
      canvas.drawLine(Offset(radius, radius), Offset(x, y), dividerPaint);
    }

    for (int i = 0; i < colors.length; i++) {
      final centerAngle = angle * i + angle / 2;
      final textRadius = radius * 0.7;
      final x = radius + textRadius * cos(centerAngle);
      final y = radius + textRadius * sin(centerAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(centerAngle + pi / 2);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    final borderPaint = Paint()
      ..color = Color.fromARGB(255, 46, 25, 142)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(
        Offset(radius, radius), radius - borderPaint.strokeWidth / 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
