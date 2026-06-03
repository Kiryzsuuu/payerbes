import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/custom_hero.dart';
import '../../providers/admin_provider.dart';
import '../../theme/nyt_theme.dart';
import '../../widgets/nyt_header.dart';
import 'add_edit_hero_screen.dart';
import 'site_settings_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: NYTColors.black,
        foregroundColor: NYTColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddEditHeroScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: NYTSubpageHeader(section: 'Admin Panel'),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: NYTColors.sectionBlue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'ADMIN',
                              style: GoogleFonts.frankRuhlLibre(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${admin.customHeroes.length} hero tersimpan di database',
                            style: GoogleFonts.sourceSerif4(
                                fontSize: 12, color: NYTColors.darkGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SiteSettingsScreen()),
                        ),
                        icon: const Icon(Icons.tune_outlined,
                            size: 16, color: NYTColors.black),
                        label: Text(
                          'PENGATURAN SITUS',
                          style: GoogleFonts.frankRuhlLibre(
                              fontSize: 11,
                              color: NYTColors.black,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: NYTColors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              if (admin.customHeroes.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 56, color: NYTColors.midGrey),
                        const SizedBox(height: 16),
                        Text('Belum ada hero',
                            style: GoogleFonts.unna(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: NYTColors.black)),
                        const SizedBox(height: 8),
                        Text('Tap tombol + untuk menambah hero baru',
                            style: GoogleFonts.sourceSerif4(
                                fontSize: 13,
                                color: NYTColors.darkGrey,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Seret  ≡  untuk mengatur urutan section',
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 11,
                          color: NYTColors.darkGrey,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              if (admin.customHeroes.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverReorderableList(
                    itemCount: admin.customHeroes.length,
                    onReorder: admin.reorderHeroes,
                    itemBuilder: (context, i) {
                      final hero = admin.customHeroes[i];
                      final sectionLabel = i == 0
                          ? 'Today\'s Feature'
                          : i <= 2
                              ? 'In The News'
                              : 'Also Reported';
                      return ReorderableDragStartListener(
                        key: ValueKey(hero.id),
                        index: i,
                        child: _HeroAdminCard(
                          hero: hero,
                          sectionLabel: sectionLabel,
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddEditHeroScreen(hero: hero)),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, admin, hero),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AdminProvider admin, CustomHero hero) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NYTColors.white,
        title: Text('Hapus Hero',
            style: GoogleFonts.unna(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NYTColors.black)),
        content: Text(
            'Yakin ingin menghapus "${hero.name}" dari database?',
            style: GoogleFonts.sourceSerif4(
                fontSize: 14, color: NYTColors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style:
                    GoogleFonts.frankRuhlLibre(color: NYTColors.darkGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus',
                style: GoogleFonts.frankRuhlLibre(
                    color: NYTColors.accent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) await admin.deleteHero(hero.id!);
  }
}

class _HeroAdminCard extends StatelessWidget {
  final CustomHero hero;
  final String sectionLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HeroAdminCard({
    required this.hero,
    required this.sectionLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final alignColor = hero.alignment == 'good'
        ? NYTColors.sectionBlue
        : hero.alignment == 'bad'
            ? NYTColors.accent
            : NYTColors.gold;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: NYTColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: NYTColors.midGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                width: 72,
                height: 80,
                child: hero.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: hero.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          color: NYTColors.lightGrey,
                          child: const Icon(Icons.person,
                              color: NYTColors.midGrey),
                        ),
                      )
                    : Container(
                        color: NYTColors.lightGrey,
                        child: const Icon(Icons.person,
                            color: NYTColors.midGrey),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        color: alignColor,
                        child: Text(
                          hero.alignment.toUpperCase(),
                          style: GoogleFonts.frankRuhlLibre(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hero.publisher,
                          style: GoogleFonts.frankRuhlLibre(
                              fontSize: 10, color: NYTColors.darkGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.name,
                    style: GoogleFonts.unna(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: NYTColors.black),
                  ),
                  if (hero.description.isNotEmpty)
                    Text(
                      hero.description,
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 11,
                          color: NYTColors.darkGrey,
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: NYTColors.midGrey),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '📌 $sectionLabel',
                      style: GoogleFonts.frankRuhlLibre(
                          fontSize: 9,
                          color: NYTColors.darkGrey,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                const Icon(Icons.drag_handle,
                    size: 20, color: NYTColors.midGrey),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: NYTColors.sectionBlue),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: NYTColors.accent),
                  onPressed: onDelete,
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
