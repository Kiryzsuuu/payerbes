import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/superhero.dart';
import '../providers/superhero_provider.dart';
import '../theme/nyt_theme.dart';

class DetailScreen extends StatelessWidget {
  final Superhero hero;
  const DetailScreen({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer<SuperheroProvider>(
        builder: (context, provider, _) {
          final isFav = provider.isFavorite(hero.id);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: NYTColors.white,
                foregroundColor: NYTColors.black,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.bookmark : Icons.bookmark_border,
                      color: isFav ? NYTColors.accent : NYTColors.black,
                    ),
                    onPressed: () => provider.toggleFavorite(hero),
                    tooltip: isFav ? 'Remove from saved' : 'Save article',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: hero.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: NYTColors.lightGrey,
                      child: const Icon(Icons.person,
                          size: 80, color: NYTColors.midGrey),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AlignmentBadge(hero.biography.alignment),
                      const SizedBox(height: 12),
                      Text(
                        hero.name,
                        style: GoogleFonts.unna(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: NYTColors.black,
                          height: 1.0,
                        ),
                      ),
                      if (hero.biography.fullName != '-') ...[
                        const SizedBox(height: 6),
                        Text(
                          '"${hero.biography.fullName}"',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 16,
                            color: NYTColors.darkGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${hero.biography.publisher} Â· ${hero.biography.firstAppearance}',
                        style: GoogleFonts.frankRuhlLibre(
                          fontSize: 12,
                          color: NYTColors.darkGrey,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 2, color: NYTColors.black),
                      const SizedBox(height: 20),

                      // Power Stats
                      _SectionTitle('Power Statistics'),
                      const SizedBox(height: 14),
                      _PowerStatsGrid(powerstats: hero.powerstats),

                      const SizedBox(height: 24),
                      const Divider(color: NYTColors.midGrey),
                      const SizedBox(height: 20),

                      // Biography
                      _SectionTitle('Biography'),
                      const SizedBox(height: 12),
                      _InfoRow('Full Name', hero.biography.fullName),
                      _InfoRow('Alter Egos', hero.biography.alterEgos),
                      _InfoRow('Place of Birth', hero.biography.placeOfBirth),
                      _InfoRow('Publisher', hero.biography.publisher),
                      _InfoRow(
                          'First Appearance', hero.biography.firstAppearance),

                      const SizedBox(height: 20),
                      const Divider(color: NYTColors.midGrey),
                      const SizedBox(height: 20),

                      // Appearance
                      _SectionTitle('Appearance'),
                      const SizedBox(height: 12),
                      _InfoRow('Gender', hero.appearance.gender),
                      _InfoRow('Race', hero.appearance.race),
                      _InfoRow('Height',
                          hero.appearance.height.join(' / ')),
                      _InfoRow('Weight',
                          hero.appearance.weight.join(' / ')),
                      _InfoRow('Eye Color', hero.appearance.eyeColor),
                      _InfoRow('Hair Color', hero.appearance.hairColor),

                      const SizedBox(height: 20),
                      const Divider(color: NYTColors.midGrey),
                      const SizedBox(height: 20),

                      // Work & Connections
                      _SectionTitle('Work & Affiliations'),
                      const SizedBox(height: 12),
                      _InfoRow('Occupation', hero.work.occupation),
                      _InfoRow('Base', hero.work.base),
                      _InfoRow('Group Affiliation',
                          hero.connections.groupAffiliation),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlignmentBadge extends StatelessWidget {
  final String alignment;
  const _AlignmentBadge(this.alignment);

  @override
  Widget build(BuildContext context) {
    final color = alignment.toLowerCase() == 'good'
        ? NYTColors.sectionBlue
        : alignment.toLowerCase() == 'bad'
            ? NYTColors.accent
            : NYTColors.gold;
    final label = alignment.toLowerCase() == 'good'
        ? 'HERO'
        : alignment.toLowerCase() == 'bad'
            ? 'VILLAIN'
            : 'NEUTRAL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: GoogleFonts.frankRuhlLibre(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.frankRuhlLibre(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: NYTColors.black,
        letterSpacing: 2,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.frankRuhlLibre(
                fontSize: 12,
                color: NYTColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sourceSerif4(
                fontSize: 13,
                color: NYTColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerStatsGrid extends StatelessWidget {
  final Powerstats powerstats;
  const _PowerStatsGrid({required this.powerstats});

  @override
  Widget build(BuildContext context) {
    final stats = {
      'Intelligence': powerstats.intelligence,
      'Strength': powerstats.strength,
      'Speed': powerstats.speed,
      'Durability': powerstats.durability,
      'Power': powerstats.power,
      'Combat': powerstats.combat,
    };

    return Column(
      children: stats.entries.map((entry) {
        final val = int.tryParse(entry.value) ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 11,
                      color: NYTColors.darkGrey,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '$val',
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NYTColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: val / 100,
                  backgroundColor: NYTColors.lightGrey,
                  color: _statColor(val),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _statColor(int val) {
    if (val >= 80) return NYTColors.black;
    if (val >= 50) return NYTColors.sectionBlue;
    return NYTColors.darkGrey;
  }
}

