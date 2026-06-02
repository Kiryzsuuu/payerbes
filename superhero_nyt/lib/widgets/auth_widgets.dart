import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nyt_theme.dart';

class AuthMasthead extends StatelessWidget {
  const AuthMasthead({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NYTColors.accent.withValues(alpha: 0.08),
        border: Border.all(color: NYTColors.accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: NYTColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.sourceSerif4(
                  fontSize: 13, color: NYTColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthSuccessBanner extends StatelessWidget {
  final String message;
  const AuthSuccessBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.sourceSerif4(
                  fontSize: 13, color: Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const AuthPrimaryButton(
      {super.key,
      required this.label,
      required this.loading,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: NYTColors.black,
          foregroundColor: NYTColors.white,
          disabledBackgroundColor: NYTColors.midGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: GoogleFonts.frankRuhlLibre(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const AuthGoogleButton(
      {super.key, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: NYTColors.black,
          side: const BorderSide(color: NYTColors.midGrey),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.google.com/favicon.ico',
              width: 18,
              height: 18,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.g_mobiledata, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Lanjutkan dengan Google',
              style: GoogleFonts.sourceSerif4(
                  fontSize: 14, color: NYTColors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthBottomLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;
  const AuthBottomLink(
      {super.key,
      required this.question,
      required this.action,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.sourceSerif4(
              fontSize: 13, color: NYTColors.darkGrey),
          children: [
            TextSpan(text: question),
            TextSpan(
              text: action,
              style: const TextStyle(
                color: NYTColors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
