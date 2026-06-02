import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nyt_theme.dart';

class UserDisplayNameScreen extends StatefulWidget {
  // Route ID — daftarkan di main.dart
  static const String id = '/set-display-name';

  const UserDisplayNameScreen({super.key});

  @override
  State<UserDisplayNameScreen> createState() => _UserDisplayNameScreenState();
}

class _UserDisplayNameScreenState extends State<UserDisplayNameScreen> {
  // Object Firebase Auth (sesuai clue no.3)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabel User Firebase (clue no.4)
  User? _activeUser;

  // Variabel untuk menyimpan nilai display name (clue no.5)
  dynamic _setDisplayName;

  final TextEditingController _controller = TextEditingController();

  // Method getCurrentUser (clue no.6)
  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _activeUser = user;
        // Isi field dengan nama yang sudah ada (jika ada)
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _controller.text = user.displayName!;
          _setDisplayName = user.displayName;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser(); // clue no.7
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // clue no.8 — nonaktifkan tombol back system Android dengan PopScope
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: NYTColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            // Widget tree sesuai PDF: Scaffold > Padding > Column
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header NYT ──────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'The Hero Times',
                          style: GoogleFonts.unna(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: NYTColors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CORRESPONDENT REGISTRATION',
                          style: GoogleFonts.frankRuhlLibre(
                            fontSize: 9,
                            letterSpacing: 2.5,
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
                  const SizedBox(height: 36),

                  // ── Ilustrasi ───────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: NYTColors.black, width: 2),
                        color: NYTColors.lightGrey,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 44,
                        color: NYTColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Text (label) ────────────────────────────
                  Text(
                    'SET YOUR BYLINE',
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: NYTColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Every great correspondent needs a name.\nHow shall readers know you?',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 13,
                      color: NYTColors.darkGrey,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── TextField ───────────────────────────────
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'e.g. Clark Kent, Bruce Wayne...',
                      labelText: 'Display Name',
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: NYTColors.darkGrey,
                      ),
                      filled: true,
                      fillColor: NYTColors.lightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(color: NYTColors.midGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(color: NYTColors.midGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: NYTColors.black, width: 1.5),
                      ),
                    ),
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 15, color: NYTColors.black),
                    // clue no.9 — simpan perubahan ke _setDisplayName
                    onChanged: (value) {
                      setState(() {
                        _setDisplayName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nama ini akan ditampilkan di profil Anda.',
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 11,
                      color: NYTColors.darkGrey,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Divider(color: NYTColors.midGrey),
                  const SizedBox(height: 20),

                  // ── Row of Buttons (clue widget tree) ───────
                  Row(
                    children: [
                      // RaisedButton Back
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NYTColors.black,
                            side: const BorderSide(
                                color: NYTColors.black, width: 1.5),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'BACK',
                            style: GoogleFonts.frankRuhlLibre(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // RaisedButton Submit (clue no.10)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NYTColors.black,
                            foregroundColor: NYTColors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          // clue no.10 — onPressed Submit
                          onPressed: () async {
                            try {
                              await _activeUser?.updateDisplayName(
                                  _setDisplayName);
                              if (_setDisplayName != null &&
                                  _setDisplayName.toString().isNotEmpty) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          child: Text(
                            'SUBMIT',
                            style: GoogleFonts.frankRuhlLibre(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
