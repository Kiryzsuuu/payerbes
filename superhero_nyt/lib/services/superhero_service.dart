import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/superhero.dart';

class SuperheroService {
  // Free access token from superheroapi.com â€” register for your own at superheroapi.com/api.html
  static const String _token = '10160534789069524';
  static const String _baseUrl = 'https://superheroapi.com/api/$_token';

  Future<List<Superhero>> searchHeroes(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response'] == 'success') {
        final results = data['results'] as List;
        return results.map((json) => Superhero.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<Superhero?> getHeroById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response'] == 'success') {
        return Superhero.fromJson(data);
      }
    }
    return null;
  }

  Future<List<Superhero>> getFeaturedHeroes() async {
    // Fetch a curated list of well-known heroes for the front page
    const featuredIds = ['70', '149', '332', '107', '441', '213', '720', '655'];
    final futures = featuredIds.map((id) => getHeroById(id));
    final results = await Future.wait(futures);
    return results.whereType<Superhero>().toList();
  }
}

