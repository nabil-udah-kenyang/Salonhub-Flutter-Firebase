import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stylist_model.dart';

class StylistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new stylist
  Future<String> createStylist(StylistModel stylist) async {
    try {
      final docRef = await _firestore.collection('stylists').add(stylist.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create stylist: $e');
    }
  }

  // Get stylist by ID
  Future<StylistModel?> getStylistById(String stylistId) async {
    try {
      final doc = await _firestore.collection('stylists').doc(stylistId).get();
      if (doc.exists) {
        return StylistModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get stylist: $e');
    }
  }

  // Get stylists by barbershop ID
  Future<List<StylistModel>> getStylistsByBarbershopId(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('stylists')
          .where('barbershopId', isEqualTo: barbershopId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => StylistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get stylists: $e');
    }
  }

  // Get all stylists (for admin)
  Future<List<StylistModel>> getAllStylists() async {
    try {
      final query = await _firestore
          .collection('stylists')
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => StylistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all stylists: $e');
    }
  }

  // Update stylist
  Future<void> updateStylist(StylistModel stylist) async {
    try {
      await _firestore
          .collection('stylists')
          .doc(stylist.id)
          .update({
            ...stylist.toFirestore(),
            'rating': FieldValue.delete(),
            'totalReviews': FieldValue.delete(),
          });
    } catch (e) {
      throw Exception('Failed to update stylist: $e');
    }
  }

  // Delete stylist (soft delete - set isActive to false)
  Future<void> deleteStylist(String stylistId) async {
    try {
      await _firestore.collection('stylists').doc(stylistId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete stylist: $e');
    }
  }

  // Activate/deactivate stylist
  Future<void> toggleStylistStatus(String stylistId, bool isActive) async {
    try {
      await _firestore.collection('stylists').doc(stylistId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle stylist status: $e');
    }
  }

  // Search stylists by name
  Future<List<StylistModel>> searchStylists(String query, {String? barbershopId}) async {
    try {
      Query queryRef = _firestore.collection('stylists');

      if (barbershopId != null) {
        queryRef = queryRef.where('barbershopId', isEqualTo: barbershopId);
      }

      queryRef = queryRef.where('isActive', isEqualTo: true);

      final snapshot = await queryRef.get();
      
      final stylists = snapshot.docs
          .map((doc) => StylistModel.fromFirestore(doc))
          .toList();

      // Filter by name (case insensitive)
      if (query.isNotEmpty) {
        return stylists.where((stylist) =>
            stylist.name.toLowerCase().contains(query.toLowerCase())).toList();
      }

      return stylists;
    } catch (e) {
      throw Exception('Failed to search stylists: $e');
    }
  }

  // Get available stylists for specific date and time
  Future<List<StylistModel>> getAvailableStylists(
      String barbershopId, DateTime date, String time) async {
    try {
      // Get all active stylists for the barbershop
      final stylists = await getStylistsByBarbershopId(barbershopId);
      
      // Filter stylists based on their work schedule
      final availableStylists = <StylistModel>[];
      
      for (final stylist in stylists) {
        final dayOfWeek = _getDayOfWeek(date);
        final schedule = stylist.workSchedule[dayOfWeek];
        
        if (schedule != null && schedule.contains(time)) {
          availableStylists.add(stylist);
        }
      }
      
      return availableStylists;
    } catch (e) {
      throw Exception('Failed to get available stylists: $e');
    }
  }

  // Get stylist statistics
  Future<Map<String, dynamic>> getStylistStats(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('stylists')
          .where('barbershopId', isEqualTo: barbershopId)
          .get();

      final totalStylists = query.docs.length;
      final activeStylists = query.docs
          .where((doc) => doc['isActive'] == true)
          .length;
      
      return {
        'totalStylists': totalStylists,
        'activeStylists': activeStylists,
      };
    } catch (e) {
      throw Exception('Failed to get stylist stats: $e');
    }
  }

  // Stream stylists by barbershop ID
  Stream<List<StylistModel>> streamStylistsByBarbershopId(String barbershopId) {
    return _firestore
        .collection('stylists')
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StylistModel.fromFirestore(doc))
            .toList());
  }

  // Helper method to get day of week
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
