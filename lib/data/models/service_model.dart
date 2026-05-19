import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration; // in minutes
  final String photo;
  final bool isActive;
  final String barbershopId;
  final int totalBookings;
  final double rating;
  final int totalReviews;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ServiceModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.photo,
    this.isActive = true,
    required this.barbershopId,
    this.totalBookings = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 30,
      photo: data['photo'] ?? '',
      isActive: data['isActive'] ?? true,
      barbershopId: data['barbershopId'] ?? '',
      totalBookings: data['totalBookings'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'photo': photo,
      'isActive': isActive,
      'barbershopId': barbershopId,
      'totalBookings': totalBookings,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? duration,
    String? photo,
    bool? isActive,
    String? barbershopId,
    int? totalBookings,
    double? rating,
    int? totalReviews,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      barbershopId: barbershopId ?? this.barbershopId,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Predefined service categories
  static List<String> get categories => [
    'Haircut',
    'Hair Color',
    'Hair Styling',
    'Hair Treatment',
    'Beard & Mustache',
    'Facial',
    'Massage',
    'Manicure & Pedicure',
    'Waxing',
    'Other',
  ];

  // Predefined services
  static List<ServiceModel> get predefinedServices => [
    ServiceModel(
      name: 'Regular Haircut',
      description: 'Basic haircut with wash and styling',
      category: 'Haircut',
      price: 50000,
      duration: 30,
      photo: 'assets/services/regular_haircut.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Premium Haircut',
      description: 'Premium haircut with detailed styling',
      category: 'Haircut',
      price: 80000,
      duration: 45,
      photo: 'assets/services/premium_haircut.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Hair Coloring',
      description: 'Full hair coloring service',
      category: 'Hair Color',
      price: 150000,
      duration: 120,
      photo: 'assets/services/hair_coloring.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Hair Styling',
      description: 'Professional hair styling for special occasions',
      category: 'Hair Styling',
      price: 75000,
      duration: 60,
      photo: 'assets/services/hair_styling.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Hair Treatment',
      description: 'Deep conditioning and hair treatment',
      category: 'Hair Treatment',
      price: 60000,
      duration: 45,
      photo: 'assets/services/hair_treatment.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Beard Trim',
      description: 'Beard trimming and shaping',
      category: 'Beard & Mustache',
      price: 30000,
      duration: 20,
      photo: 'assets/services/beard_trim.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Facial Treatment',
      description: 'Basic facial treatment',
      category: 'Facial',
      price: 80000,
      duration: 60,
      photo: 'assets/services/facial.jpg',
      barbershopId: '',
    ),
    ServiceModel(
      name: 'Head Massage',
      description: 'Relaxing head massage',
      category: 'Massage',
      price: 40000,
      duration: 30,
      photo: 'assets/services/head_massage.jpg',
      barbershopId: '',
    ),
  ];
}
