import 'package:cloud_firestore/cloud_firestore.dart';

class SiteSettings {
  final String siteTitle;
  final String tagline;
  final String section1Label;
  final String section2Label;
  final String section3Label;
  final bool showApiHeroes;

  const SiteSettings({
    this.siteTitle = 'The Hero Times',
    this.tagline = "ALL THE SUPERHERO NEWS THAT'S FIT TO PRINT",
    this.section1Label = "Today's Feature",
    this.section2Label = 'In The News',
    this.section3Label = 'Also Reported',
    this.showApiHeroes = true,
  });

  factory SiteSettings.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return SiteSettings(
      siteTitle: d['siteTitle'] ?? 'The Hero Times',
      tagline: d['tagline'] ?? "ALL THE SUPERHERO NEWS THAT'S FIT TO PRINT",
      section1Label: d['section1Label'] ?? "Today's Feature",
      section2Label: d['section2Label'] ?? 'In The News',
      section3Label: d['section3Label'] ?? 'Also Reported',
      showApiHeroes: d['showApiHeroes'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'siteTitle': siteTitle,
        'tagline': tagline,
        'section1Label': section1Label,
        'section2Label': section2Label,
        'section3Label': section3Label,
        'showApiHeroes': showApiHeroes,
      };

  SiteSettings copyWith({
    String? siteTitle,
    String? tagline,
    String? section1Label,
    String? section2Label,
    String? section3Label,
    bool? showApiHeroes,
  }) =>
      SiteSettings(
        siteTitle: siteTitle ?? this.siteTitle,
        tagline: tagline ?? this.tagline,
        section1Label: section1Label ?? this.section1Label,
        section2Label: section2Label ?? this.section2Label,
        section3Label: section3Label ?? this.section3Label,
        showApiHeroes: showApiHeroes ?? this.showApiHeroes,
      );
}
