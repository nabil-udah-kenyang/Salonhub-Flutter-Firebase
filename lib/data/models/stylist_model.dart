import 'package:cloud_firestore/cloud_firestore.dart';

class StylistModel {
  final String? id;
  final String name;
  final String photo;
  final List<String> specializations;
  final int experience;
  final bool isActive;
  final String barbershopId;
  final Map<String, List<String>> workSchedule;
  final String? bio;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  StylistModel({
    this.id,
    required this.name,
    required this.photo,
    this.specializations = const [],
    this.experience = 0,
    this.isActive = true,
    required this.barbershopId,
    this.workSchedule = const {},
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory StylistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StylistModel(
      id: doc.id,
      name: data['name'] ?? '',
      photo: data['photo'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      experience: (data['experience'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      barbershopId: data['barbershopId'] ?? '',
      workSchedule: Map<String, List<String>>.from(data['workSchedule'] ?? {}),
      bio: data['bio'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photo': photo,
      'specializations': specializations,
      'experience': experience,
      'isActive': isActive,
      'barbershopId': barbershopId,
      'workSchedule': workSchedule,
      'bio': bio,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  StylistModel copyWith({
    String? id,
    String? name,
    String? photo,
    List<String>? specializations,
    int? experience,
    bool? isActive,
    String? barbershopId,
    Map<String, List<String>>? workSchedule,
    String? bio,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return StylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      specializations: specializations ?? this.specializations,
      experience: experience ?? this.experience,
      isActive: isActive ?? this.isActive,
      barbershopId: barbershopId ?? this.barbershopId,
      workSchedule: workSchedule ?? this.workSchedule,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
