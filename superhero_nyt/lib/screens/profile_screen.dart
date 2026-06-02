import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/nyt_theme.dart';
import '../widgets/nyt_header.dart';
import 'userdisplayname_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _activeUser;

  // getCurrentUser — pola sama seperti di modul (clue no.3 & 6)
  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() => _activeUser = user);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _activeUser?.displayName;
    final email = _activeUser?.email ?? '';
    final photoUrl = _activeUser?.photoURL;
    final hasName =
        displayName != null && displayName.isNotEmpty;

    return Scaffold(
      backgroundColor: NYTColors.white,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────
          const SliverToBoxAdapter(
            child: NYTSubpageHeader(section: 'My Profile'),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                children: [
                  // ── Avatar ────────────────────────────────
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: NYTColors.black, width: 2),
                        ),
                        child: ClipOval(
                          child: photoUrl != null
                              ? Image.network(photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _defaultAvatar())
                              : _defaultAvatar(),
                        ),
                      ),
                      // Edit icon
                      GestureDetector(
                        onTap: () => _goToSetName(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: NYTColors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: NYTColors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Display name / prompt ──────────────────
                  if (hasName)
                    Text(
                      displayName,
                      style: GoogleFonts.unna(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: NYTColors.black,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _goToSetName(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: NYTColors.midGrey, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                size: 16, color: NYTColors.darkGrey),
                            const SizedBox(width: 6),
                            Text(
                              'Set your display name',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 13,
                                color: NYTColors.darkGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),

                  // Email
                  Text(
                    email,
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 12,
                      color: NYTColors.darkGrey,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(thickness: 2, color: NYTColors.black),
                ],
              ),
            ),
          ),

          // ── Menu items ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MenuItem(
                  icon: Icons.badge_outlined,
                  label: 'Edit Display Name',
                  subtitle: hasName ? displayName : 'Belum diset',
                  onTap: () => _goToSetName(context),
                ),
                const Divider(color: NYTColors.midGrey),
                _MenuItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  subtitle: email,
                  onTap: null,
                ),
                const Divider(color: NYTColors.midGrey),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  label: 'Provider',
                  subtitle: _activeUser?.providerData.isNotEmpty == true
                      ? _activeUser!.providerData.first.providerId
                      : '-',
                  onTap: null,
                ),
                const Divider(color: NYTColors.midGrey),
                const SizedBox(height: 16),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(
                      'SIGN OUT',
                      style: GoogleFonts.frankRuhlLibre(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NYTColors.accent,
                      side: const BorderSide(
                          color: NYTColors.accent, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _confirmSignOut(context),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // clue no.11 — Navigator.pushNamed + whenComplete + setState + getCurrentUser
  void _goToSetName(BuildContext context) {
    Navigator.pushNamed(context, UserDisplayNameScreen.id)
        .whenComplete(() => setState(() {
              getCurrentUser();
            }));
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NYTColors.white,
        title: Text(
          'Sign Out',
          style: GoogleFonts.unna(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: NYTColors.black),
        ),
        content: Text(
          'Yakin ingin keluar dari The Hero Times?',
          style: GoogleFonts.sourceSerif4(
              fontSize: 14, color: NYTColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: GoogleFonts.frankRuhlLibre(
                    color: NYTColors.darkGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out',
                style: GoogleFonts.frankRuhlLibre(
                    color: NYTColors.accent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ap.AuthProvider>().signOut();
    }
  }

  Widget _defaultAvatar() => Container(
        color: NYTColors.lightGrey,
        child: const Icon(Icons.person, size: 50, color: NYTColors.darkGrey),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: NYTColors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NYTColors.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 12,
                      color: NYTColors.darkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 18, color: NYTColors.darkGrey),
          ],
        ),
      ),
    );
  }
}
