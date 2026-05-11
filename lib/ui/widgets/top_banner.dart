import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/widgets/app_shell.dart';

class BaseTopBanner extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final List<Widget>? actions;

  const BaseTopBanner({super.key, required this.child, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (42 / 1440)),
      color: colorScheme.secondary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (actions != null) ...actions!,
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return IconButton(
                      icon: Icon(Icons.menu, color: colorScheme.onPrimary),
                      onPressed: () {
                        AppShell.openDrawer();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopBanner extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const TopBanner({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BaseTopBanner(
      actions: actions,
      child: Text(
        'Buscamos 100 MEJORES talentos en Pizza',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class CountdownTopBanner extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const CountdownTopBanner({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CountdownTopBanner> createState() => _CountdownTopBannerState();
}

class _CountdownTopBannerState extends State<CountdownTopBanner> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  // May 18, 2026, 12:00 Spanish time (CEST) = 10:00 UTC
  final DateTime _targetDate = DateTime.utc(2026, 5, 18, 10, 0, 0);

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now().toUtc();
    setState(() {
      _timeLeft = _targetDate.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;

    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return BaseTopBanner(
      actions: widget.actions,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pizzathon finaliza en',
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          Text(
            '$days DÍAS · $hours H · $minutes M',
            textAlign: TextAlign.center,
            style: textStyle?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
