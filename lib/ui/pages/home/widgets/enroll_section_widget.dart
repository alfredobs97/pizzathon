import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pizzathon/ui/pages/home/widgets/enroll_button.dart';

class EnrollSectionWidget extends StatelessWidget {
  const EnrollSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PIZZATHON',
            style: GoogleFonts.climateCrisis(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 40,
              fontWeight: FontWeight.w400,
              height: 1.0,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          const EnrollButton(),
        ],
      ),
    );
  }
}
