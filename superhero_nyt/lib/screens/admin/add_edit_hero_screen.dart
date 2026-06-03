import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/custom_hero.dart';
import '../../providers/admin_provider.dart';
import '../../theme/nyt_theme.dart';

class AddEditHeroScreen extends StatefulWidget {
  final CustomHero? hero;
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

  XFile? _pickedImage;
  String? _base64Image; // gambar lokal sebagai base64
  bool _processing = false;

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

  // Konversi gambar ke base64 dan simpan sebagai data URI
  Future<void> _processImage(XFile file) async {
    setState(() => _processing = true);
    try {
      final bytes = await file.readAsBytes();
      // Resize jika terlalu besar (max ~500KB)
      final ext = file.name.split('.').last.toLowerCase();
      final b64 = base64Encode(bytes);
      final dataUri = 'data:image/$ext;base64,$b64';
      setState(() {
        _base64Image = dataUri;
        _imageUrl.text = dataUri;
        _pickedImage = file;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: $e')),
        );
      }
    }
    setState(() => _processing = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (file != null) await _processImage(file);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NYTColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Sumber Gambar',
                  style: GoogleFonts.unna(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NYTColors.black)),
              const Divider(color: NYTColors.midGrey),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: NYTColors.black),
                title: Text('Pilih dari Galeri',
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 14, color: NYTColors.black)),
                subtitle: Text('Foto dari galeri HP/emulator',
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 11, color: NYTColors.darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: NYTColors.black),
                  title: Text('Ambil Foto (Kamera)',
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 14, color: NYTColors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.link, color: NYTColors.darkGrey),
                title: Text('Masukkan URL gambar',
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 14, color: NYTColors.black)),
                subtitle: Text('Tempel link gambar dari internet',
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 11, color: NYTColors.darkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NYTColors.white,
        title: Text('URL Gambar',
            style: GoogleFonts.unna(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NYTColors.black)),
        content: TextField(
          controller: _imageUrl,
          decoration: const InputDecoration(
            hintText: 'https://...',
            labelText: 'URL Gambar',
          ),
          style: GoogleFonts.sourceSerif4(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _base64Image = null);
            },
            child: Text('OK',
                style: GoogleFonts.frankRuhlLibre(
                    fontWeight: FontWeight.w700, color: NYTColors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final hasImage = _imageUrl.text.isNotEmpty;

    return GestureDetector(
      onTap: _processing ? null : _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: NYTColors.lightGrey,
          border: Border.all(
            color: hasImage ? NYTColors.black : NYTColors.midGrey,
            width: hasImage ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _processing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                      color: NYTColors.black, strokeWidth: 2),
                  const SizedBox(height: 12),
                  Text('Memproses gambar...',
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 13, color: NYTColors.darkGrey)),
                ],
              )
            : hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: _base64Image != null
                            ? Image.memory(
                                base64Decode(
                                    _base64Image!.split(',').last),
                                fit: BoxFit.cover)
                            : (_pickedImage != null && !kIsWeb
                                ? Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover)
                                : Image.network(
                                    _imageUrl.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: NYTColors.midGrey),
                                  )),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: NYTColors.black
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('Ganti',
                                    style: GoogleFonts.frankRuhlLibre(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: NYTColors.darkGrey),
                      const SizedBox(height: 10),
                      Text('Tap untuk pilih gambar',
                          style: GoogleFonts.frankRuhlLibre(
                              fontSize: 13,
                              color: NYTColors.darkGrey,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Galeri • Kamera • URL',
                          style: GoogleFonts.sourceSerif4(
                              fontSize: 11,
                              color: NYTColors.darkGrey,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
      ),
    );
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
              color: NYTColors.black),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(thickness: 2, color: NYTColors.black, height: 2),
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
                  const SizedBox(height: 4),
                  Text('Gambar Hero *',
                      style: GoogleFonts.frankRuhlLibre(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: NYTColors.darkGrey,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  _field(_publisher, 'Publisher',
                      hint: 'Marvel Comics / DC Comics'),
                  _field(_firstAppearance, 'First Appearance',
                      hint: 'Amazing Fantasy #15'),

                  // Alignment
                  const SizedBox(height: 4),
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
                      onPressed:
                          (admin.loading || _processing) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NYTColors.black,
                        foregroundColor: NYTColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: (admin.loading || _processing)
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

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.frankRuhlLibre(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: NYTColors.black,
          letterSpacing: 2));

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
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

  Widget _statSlider(
      String label, int value, ValueChanged<int> onChanged) {
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
    if (_imageUrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }
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

    final success = isEdit
        ? await admin.updateHero(widget.hero!.id!, hero)
        : await admin.addHero(hero);
    if (success && mounted) Navigator.pop(context);
  }
}
