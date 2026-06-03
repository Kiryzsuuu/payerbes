import 'package:cloud_firestore/cloud_firestore.dart';
import 'superhero.dart';

enum UserRole { admin, user }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final String displayName;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.displayName,
  });

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: d['email'] ?? '',
      role: d['role'] == 'admin' ? UserRole.admin : UserRole.user,
      displayName: d['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'role': role == UserRole.admin ? 'admin' : 'user',
        'displayName': displayName,
      };
}

class CustomHero {
  final String? id;
  final String name;
  final String imageUrl;
  final String fullName;
  final String publisher;
  final String alignment;
  final String firstAppearance;
  final String occupation;
  final String groupAffiliation;
  final String description;
  // Powerstats
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;
  final DateTime? createdAt;
  final String createdBy;

  CustomHero({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.fullName,
    required this.publisher,
    required this.alignment,
    required this.firstAppearance,
    required this.occupation,
    required this.groupAffiliation,
    required this.description,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    this.createdAt,
    this.createdBy = '',
  });

  factory CustomHero.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CustomHero(
      id: doc.id,
      name: d['name'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      fullName: d['fullName'] ?? '-',
      publisher: d['publisher'] ?? '-',
      alignment: d['alignment'] ?? 'good',
      firstAppearance: d['firstAppearance'] ?? '-',
      occupation: d['occupation'] ?? '-',
      groupAffiliation: d['groupAffiliation'] ?? '-',
      description: d['description'] ?? '',
      intelligence: d['intelligence'] ?? 50,
      strength: d['strength'] ?? 50,
      speed: d['speed'] ?? 50,
      durability: d['durability'] ?? 50,
      power: d['power'] ?? 50,
      combat: d['combat'] ?? 50,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      createdBy: d['createdBy'] ?? '',
    );
  }

  Superhero toSuperhero() => Superhero(
        id: id ?? name.hashCode.toString(),
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
          intelligence: intelligence.toString(),
          strength: strength.toString(),
          speed: speed.toString(),
          durability: durability.toString(),
          power: power.toString(),
          combat: combat.toString(),
        ),
        appearance: Appearance(
          gender: '-',
          race: '-',
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

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'fullName': fullName,
        'publisher': publisher,
        'alignment': alignment,
        'firstAppearance': firstAppearance,
        'occupation': occupation,
        'groupAffiliation': groupAffiliation,
        'description': description,
        'intelligence': intelligence,
        'strength': strength,
        'speed': speed,
        'durability': durability,
        'power': power,
        'combat': combat,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      };
}
