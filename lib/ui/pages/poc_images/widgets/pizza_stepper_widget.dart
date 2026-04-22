import 'dart:math' as math;
import 'package:flutter/material.dart';

class PizzaStepperWidget extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Set<int> confirmedSteps;
  final Color activeColor;
  final Color crustColor;
  final Color inactiveColor;

  const PizzaStepperWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.confirmedSteps,
    required this.activeColor,
    required this.crustColor,
    required this.inactiveColor,
  });

  @override
  State<PizzaStepperWidget> createState() => _PizzaStepperWidgetState();
}

class _PizzaStepperWidgetState extends State<PizzaStepperWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: PizzaSlicesPainter(
            currentStep: widget.currentStep,
            totalSteps: widget.totalSteps,
            confirmedSteps: widget.confirmedSteps,
            activeColor: widget.activeColor,
            crustColor: widget.crustColor,
            inactiveColor: widget.inactiveColor,
            pulseValue: _pulseAnimation.value,
          ),
        );
      },
    );
  }
}

class PizzaSlicesPainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Set<int> confirmedSteps;
  final Color activeColor;
  final Color crustColor;
  final Color inactiveColor;
  final double pulseValue;

  PizzaSlicesPainter({
    required this.currentStep,
    required this.totalSteps,
    required this.confirmedSteps,
    required this.activeColor,
    required this.crustColor,
    required this.inactiveColor,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const gap = 0.12; // Separación entre porciones
    final sliceAngle = (2 * math.pi) / totalSteps;

    final paint = Paint()..style = PaintingStyle.fill;

    final crustPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < totalSteps; i++) {
      final isConfirmed = confirmedSteps.contains(i);
      final isCurrent = i == currentStep;

      final startAngle = (i * sliceAngle) - (math.pi / 2) + (gap / 2);
      final sweepAngle = sliceAngle - gap;

      // 1. Dibujar la porción (base/queso)
      if (isConfirmed) {
        paint.color = activeColor;
      } else if (isCurrent) {
        paint.color = activeColor.withValues(alpha: pulseValue * 0.7);
      } else {
        paint.color = inactiveColor;
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.85),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 2. Dibujar el borde exterior (la masa/crust)
      if (isConfirmed) {
        crustPaint.color = crustColor;
      } else if (isCurrent) {
        crustPaint.color = crustColor.withValues(alpha: pulseValue);
      } else {
        crustPaint.color = inactiveColor.withAlpha(80);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.85),
        startAngle,
        sweepAngle,
        false,
        crustPaint,
      );

      // 3. Magia: Añadir "pepperoni" si está confirmada
      if (isConfirmed) {
        final pepAngle = startAngle + (sweepAngle / 2);
        final pepRadius = radius * 0.55;
        final pepCenter = Offset(
          center.dx + pepRadius * math.cos(pepAngle),
          center.dy + pepRadius * math.sin(pepAngle),
        );

        final pepPaint = Paint()
          ..color = Colors.white.withAlpha(160)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pepCenter, radius * 0.12, pepPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PizzaSlicesPainter oldDelegate) {
    return oldDelegate.currentStep != currentStep ||
        oldDelegate.confirmedSteps.length != confirmedSteps.length ||
        oldDelegate.pulseValue != pulseValue;
  }
}
