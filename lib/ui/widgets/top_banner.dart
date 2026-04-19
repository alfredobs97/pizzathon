import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/blocs/enrollment_state.dart';

class BaseTopBanner extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final bool showIcons;

  const BaseTopBanner({super.key, required this.child, this.showIcons = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (42 / 1440)),
      color: Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (showIcons)
            Positioned(
              right: 0,
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    final enrollmentState = context.watch<EnrollmentCubit>().state;
                    final isEnrolled =
                        enrollmentState is EnrollmentStatusChecked && enrollmentState.isEnrolled;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.user.isAdmin)
                          IconButton(
                            icon: Icon(
                              Icons.admin_panel_settings,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => context.go(AppRouter.adminRoute),
                            tooltip: 'Admin Console',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (isEnrolled) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => context.go(AppRouter.profileRoute),
                            icon: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TopBanner extends StatelessWidget implements PreferredSizeWidget {
  const TopBanner({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BaseTopBanner(
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
  const CountdownTopBanner({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CountdownTopBanner> createState() => _CountdownTopBannerState();
}

class _CountdownTopBannerState extends State<CountdownTopBanner> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  // May 11, 2026, 12:00 Spanish time (CEST) = 10:00 UTC
  final DateTime _targetDate = DateTime.utc(2026, 5, 11, 10, 0, 0);

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

    return BaseTopBanner(
      child: Text(
        'Quedan $days dias $hours horas $minutes minutos',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
