import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/nyt_theme.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
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

                    // Icon kunci
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        border: Border.all(color: NYTColors.black, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.lock_reset,
                          size: 36, color: NYTColors.black),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'RESET PASSWORD',
                      style: GoogleFonts.frankRuhlLibre(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: NYTColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailSent
                          ? 'Email reset telah dikirim.\nCek inbox atau folder spam Anda.'
                          : 'Masukkan email yang terdaftar.\nKami akan mengirim link reset password.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        color: NYTColors.darkGrey,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (_emailSent) ...[
                      // State setelah email terkirim
                      AuthSuccessBanner(
                        message:
                            'Email reset dikirim ke ${_emailCtrl.text}. Cek inbox Anda.',
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: NYTColors.midGrey),
                      const SizedBox(height: 20),
                      Text(
                        'Tidak menerima email?',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 13,
                          color: NYTColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthPrimaryButton(
                        label: 'KIRIM ULANG',
                        loading: auth.loading,
                        onPressed: () => _sendReset(auth),
                      ),
                      const SizedBox(height: 16),
                      AuthBottomLink(
                        question: '',
                        action: '← Kembali ke Login',
                        onTap: () => Navigator.pop(context),
                      ),
                    ] else ...[
                      // Form email
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

                      if (auth.error != null) ...[
                        const SizedBox(height: 14),
                        AuthErrorBanner(message: auth.error!),
                      ],

                      const SizedBox(height: 24),

                      AuthPrimaryButton(
                        label: 'KIRIM RESET EMAIL',
                        loading: auth.loading,
                        onPressed: () => _sendReset(auth),
                      ),
                      const SizedBox(height: 28),

                      AuthBottomLink(
                        question: 'Ingat password? ',
                        action: 'Kembali masuk',
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
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

  Future<void> _sendReset(ap.AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final success =
        await auth.sendPasswordReset(_emailCtrl.text.trim());
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }
}
