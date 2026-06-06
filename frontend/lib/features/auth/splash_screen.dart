import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/smart_ai_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      child: CustomPaint(
        painter: _SplashDiagonalPainter(),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.glass.withValues(alpha: 0.56),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.purpleAccent.withValues(alpha: 0.42),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purpleAccent.withValues(alpha: 0.28),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.purple3,
                            size: 34,
                          ),
                          Positioned(
                            right: 14,
                            bottom: 13,
                            child: Icon(
                              Icons.memory_rounded,
                              color: AppColors.cyan,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Smart Campus AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 108,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.45),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashDiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF202331), Color(0xFF060715)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    final purplePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3D2594), Color(0xFF260284)],
        begin: Alignment.topRight,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.43, 0)
      ..lineTo(size.width * 0.73, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rightPath = Path()
      ..moveTo(size.width * 0.20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.58, size.height)
      ..close();

    canvas.drawPath(rightPath, purplePaint);
    canvas.drawPath(leftPath, darkPaint);

    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    accent.color = AppColors.purple3.withValues(alpha: 0.40);
    canvas.drawLine(
      Offset(0, size.height * 0.09),
      Offset(size.width * 0.24, 0),
      accent,
    );
    accent.color = AppColors.cyan.withValues(alpha: 0.28);
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.71),
      Offset(size.width, size.height * 0.90),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
