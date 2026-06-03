import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/custom_hero.dart';
import '../../providers/admin_provider.dart';
import '../../theme/nyt_theme.dart';

class AddEditHeroScreen extends StatefulWidget {
  final CustomHero? hero; // null = add, non-null = edit

  const AddEditHeroScreen({super.key, this.hero});

  @override
  State<AddEditHeroScreen> createState() => _AddEditHeroScreenState();
}

class _AddEditHeroScreenState extends State<AddEditHeroScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get isEdit => widget.hero != null;

  late final TextEditingController _name;
  late final TextEditingController _imageUrl;
  late final TextEditingController _fullName;
  late final TextEditingController _publisher;
  late final TextEditingController _firstAppearance;
  late final TextEditingController _occupation;
  late final TextEditingController _groupAffiliation;
  late final TextEditingController _description;
  String _alignment = 'good';
  late int _intel, _str, _spd, _dur, _pow, _com;

  @override
  void initState() {
    super.initState();
    final h = widget.hero;
    _name = TextEditingController(text: h?.name ?? '');
    _imageUrl = TextEditingController(text: h?.imageUrl ?? '');
    _fullName = TextEditingController(text: h?.fullName ?? '');
    _publisher = TextEditingController(text: h?.publisher ?? '');
    _firstAppearance = TextEditingController(text: h?.firstAppearance ?? '');
    _occupation = TextEditingController(text: h?.occupation ?? '');
    _groupAffiliation = TextEditingController(text: h?.groupAffiliation ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _alignment = h?.alignment ?? 'good';
    _intel = h?.intelligence ?? 50;
    _str = h?.strength ?? 50;
    _spd = h?.speed ?? 50;
    _dur = h?.durability ?? 50;
    _pow = h?.power ?? 50;
    _com = h?.combat ?? 50;
  }

  @override
  void dispose() {
    for (final c in [_name, _imageUrl, _fullName, _publisher,
        _firstAppearance, _occupation, _groupAffiliation, _description]) {
      c.dispose();
    }
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
        title: Text(
          isEdit ? 'EDIT HERO' : 'ADD HERO',
          style: GoogleFonts.frankRuhlLibre(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: NYTColors.black,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Column(children: [
            Divider(thickness: 2, color: NYTColors.black, height: 2),
          ]),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('INFORMASI DASAR'),
                  const SizedBox(height: 12),
                  _field(_name, 'Nama Hero *', required: true),
                  _field(_fullName, 'Nama Asli (Full Name)'),
                  _field(_imageUrl, 'URL Gambar *',
                      hint: 'https://...', required: true),

                  // Preview gambar
                  if (_imageUrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        _imageUrl.text,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 80,
                          color: NYTColors.lightGrey,
                          child: const Center(
                            child: Text('URL gambar tidak valid'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _field(_publisher, 'Publisher',
                      hint: 'Marvel Comics / DC Comics'),
                  _field(_firstAppearance, 'First Appearance',
                      hint: 'Amazing Fantasy #15'),

                  // Alignment
                  const SizedBox(height: 8),
                  Text('Alignment',
                      style: GoogleFonts.frankRuhlLibre(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: NYTColors.darkGrey,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Row(
                    children: ['good', 'bad', 'neutral'].map((a) {
                      final selected = _alignment == a;
                      final color = a == 'good'
                          ? NYTColors.sectionBlue
                          : a == 'bad'
                              ? NYTColors.accent
                              : NYTColors.gold;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(a.toUpperCase(),
                              style: GoogleFonts.frankRuhlLibre(
                                  fontSize: 11,
                                  color: selected
                                      ? Colors.white
                                      : NYTColors.black,
                                  fontWeight: FontWeight.w700)),
                          selected: selected,
                          selectedColor: color,
                          backgroundColor: NYTColors.lightGrey,
                          onSelected: (_) =>
                              setState(() => _alignment = a),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: BorderSide(
                              color: selected ? color : NYTColors.midGrey),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: NYTColors.midGrey),
                  const SizedBox(height: 12),
                  _sectionTitle('DESKRIPSI'),
                  const SizedBox(height: 12),
                  _field(_description, 'Deskripsi / Latar Belakang',
                      maxLines: 4),
                  _field(_occupation, 'Pekerjaan / Occupation'),
                  _field(_groupAffiliation, 'Group / Affiliasi'),

                  const SizedBox(height: 20),
                  const Divider(color: NYTColors.midGrey),
                  const SizedBox(height: 12),
                  _sectionTitle('POWER STATS'),
                  const SizedBox(height: 16),
                  _statSlider('Intelligence', _intel,
                      (v) => setState(() => _intel = v)),
                  _statSlider('Strength', _str,
                      (v) => setState(() => _str = v)),
                  _statSlider('Speed', _spd,
                      (v) => setState(() => _spd = v)),
                  _statSlider('Durability', _dur,
                      (v) => setState(() => _dur = v)),
                  _statSlider('Power', _pow,
                      (v) => setState(() => _pow = v)),
                  _statSlider('Combat', _com,
                      (v) => setState(() => _com = v)),

                  const SizedBox(height: 24),

                  if (admin.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NYTColors.accent.withValues(alpha: 0.08),
                          border: Border.all(color: NYTColors.accent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(admin.error!,
                            style: GoogleFonts.sourceSerif4(
                                fontSize: 13, color: NYTColors.accent)),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: admin.loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NYTColors.black,
                        foregroundColor: NYTColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: admin.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH HERO',
                              style: GoogleFonts.frankRuhlLibre(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.frankRuhlLibre(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: NYTColors.black,
          letterSpacing: 2,
        ),
      );

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        onChanged: label.contains('URL') ? (_) => setState(() {}) : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.sourceSerif4(
              fontSize: 12, color: NYTColors.darkGrey),
        ),
        style: GoogleFonts.sourceSerif4(fontSize: 14),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null
            : null,
      ),
    );
  }

  Widget _statSlider(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.frankRuhlLibre(
                    fontSize: 12,
                    color: NYTColors.darkGrey,
                    letterSpacing: 0.5)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: NYTColors.black,
                inactiveTrackColor: NYTColors.midGrey,
                thumbColor: NYTColors.black,
                overlayColor: NYTColors.black.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 100,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: GoogleFonts.frankRuhlLibre(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NYTColors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final admin = context.read<AdminProvider>();
    final hero = CustomHero(
      id: widget.hero?.id,
      name: _name.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      fullName: _fullName.text.trim().isEmpty ? '-' : _fullName.text.trim(),
      publisher:
          _publisher.text.trim().isEmpty ? '-' : _publisher.text.trim(),
      alignment: _alignment,
      firstAppearance: _firstAppearance.text.trim().isEmpty
          ? '-'
          : _firstAppearance.text.trim(),
      occupation:
          _occupation.text.trim().isEmpty ? '-' : _occupation.text.trim(),
      groupAffiliation: _groupAffiliation.text.trim().isEmpty
          ? '-'
          : _groupAffiliation.text.trim(),
      description: _description.text.trim(),
      intelligence: _intel,
      strength: _str,
      speed: _spd,
      durability: _dur,
      power: _pow,
      combat: _com,
    );

    bool success;
    if (isEdit) {
      success = await admin.updateHero(widget.hero!.id!, hero);
    } else {
      success = await admin.addHero(hero);
    }

    if (success && mounted) Navigator.pop(context);
  }
}
