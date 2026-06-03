import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/site_settings_provider.dart';
import '../theme/nyt_theme.dart';

// ── Header penuh untuk halaman utama (dengan tanggal & tagline) ──────────────
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
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
    final s = context.watch<SiteSettingsProvider>().settings;

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
                  s.siteTitle,
                  style: GoogleFonts.unna(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: NYTColors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.tagline.toUpperCase(),
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

// ── Header ringkas untuk subpage (Search, Favorites, Profile) ────────────────
class NYTSubpageHeader extends StatelessWidget {
  final String section; // label section di bawah masthead

  const NYTSubpageHeader({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: NYTColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'The Hero Times',
              style: GoogleFonts.unna(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: NYTColors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 3, color: NYTColors.black),
            const SizedBox(height: 2),
            const Divider(thickness: 1, color: NYTColors.black),
            const SizedBox(height: 8),
            // Section label berwarna bawah masthead
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: NYTColors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Text(
                    section.toUpperCase(),
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 11,
                      color: NYTColors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Label section dengan garis (dipakai di semua halaman) ────────────────────
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
          const Expanded(
              child: Divider(color: NYTColors.black, thickness: 1)),
        ],
      ),
    );
  }
}
