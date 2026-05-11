import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
import 'package:pizzathon/ui/blocs/enrollment_cubit.dart';
import 'package:pizzathon/ui/pages/landing_page/widgets/main_sponsor_section.dart';
import 'package:pizzathon/ui/widgets/footer.dart';
import 'package:pizzathon/ui/widgets/top_banner.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_section.dart';
import 'widgets/team_section.dart';
import 'widgets/sponsor_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous is AuthLoading && current is AuthAuthenticated,
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          await context.read<EnrollmentCubit>().checkUserEnrollment();
          if (context.mounted) {
            context.go(AppRouter.profileRoute);
          }
        }
      },
      child: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CountdownTopBanner(),
              HeroSection(),
              MainSponsorSection(),
              InfoSection(),
              TeamSection(),
              SponsorSection(),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
