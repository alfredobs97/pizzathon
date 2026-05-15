import 'dart:async';
import 'package:flutter/material.dart';

class RankingAnxietyCountdown extends StatefulWidget {
  const RankingAnxietyCountdown({super.key});

  @override
  State<RankingAnxietyCountdown> createState() => _RankingAnxietyCountdownState();
}

class _RankingAnxietyCountdownState extends State<RankingAnxietyCountdown>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _calculateTimeLeft();
    // Actualizar cada 10ms para el efecto de milisegundos frenético
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        _calculateTimeLeft();
      }
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    int nextMinute = (now.minute < 30) ? 30 : 60;

    final nextRefresh = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(Duration(minutes: nextMinute));

    if (mounted) {
      setState(() {
        _timeLeft = nextRefresh.difference(now);
        if (_timeLeft.isNegative) {
          _timeLeft = Duration.zero;
        }
      });
    }

    // Acelerar drásticamente si queda poco tiempo (< 5 min)
    final bool isLowTime = _timeLeft.inMinutes < 5;
    final targetDuration = isLowTime
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: 1200);

    if (_pulseController.duration != targetDuration) {
      _pulseController.duration = targetDuration;
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');
    // Mostrar dos dígitos de milisegundos (centisegundos) para máxima velocidad
    final millis = (_timeLeft.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EL RANKING SE ACTUALIZA EN:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                // Usamos una fila fija para que los números no bailen
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '.$millis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
