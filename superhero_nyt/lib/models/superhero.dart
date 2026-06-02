class Superhero {
  final String id;
  final String name;
  final String imageUrl;
  final Biography biography;
  final Powerstats powerstats;
  final Appearance appearance;
  final Connections connections;
  final Work work;

  Superhero({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.biography,
    required this.powerstats,
    required this.appearance,
    required this.connections,
    required this.work,
  });

  factory Superhero.fromJson(Map<String, dynamic> json) {
    return Superhero(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image']?['url'] ?? '',
      biography: Biography.fromJson(json['biography'] ?? {}),
      powerstats: Powerstats.fromJson(json['powerstats'] ?? {}),
      appearance: Appearance.fromJson(json['appearance'] ?? {}),
      connections: Connections.fromJson(json['connections'] ?? {}),
      work: Work.fromJson(json['work'] ?? {}),
    );
  }
}

class Biography {
  final String fullName;
  final String alterEgos;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  Biography({
    required this.fullName,
    required this.alterEgos,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
  });

  factory Biography.fromJson(Map<String, dynamic> json) {
    return Biography(
      fullName: json['full-name'] ?? '-',
      alterEgos: json['alter-egos'] ?? '-',
      placeOfBirth: json['place-of-birth'] ?? '-',
      firstAppearance: json['first-appearance'] ?? '-',
      publisher: json['publisher'] ?? '-',
      alignment: json['alignment'] ?? '-',
    );
  }
}

class Powerstats {
  final String intelligence;
  final String strength;
  final String speed;
  final String durability;
  final String power;
  final String combat;

  Powerstats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory Powerstats.fromJson(Map<String, dynamic> json) {
    return Powerstats(
      intelligence: json['intelligence'] ?? '0',
      strength: json['strength'] ?? '0',
      speed: json['speed'] ?? '0',
      durability: json['durability'] ?? '0',
      power: json['power'] ?? '0',
      combat: json['combat'] ?? '0',
    );
  }

  int get(String stat) => int.tryParse(stat) ?? 0;
}

class Appearance {
  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  Appearance({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      gender: json['gender'] ?? '-',
      race: json['race'] ?? '-',
      height: List<String>.from(json['height'] ?? ['-']),
      weight: List<String>.from(json['weight'] ?? ['-']),
      eyeColor: json['eye-color'] ?? '-',
      hairColor: json['hair-color'] ?? '-',
    );
  }
}

class Connections {
  final String groupAffiliation;
  final String relatives;

  Connections({required this.groupAffiliation, required this.relatives});

  factory Connections.fromJson(Map<String, dynamic> json) {
    return Connections(
      groupAffiliation: json['group-affiliation'] ?? '-',
      relatives: json['relatives'] ?? '-',
    );
  }
}

class Work {
  final String occupation;
  final String base;

  Work({required this.occupation, required this.base});

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      occupation: json['occupation'] ?? '-',
      base: json['base'] ?? '-',
    );
  }
}

