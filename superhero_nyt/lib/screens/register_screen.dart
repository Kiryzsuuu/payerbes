import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/nyt_theme.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      appBar: AppBar(
        backgroundColor: NYTColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NYTColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                    const SizedBox(height: 16),
                    const AuthMasthead(),
                    const SizedBox(height: 32),

                    Text(
                      'CREATE ACCOUNT',
                      style: GoogleFonts.frankRuhlLibre(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: NYTColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join our network of hero enthusiasts',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        color: NYTColors.darkGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline,
                            color: NYTColors.darkGrey),
                      ),
                      style: GoogleFonts.sourceSerif4(fontSize: 14),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Email tidak valid'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: NYTColors.darkGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: NYTColors.darkGrey,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      style: GoogleFonts.sourceSerif4(fontSize: 14),
                      validator: (v) => v == null || v.length < 6
                          ? 'Minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Konfirmasi password
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: NYTColors.darkGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: NYTColors.darkGrey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      style: GoogleFonts.sourceSerif4(fontSize: 14),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v != _passCtrl.text) return 'Password tidak sama';
                        return null;
                      },
                    ),

                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      AuthErrorBanner(message: auth.error!),
                    ],

                    const SizedBox(height: 24),

                    AuthPrimaryButton(
                      label: 'BUAT AKUN',
                      loading: auth.loading,
                      onPressed: () => _submit(auth),
                    ),
                    const SizedBox(height: 20),
                    const AuthOrDivider(),
                    const SizedBox(height: 16),

                    AuthGoogleButton(
                      loading: auth.loading,
                      onPressed: () => auth.signInWithGoogle(),
                    ),
                    const SizedBox(height: 32),

                    AuthBottomLink(
                      question: 'Sudah punya akun? ',
                      action: 'Masuk',
                      onTap: () => Navigator.pop(context),
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

  Future<void> _submit(ap.AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await auth.registerWithEmail(
        _emailCtrl.text.trim(), _passCtrl.text);
    if (success && mounted) Navigator.pop(context);
  }
}
