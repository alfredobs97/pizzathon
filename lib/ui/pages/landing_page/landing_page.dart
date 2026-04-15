import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pizzathon/ui/app_router.dart';
import 'package:pizzathon/ui/blocs/auth_cubit.dart';
import 'package:pizzathon/ui/blocs/auth_state.dart';
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
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.participantsRoute);
        }
      },
      child: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBanner(),
              HeroSection(),
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
