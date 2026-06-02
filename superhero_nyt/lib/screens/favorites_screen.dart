import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/superhero_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/nyt_header.dart';
import '../theme/nyt_theme.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer<SuperheroProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        Text(
                          'The Hero Times',
                          style: GoogleFonts.unna(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: NYTColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(thickness: 2, color: NYTColors.black),
                        const SizedBox(height: 2),
                        const Divider(thickness: 1, color: NYTColors.black),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.loadingFavorites)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: NYTColors.black, strokeWidth: 2),
                  ),
                )
              else if (provider.favoriteHeroes.isEmpty)
                SliverFillRemaining(child: _EmptyFavorites())
              else ...[
                SliverToBoxAdapter(
                  child: SectionLabel(
                      'Saved Â· ${provider.favoriteHeroes.length} articles'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final hero = provider.favoriteHeroes[i];
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Dismissible(
                                key: Key(hero.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: NYTColors.accent,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.bookmark_remove,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) =>
                                    provider.toggleFavorite(hero),
                                child: HeroCardSmall(
                                  hero: hero,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            DetailScreen(hero: hero)),
                                  ),
                                ),
                              ),
                            ),
                            if (i < provider.favoriteHeroes.length - 1)
                              const Divider(color: NYTColors.midGrey),
                          ],
                        );
                      },
                      childCount: provider.favoriteHeroes.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: NYTColors.midGrey),
            const SizedBox(height: 16),
            Text(
              'Your Reading List',
              style: GoogleFonts.unna(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: NYTColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved articles will appear here.\nTap the bookmark icon on any hero.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSerif4(
                fontSize: 14,
                color: NYTColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

