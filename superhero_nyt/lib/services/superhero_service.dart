import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/superhero.dart';

class SuperheroService {
  static const String _token = '10160534789069524';
  static const String _baseUrl = 'https://superheroapi.com/api/$_token';

  String _url(String path) {
    final url = '$_baseUrl/$path';
    if (kIsWeb) return 'https://corsproxy.io/?url=${Uri.encodeComponent(url)}';
    return url;
  }

  Future<List<Superhero>> searchHeroes(String query) async {
    try {
      final response = await http
          .get(Uri.parse(_url('search/$query')))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] == 'success') {
          final results = data['results'] as List;
          return results.map((json) => Superhero.fromJson(json)).toList();
        }
      }
    } catch (_) {}
    // Fallback pencarian dari data statis
    return _staticHeroes
        .where((h) => h.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Superhero?> getHeroById(String id) async {
    try {
      final response = await http
          .get(Uri.parse(_url(id)))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] == 'success') {
          return Superhero.fromJson(data);
        }
      }
    } catch (_) {}
    // Fallback dari data statis
    try {
      return _staticHeroes.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Superhero>> getFeaturedHeroes() async {
    try {
      const featuredIds = ['70', '149', '332', '107', '441', '213', '720', '655'];
      final futures = featuredIds.map((id) => getHeroById(id));
      final results = await Future.wait(futures);
      final heroes = results.whereType<Superhero>().toList();
      if (heroes.isNotEmpty) return heroes;
    } catch (_) {}
    // Jika API gagal, tampilkan data statis
    return _staticHeroes;
  }

  // ── Data statis fallback (tampil saat API offline / CORS) ──────────────────
  // Anda bisa menambah/mengubah hero di sini:
  // - name     : Nama superhero
  // - imageUrl : URL gambar (bisa dari internet atau assets)
  // - biography, powerstats, dll.
  static final List<Superhero> _staticHeroes = [
    _makeHero(
      id: '70',
      name: 'Batman',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
      fullName: 'Bruce Wayne',
      publisher: 'DC Comics',
      alignment: 'good',
      firstAppearance: 'Detective Comics #27',
      intelligence: '100', strength: '26', speed: '27',
      durability: '50', power: '47', combat: '100',
      gender: 'Male', race: 'Human',
      occupation: 'Businessman',
      groupAffiliation: 'Justice League',
    ),
    _makeHero(
      id: '149',
      name: 'Superman',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/791.jpg',
      fullName: 'Clark Kent',
      publisher: 'DC Comics',
      alignment: 'good',
      firstAppearance: 'Action Comics #1',
      intelligence: '94', strength: '100', speed: '100',
      durability: '100', power: '100', combat: '85',
      gender: 'Male', race: 'Kryptonian',
      occupation: 'Reporter',
      groupAffiliation: 'Justice League',
    ),
    _makeHero(
      id: '332',
      name: 'Iron Man',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
      fullName: 'Tony Stark',
      publisher: 'Marvel Comics',
      alignment: 'good',
      firstAppearance: 'Tales of Suspense #39',
      intelligence: '100', strength: '85', speed: '58',
      durability: '85', power: '100', combat: '64',
      gender: 'Male', race: 'Human',
      occupation: 'Inventor, Industrialist',
      groupAffiliation: 'Avengers',
    ),
    _makeHero(
      id: '107',
      name: 'Captain America',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/274.jpg',
      fullName: 'Steve Rogers',
      publisher: 'Marvel Comics',
      alignment: 'good',
      firstAppearance: 'Captain America Comics #1',
      intelligence: '69', strength: '19', speed: '35',
      durability: '55', power: '32', combat: '100',
      gender: 'Male', race: 'Human',
      occupation: 'Soldier',
      groupAffiliation: 'Avengers',
    ),
    _makeHero(
      id: '441',
      name: 'Spider-Man',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/133.jpg',
      fullName: 'Peter Parker',
      publisher: 'Marvel Comics',
      alignment: 'good',
      firstAppearance: 'Amazing Fantasy #15',
      intelligence: '90', strength: '55', speed: '67',
      durability: '75', power: '74', combat: '85',
      gender: 'Male', race: 'Human',
      occupation: 'Photographer, Student',
      groupAffiliation: 'Avengers',
    ),
    _makeHero(
      id: '213',
      name: 'Thor',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/140.jpg',
      fullName: 'Thor Odinson',
      publisher: 'Marvel Comics',
      alignment: 'good',
      firstAppearance: 'Journey into Mystery #83',
      intelligence: '69', strength: '100', speed: '92',
      durability: '100', power: '100', combat: '100',
      gender: 'Male', race: 'Asgardian',
      occupation: 'King of Asgard',
      groupAffiliation: 'Avengers',
    ),
    _makeHero(
      id: '720',
      name: 'Wonder Woman',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/807.jpg',
      fullName: 'Diana Prince',
      publisher: 'DC Comics',
      alignment: 'good',
      firstAppearance: 'All Star Comics #8',
      intelligence: '88', strength: '100', speed: '79',
      durability: '95', power: '100', combat: '100',
      gender: 'Female', race: 'Amazon',
      occupation: 'Amazon Princess',
      groupAffiliation: 'Justice League',
    ),
    _makeHero(
      id: '655',
      name: 'The Joker',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/719.jpg',
      fullName: 'Unknown',
      publisher: 'DC Comics',
      alignment: 'bad',
      firstAppearance: 'Batman #1',
      intelligence: '100', strength: '10', speed: '12',
      durability: '60', power: '43', combat: '70',
      gender: 'Male', race: 'Human',
      occupation: 'Criminal',
      groupAffiliation: 'Injustice League',
    ),
  ];

  static Superhero _makeHero({
    required String id,
    required String name,
    required String imageUrl,
    required String fullName,
    required String publisher,
    required String alignment,
    required String firstAppearance,
    required String intelligence,
    required String strength,
    required String speed,
    required String durability,
    required String power,
    required String combat,
    required String gender,
    required String race,
    required String occupation,
    required String groupAffiliation,
  }) {
    return Superhero(
      id: id,
      name: name,
      imageUrl: imageUrl,
      biography: Biography(
        fullName: fullName,
        alterEgos: '-',
        placeOfBirth: '-',
        firstAppearance: firstAppearance,
        publisher: publisher,
        alignment: alignment,
      ),
      powerstats: Powerstats(
        intelligence: intelligence,
        strength: strength,
        speed: speed,
        durability: durability,
        power: power,
        combat: combat,
      ),
      appearance: Appearance(
        gender: gender,
        race: race,
        height: ['-'],
        weight: ['-'],
        eyeColor: '-',
        hairColor: '-',
      ),
      connections: Connections(
        groupAffiliation: groupAffiliation,
        relatives: '-',
      ),
      work: Work(occupation: occupation, base: '-'),
    );
  }
}
