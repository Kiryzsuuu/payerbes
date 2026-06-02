import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/nyt_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegister = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer<ap.AuthProvider>(
        builder: (context, auth, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // ── Masthead ──────────────────────────────
                    Text(
                      'The Hero Times',
                      style: GoogleFonts.unna(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: NYTColors.black,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ALL THE SUPERHERO NEWS THAT\'S FIT TO PRINT',
                      style: GoogleFonts.frankRuhlLibre(
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: NYTColors.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 3, color: NYTColors.black),
                    const SizedBox(height: 2),
                    const Divider(thickness: 1, color: NYTColors.black),
                    const SizedBox(height: 36),

                    // ── Section title ─────────────────────────
                    Text(
                      _isRegister ? 'CREATE ACCOUNT' : 'SIGN IN',
                      style: GoogleFonts.frankRuhlLibre(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: NYTColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRegister
                          ? 'Join our network of hero enthusiasts'
                          : 'Welcome back, valued reader',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        color: NYTColors.darkGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Email field ───────────────────────────
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon:
                            Icon(Icons.mail_outline, color: NYTColors.darkGrey),
                      ),
                      style: GoogleFonts.sourceSerif4(fontSize: 14),
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Password field ────────────────────────
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: NYTColors.darkGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: NYTColors.darkGrey,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      style: GoogleFonts.sourceSerif4(fontSize: 14),
                      validator: (v) => v == null || v.length < 6
                          ? 'Minimal 6 karakter'
                          : null,
                    ),

                    // ── Error message ─────────────────────────
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NYTColors.accent.withValues(alpha: 0.08),
                          border: Border.all(color: NYTColors.accent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: NYTColors.accent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 13,
                                  color: NYTColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Email submit button ───────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: auth.loading ? null : _submitEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NYTColors.black,
                          foregroundColor: NYTColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: auth.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isRegister ? 'BUAT AKUN' : 'MASUK',
                                style: GoogleFonts.frankRuhlLibre(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Divider OR ────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: NYTColors.midGrey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: GoogleFonts.frankRuhlLibre(
                              fontSize: 11,
                              color: NYTColors.darkGrey,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: NYTColors.midGrey)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Google Sign-In ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: auth.loading ? null : _signInGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NYTColors.black,
                          side: const BorderSide(color: NYTColors.midGrey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 18,
                          height: 18,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.g_mobiledata, size: 20),
                        ),
                        label: Text(
                          'Lanjutkan dengan Google',
                          style: GoogleFonts.sourceSerif4(
                              fontSize: 14, color: NYTColors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Toggle login/register ─────────────────
                    GestureDetector(
                      onTap: () => setState(() => _isRegister = !_isRegister),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.sourceSerif4(
                              fontSize: 13, color: NYTColors.darkGrey),
                          children: [
                            TextSpan(
                              text: _isRegister
                                  ? 'Sudah punya akun? '
                                  : 'Belum punya akun? ',
                            ),
                            TextSpan(
                              text: _isRegister ? 'Masuk' : 'Daftar',
                              style: const TextStyle(
                                color: NYTColors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    final success = _isRegister
        ? await auth.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text)
        : await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    if (!success && mounted) {
      // error sudah ditampilkan via auth.error
    }
  }

  Future<void> _signInGoogle() async {
    await context.read<ap.AuthProvider>().signInWithGoogle();
  }
}
