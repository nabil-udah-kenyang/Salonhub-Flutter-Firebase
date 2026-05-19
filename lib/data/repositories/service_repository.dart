import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new service
  Future<String> createService(ServiceModel service) async {
    try {
      final docRef = await _firestore.collection('services').add(service.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  // Get services by barbershop ID
  Future<List<ServiceModel>> getServicesByBarbershopId(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('services')
          .where('barbershopId', isEqualTo: barbershopId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services: $e');
    }
  }

  // Get all services (for admin)
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final query = await _firestore
          .collection('services')
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all services: $e');
    }
  }

  // Get services by category
  Future<List<ServiceModel>> getServicesByCategory(String category, {String? barbershopId}) async {
    try {
      Query queryRef = _firestore
          .collection('services')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true);

      if (barbershopId != null) {
        queryRef = queryRef.where('barbershopId', isEqualTo: barbershopId);
      }

      final query = await queryRef.orderBy('name').get();

      return query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by category: $e');
    }
  }

  // Update service
  Future<void> updateService(ServiceModel service) async {
    try {
      await _firestore
          .collection('services')
          .doc(service.id)
          .update(service.toFirestore());
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  // Delete service (soft delete - set isActive to false)
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  // Activate/deactivate service
  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle service status: $e');
    }
  }

  // Update service rating
  Future<void> updateServiceRating(String serviceId, double newRating) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        final service = ServiceModel.fromFirestore(doc);
        final totalReviews = service.totalReviews + 1;
        final updatedRating = ((service.rating * service.totalReviews) + newRating) / totalReviews;

        await _firestore.collection('services').doc(serviceId).update({
          'rating': updatedRating,
          'totalReviews': totalReviews,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update service rating: $e');
    }
  }

  // Search services by name
  Future<List<ServiceModel>> searchServices(String query, {String? barbershopId}) async {
    try {
      Query queryRef = _firestore.collection('services');

      if (barbershopId != null) {
        queryRef = queryRef.where('barbershopId', isEqualTo: barbershopId);
      }

      queryRef = queryRef.where('isActive', isEqualTo: true);

      final snapshot = await queryRef.get();
      
      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      // Filter by name (case insensitive)
      if (query.isNotEmpty) {
        return services.where((service) =>
            service.name.toLowerCase().contains(query.toLowerCase())).toList();
      }

      return services;
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  // Get popular services
  Future<List<ServiceModel>> getPopularServices({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .where('totalBookings', isGreaterThan: 0)
          .orderBy('totalBookings', descending: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get popular services: $e');
    }
  }

  // Get services by price range
  Future<List<ServiceModel>> getServicesByPriceRange(
      double minPrice, double maxPrice, {String? barbershopId}) async {
    try {
      Query queryRef = _firestore
          .collection('services')
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .where('isActive', isEqualTo: true);

      if (barbershopId != null) {
        queryRef = queryRef.where('barbershopId', isEqualTo: barbershopId);
      }

      final query = await queryRef.orderBy('price').get();

      return query.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get services by price range: $e');
    }
  }

  // Get service statistics
  Future<Map<String, dynamic>> getServiceStats(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('services')
          .where('barbershopId', isEqualTo: barbershopId)
          .get();

      final totalServices = query.docs.length;
      final activeServices = query.docs
          .where((doc) => doc['isActive'] == true)
          .length;
      
      double avgPrice = 0;
      int totalBookings = 0;
      double avgRating = 0;

      if (totalServices > 0) {
        final totalPrice = query.docs.fold<double>(0, (sum, doc) {
          return sum + ((doc['price'] ?? 0.0) as double);
        });
        avgPrice = totalPrice / totalServices;

        totalBookings = query.docs.fold<int>(0, (sum, doc) {
          return sum + ((doc['totalBookings'] ?? 0) as int);
        });

        final totalRating = query.docs.fold<double>(0, (sum, doc) {
          return sum + ((doc['rating'] ?? 0.0) as double);
        });
        avgRating = totalRating / totalServices;
      }

      return {
        'totalServices': totalServices,
        'activeServices': activeServices,
        'averagePrice': avgPrice,
        'totalBookings': totalBookings,
        'averageRating': avgRating,
      };
    } catch (e) {
      throw Exception('Failed to get service stats: $e');
    }
  }

  // Initialize predefined services for a barbershop
  Future<void> initializePredefinedServices(String barbershopId) async {
    try {
      for (final service in ServiceModel.predefinedServices) {
        final newService = service.copyWith(barbershopId: barbershopId);
        await createService(newService);
      }
    } catch (e) {
      throw Exception('Failed to initialize predefined services: $e');
    }
  }

  // Stream services by barbershop ID
  Stream<List<ServiceModel>> streamServicesByBarbershopId(String barbershopId) {
    return _firestore
        .collection('services')
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }
}
