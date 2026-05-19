import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String role;
  final bool isActive;
  final bool isEmailVerified;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Map<String, dynamic>? preferences;
  final String? deviceId;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    this.isActive = true,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.preferences,
    this.deviceId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      preferences: data['preferences'] as Map<String, dynamic>?,
      deviceId: data['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (preferences != null) 'preferences': preferences,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    bool? isActive,
    bool? isEmailVerified,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Map<String, dynamic>? preferences,
    String? deviceId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, role: $role}';
  }
}
