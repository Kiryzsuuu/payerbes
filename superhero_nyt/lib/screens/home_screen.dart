import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/superhero_provider.dart';
import '../providers/site_settings_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/nyt_header.dart';
import '../theme/nyt_theme.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer2<SuperheroProvider, SiteSettingsProvider>(
        builder: (context, provider, settingsProvider, _) {
          final settings = settingsProvider.settings;
          final heroes = settings.showApiHeroes
              ? provider.featured
              : provider.featured
                  .where((h) => provider.customHeroIds.contains(h.id))
                  .toList();
          return RefreshIndicator(
            color: NYTColors.black,
            onRefresh: provider.loadFeatured,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: NYTHeader()),
                if (provider.loadingFeatured)
                  const SliverFillRemaining(child: _LoadingView())
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: _ErrorView(
                      message: provider.error!,
                      onRetry: provider.loadFeatured,
                    ),
                  )
                else
                  _HeroContent(
                    heroes: heroes,
                    sec1: settings.section1Label,
                    sec2: settings.section2Label,
                    sec3: settings.section3Label,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final List heroes;
  final String sec1;
  final String sec2;
  final String sec3;
  const _HeroContent({
    required this.heroes,
    this.sec1 = "Today's Feature",
    this.sec2 = 'In The News',
    this.sec3 = 'Also Reported',
  });

  @override
  Widget build(BuildContext context) {
    if (heroes.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No heroes found.'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Featured hero (full width)
        SectionLabel(sec1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HeroCardLarge(
            hero: heroes[0],
            onTap: () => _goToDetail(context, heroes[0]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: NYTColors.midGrey),
        ),

        // Two-column middle row
        if (heroes.length > 2) ...[
          SectionLabel(sec2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HeroCardLarge(
                    hero: heroes[1],
                    onTap: () => _goToDetail(context, heroes[1]),
                  ),
                ),
                const SizedBox(
                  width: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: NYTColors.midGrey),
                    child: SizedBox(height: double.infinity),
                  ),
                ),
                Expanded(
                  child: HeroCardLarge(
                    hero: heroes[2],
                    onTap: () => _goToDetail(context, heroes[2]),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: NYTColors.black, thickness: 2),
        ),

        // Briefs list
        if (heroes.length > 3) ...[
          SectionLabel(sec3),
          ...List.generate(
            heroes.length - 3,
            (i) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: HeroCardSmall(
                      hero: heroes[i + 3],
                      onTap: () => _goToDetail(context, heroes[i + 3]),
                    ),
                  ),
                  if (i < heroes.length - 4)
                    const Divider(color: NYTColors.midGrey),
                ],
              ),
            ),
          ),
        ],
      ]),
    );
  }

  void _goToDetail(BuildContext context, dynamic hero) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(hero: hero)),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: NYTColors.black, strokeWidth: 2),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: NYTColors.darkGrey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: NYTColors.darkGrey)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: NYTColors.black),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

