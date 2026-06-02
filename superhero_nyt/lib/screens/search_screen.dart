import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/superhero_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/nyt_header.dart';
import '../theme/nyt_theme.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer<SuperheroProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Subpage Header konsisten NYT ───────────────
              const NYTSubpageHeader(section: 'Search Archives'),

              // ── Search field ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (q) => provider.search(q),
                  onChanged: (q) {
                    if (q.length >= 3) provider.search(q);
                    if (q.isEmpty) provider.search('');
                    setState(() {}); // rebuild untuk show/hide clear button
                  },
                  decoration: InputDecoration(
                    hintText: 'Search heroes & villains...',
                    hintStyle: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        color: NYTColors.darkGrey,
                        fontStyle: FontStyle.italic),
                    prefixIcon: const Icon(Icons.search,
                        color: NYTColors.darkGrey, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: NYTColors.darkGrey, size: 18),
                            onPressed: () {
                              _controller.clear();
                              provider.search('');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  style: GoogleFonts.sourceSerif4(
                      fontSize: 14, color: NYTColors.black),
                  textInputAction: TextInputAction.search,
                ),
              ),

              // ── Hasil pencarian ────────────────────────────
              Expanded(child: _buildResults(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, SuperheroProvider provider) {
    if (provider.loadingSearch) {
      return const Center(
        child: CircularProgressIndicator(
            color: NYTColors.black, strokeWidth: 2),
      );
    }

    if (provider.searchQuery.isEmpty) return const _EmptySearch();

    if (provider.searchResults.isEmpty) {
      return _NoResults(query: provider.searchQuery);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
            '${provider.searchResults.length} results for "${provider.searchQuery}"'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: provider.searchResults.length,
            separatorBuilder: (_, _) =>
                const Divider(color: NYTColors.midGrey),
            itemBuilder: (context, i) {
              final hero = provider.searchResults[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: HeroCardSmall(
                  hero: hero,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(hero: hero)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 56, color: NYTColors.midGrey),
            const SizedBox(height: 16),
            Text(
              'Search Our Archives',
              style: GoogleFonts.unna(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: NYTColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find any superhero or villain\nfrom the universe.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSerif4(
                fontSize: 14,
                color: NYTColors.darkGrey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.newspaper, size: 56, color: NYTColors.midGrey),
            const SizedBox(height: 16),
            Text(
              'Nothing Found',
              style: GoogleFonts.unna(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: NYTColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "$query".\nTry a different name.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSerif4(
                fontSize: 14,
                color: NYTColors.darkGrey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
