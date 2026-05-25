import 'package:cloud_firestore/cloud_firestore.dart';

class BarbershopModel {
  final String? id;
  final String name;
  final String description;
  final String address;
  final String? mapsLocation;
  final List<String> photos;
  final List<String> gallery;
  final String? phone;
  final String? whatsapp;
  final Map<String, Map<String, dynamic>> operatingHours;
  final List<String> closedDays;
  final double rating;
  final int totalReviews;
  final String ownerId;
  final bool isActive;
  final bool isApproved;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final GeoPoint? location;

  BarbershopModel({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    this.mapsLocation,
    this.photos = const [],
    this.gallery = const [],
    this.phone,
    this.whatsapp,
    this.operatingHours = const {},
    this.closedDays = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.ownerId,
    this.isActive = true,
    this.isApproved = false,
    this.createdAt,
    this.updatedAt,
    this.location,
  });

  factory BarbershopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BarbershopModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      mapsLocation: data['mapsLocation'],
      photos: List<String>.from(data['photos'] ?? []),
      gallery: List<String>.from(data['gallery'] ?? []),
      phone: data['phone'],
      whatsapp: data['whatsapp'],
      operatingHours: Map<String, Map<String, dynamic>>.from(
        data['operatingHours'] ?? {}
      ),
      closedDays: List<String>.from(data['closedDays'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
      ownerId: data['ownerId'] ?? '',
      isActive: data['isActive'] ?? true,
      isApproved: data['isApproved'] ?? false,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      if (mapsLocation != null) 'mapsLocation': mapsLocation,
      'photos': photos,
      'gallery': gallery,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      'operatingHours': operatingHours,
      'closedDays': closedDays,
      'rating': rating,
      'totalReviews': totalReviews,
      'ownerId': ownerId,
      'isActive': isActive,
      'isApproved': isApproved,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (location != null) 'location': location,
    };
  }

  BarbershopModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? mapsLocation,
    List<String>? photos,
    List<String>? gallery,
    String? phone,
    String? whatsapp,
    Map<String, Map<String, dynamic>>? operatingHours,
    List<String>? closedDays,
    double? rating,
    int? totalReviews,
    String? ownerId,
    bool? isActive,
    bool? isApproved,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    GeoPoint? location,
  }) {
    return BarbershopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      mapsLocation: mapsLocation ?? this.mapsLocation,
      photos: photos ?? this.photos,
      gallery: gallery ?? this.gallery,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      operatingHours: operatingHours ?? this.operatingHours,
      closedDays: closedDays ?? this.closedDays,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarbershopModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BarbershopModel{id: $id, name: $name, rating: $rating}';
  }
}
