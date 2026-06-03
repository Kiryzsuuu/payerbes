import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/superhero.dart';
import '../theme/nyt_theme.dart';

class HeroCardLarge extends StatelessWidget {
  final Superhero hero;
  final VoidCallback onTap;

  const HeroCardLarge({super.key, required this.hero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: NYTColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: hero.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => _shimmer(),
                errorWidget: (_, _, _) => _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                _getAlignmentTag(hero.biography.alignment),
                style: GoogleFonts.frankRuhlLibre(
                  fontSize: 11,
                  color: NYTColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                hero.name,
                style: GoogleFonts.unna(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: NYTColors.black,
                  height: 1.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Text(
                '${hero.biography.publisher} Â· ${hero.biography.firstAppearance}',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 13,
                  color: NYTColors.darkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: NYTColors.midGrey,
    highlightColor: NYTColors.lightGrey,
    child: Container(color: NYTColors.midGrey),
  );

  Widget _placeholder() => Container(
    color: NYTColors.lightGrey,
    child: const Icon(Icons.person, size: 60, color: NYTColors.midGrey),
  );

  String _getAlignmentTag(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'good':
        return 'HERO';
      case 'bad':
        return 'VILLAIN';
      default:
        return 'ANTI-HERO';
    }
  }
}

class HeroCardSmall extends StatelessWidget {
  final Superhero hero;
  final VoidCallback onTap;

  const HeroCardSmall({super.key, required this.hero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              width: 80,
              height: 90,
              child: CachedNetworkImage(
                imageUrl: hero.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: NYTColors.midGrey,
                  highlightColor: NYTColors.lightGrey,
                  child: Container(color: NYTColors.midGrey),
                ),
                errorWidget: (_, _, _) => Container(
                  color: NYTColors.lightGrey,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: NYTColors.midGrey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hero.name,
                  style: GoogleFonts.unna(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NYTColors.black,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hero.biography.publisher,
                  style: GoogleFonts.frankRuhlLibre(
                    fontSize: 11,
                    color: NYTColors.darkGrey,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hero.biography.fullName.isNotEmpty &&
                          hero.biography.fullName != '-'
                      ? '"${hero.biography.fullName}"'
                      : hero.biography.firstAppearance,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 12,
                    color: NYTColors.darkGrey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
