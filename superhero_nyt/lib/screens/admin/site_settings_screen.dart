import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/site_settings.dart';
import '../../providers/site_settings_provider.dart';
import '../../theme/nyt_theme.dart';
import '../../widgets/nyt_header.dart';

class SiteSettingsScreen extends StatefulWidget {
  const SiteSettingsScreen({super.key});

  @override
  State<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends State<SiteSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _sec1Ctrl;
  late TextEditingController _sec2Ctrl;
  late TextEditingController _sec3Ctrl;
  bool _showApiHeroes = true;
  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _sec1Ctrl.dispose();
    _sec2Ctrl.dispose();
    _sec3Ctrl.dispose();
    super.dispose();
  }

  void _init(SiteSettings s) {
    if (_initialized) return;
    _titleCtrl = TextEditingController(text: s.siteTitle);
    _taglineCtrl = TextEditingController(text: s.tagline);
    _sec1Ctrl = TextEditingController(text: s.section1Label);
    _sec2Ctrl = TextEditingController(text: s.section2Label);
    _sec3Ctrl = TextEditingController(text: s.section3Label);
    _showApiHeroes = s.showApiHeroes;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NYTColors.white,
      body: Consumer<SiteSettingsProvider>(
        builder: (context, provider, _) {
          _init(provider.settings);
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: NYTSubpageHeader(section: 'Site Settings'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionDivider('Identitas Situs'),
                        _field('Judul Situs', _titleCtrl),
                        const SizedBox(height: 12),
                        _field('Tagline', _taglineCtrl),
                        const SizedBox(height: 24),

                        _SectionDivider('Label Section Front Page'),
                        _field('Section 1 (Featured besar)', _sec1Ctrl),
                        const SizedBox(height: 12),
                        _field('Section 2 (Dua kolom)', _sec2Ctrl),
                        const SizedBox(height: 12),
                        _field('Section 3 (Daftar bawah)', _sec3Ctrl),
                        const SizedBox(height: 24),

                        _SectionDivider('Konten'),
                        _ToggleRow(
                          label: 'Tampilkan hero dari API eksternal',
                          subtitle:
                              'Matikan untuk hanya menampilkan hero buatan admin',
                          value: _showApiHeroes,
                          onChanged: (v) => setState(() => _showApiHeroes = v),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.saving ? null : () => _save(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NYTColors.black,
                              foregroundColor: NYTColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                            child: provider.saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: NYTColors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'SIMPAN PERUBAHAN',
                                    style: GoogleFonts.frankRuhlLibre(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.frankRuhlLibre(
              fontSize: 10,
              color: NYTColors.darkGrey,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.sourceSerif4(fontSize: 14, color: NYTColors.black),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Tidak boleh kosong' : null,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                borderSide: BorderSide(color: NYTColors.midGrey)),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                borderSide: BorderSide(color: NYTColors.midGrey)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                borderSide: BorderSide(color: NYTColors.black, width: 2)),
          ),
        ),
      ],
    );
  }

  Future<void> _save(SiteSettingsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    final updated = SiteSettings(
      siteTitle: _titleCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      section1Label: _sec1Ctrl.text.trim(),
      section2Label: _sec2Ctrl.text.trim(),
      section3Label: _sec3Ctrl.text.trim(),
      showApiHeroes: _showApiHeroes,
    );
    final ok = await provider.save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? NYTColors.black : NYTColors.accent,
      content: Text(
        ok ? 'Pengaturan berhasil disimpan' : 'Gagal menyimpan pengaturan',
        style: GoogleFonts.sourceSerif4(color: NYTColors.white),
      ),
    ));
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            color: NYTColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.frankRuhlLibre(
                  fontSize: 10,
                  color: NYTColors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: NYTColors.black, thickness: 1)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.sourceSerif4(
                      fontSize: 14, color: NYTColors.black)),
              Text(subtitle,
                  style: GoogleFonts.sourceSerif4(
                      fontSize: 12,
                      color: NYTColors.darkGrey,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: NYTColors.black,
        ),
      ],
    );
  }
}
