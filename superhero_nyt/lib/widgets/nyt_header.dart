import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nyt_theme.dart';

class NYTHeader extends StatelessWidget {
  const NYTHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';

    return SafeArea(
      bottom: false,
      child: Column(
      children: [
        Container(
          color: NYTColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Text(
                dateStr,
                style: GoogleFonts.frankRuhlLibre(
                  fontSize: 11,
                  color: NYTColors.darkGrey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The Hero Times',
                style: GoogleFonts.unna(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: NYTColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ALL THE SUPERHERO NEWS THAT\'S FIT TO PRINT',
                style: GoogleFonts.frankRuhlLibre(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: NYTColors.darkGrey,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 3, color: NYTColors.black),
              const SizedBox(height: 2),
              const Divider(thickness: 1, color: NYTColors.black),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Container(
            color: NYTColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.frankRuhlLibre(
                fontSize: 11,
                color: NYTColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: NYTColors.black, thickness: 1)),
        ],
      ),
    );
  }
}

