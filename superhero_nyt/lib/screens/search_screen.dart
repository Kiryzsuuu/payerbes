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
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        'The Hero Times',
                        style: GoogleFonts.unna(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: NYTColors.black,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Divider(thickness: 2, color: NYTColors.black),
                          SizedBox(height: 2),
                          Divider(thickness: 1, color: NYTColors.black),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (q) => provider.search(q),
                        onChanged: (q) {
                          if (q.length >= 3) provider.search(q);
                          if (q.isEmpty) provider.search('');
                        },
                        decoration: InputDecoration(
                          hintText: 'Search heroes, villains...',
                          prefixIcon: const Icon(Icons.search,
                              color: NYTColors.darkGrey, size: 20),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: NYTColors.darkGrey, size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    provider.search('');
                                  },
                                )
                              : null,
                        ),
                        style: GoogleFonts.sourceSerif4(fontSize: 14),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: _buildResults(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, SuperheroProvider provider) {
    if (provider.loadingSearch) {
      return const Center(
        child:
            CircularProgressIndicator(color: NYTColors.black, strokeWidth: 2),
      );
    }

    if (provider.searchQuery.isEmpty) {
      return _EmptySearch();
    }

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
            separatorBuilder: (_, __) =>
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: NYTColors.midGrey),
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
            ),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.newspaper, size: 64, color: NYTColors.midGrey),
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
            ),
          ),
        ],
      ),
    );
  }
}

