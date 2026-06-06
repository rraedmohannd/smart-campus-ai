import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmartAiBackground extends StatefulWidget {
  final Widget child;
  final bool dense;

  const SmartAiBackground({
    super.key,
    required this.child,
    this.dense = false,
  });

  @override
  State<SmartAiBackground> createState() => _SmartAiBackgroundState();
}

class _SmartAiBackgroundState extends State<SmartAiBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgDark1,
                  AppColors.bgDark2,
                  AppColors.bgDark3,
                  AppColors.purple1,
                ],
                stops: [0.0, 0.42, 0.72, 1.0],
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SmartAiBackgroundPainter(
                    progress: Curves.easeInOut.transform(_controller.value),
                    dense: widget.dense,
                  ),
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _SmartAiBackgroundPainter extends CustomPainter {
  final double progress;
  final bool dense;

  const _SmartAiBackgroundPainter({
    required this.progress,
    required this.dense,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x9A29E8FF),
          Color(0xB08A38F5),
          Color(0x0029E8FF),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    final wave = Path()
      ..moveTo(-size.width * 0.25, size.height * (0.18 + progress * 0.08))
      ..cubicTo(
        size.width * 0.22,
        size.height * (0.05 + progress * 0.10),
        size.width * 0.55,
        size.height * (0.38 - progress * 0.08),
        size.width * 1.25,
        size.height * (0.25 + progress * 0.06),
      )
      ..lineTo(size.width * 1.25, size.height * (0.42 + progress * 0.08))
      ..cubicTo(
        size.width * 0.62,
        size.height * (0.55 - progress * 0.04),
        size.width * 0.24,
        size.height * (0.25 + progress * 0.09),
        -size.width * 0.25,
        size.height * (0.36 + progress * 0.08),
      )
      ..close();
    canvas.drawPath(wave, wavePaint);

    _drawGlow(
      canvas,
      Offset(size.width * (0.14 + progress * 0.08), size.height * 0.22),
      AppColors.cyan,
      size.shortestSide * 0.44,
    );
    _drawGlow(
      canvas,
      Offset(size.width * (0.88 - progress * 0.10), size.height * 0.15),
      AppColors.purpleAccent,
      size.shortestSide * 0.56,
    );
    _drawGlow(
      canvas,
      Offset(size.width * (0.70 + progress * 0.06), size.height * 0.82),
      AppColors.purple2,
      size.shortestSide * 0.48,
    );

    final linePaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: dense ? 0.14 : 0.08)
      ..strokeWidth = 1.0;
    final purpleLinePaint = Paint()
      ..color = AppColors.purpleAccent.withValues(alpha: dense ? 0.16 : 0.09)
      ..strokeWidth = 1.0;

    for (var i = -2; i < 7; i++) {
      final x = size.width * (i * 0.24 + progress * 0.05);
      canvas.drawLine(
        Offset(x, size.height * 0.06),
        Offset(x + size.width * 0.32, size.height * 0.58),
        i.isEven ? linePaint : purpleLinePaint,
      );
    }

    final scanPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 56) {
      canvas.drawLine(
        Offset(0, y + progress * 16),
        Offset(size.width, y + progress * 16),
        scanPaint,
      );
    }
  }

  void _drawGlow(Canvas canvas, Offset center, Color color, double radius) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.26),
          color.withValues(alpha: 0.10),
          color.withValues(alpha: 0.00),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SmartAiBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dense != dense;
  }
}

class SmartAiScaffold extends StatelessWidget {
  final Widget child;
  final bool dense;
  final bool resizeToAvoidBottomInset;

  const SmartAiScaffold({
    super.key,
    required this.child,
    this.dense = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SmartAiBackground(
        dense: dense,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 480
                ? 480.0
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.12),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 21),
        ),
      ),
    );
  }
}
