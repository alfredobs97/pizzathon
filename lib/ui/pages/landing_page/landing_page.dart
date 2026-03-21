import 'package:flutter/material.dart';
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
    return const Scaffold(
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
    );
  }
}
