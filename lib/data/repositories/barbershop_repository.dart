import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/barbershop_model.dart';

class BarbershopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BarbershopModel>> streamApprovedBarbershops({bool activeOnly = true}) {
    Query query = _firestore
        .collection(AppConstants.barbershopsCollection)
        .where('isApproved', isEqualTo: true);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(BarbershopModel.fromFirestore).toList(),
        );
  }

  Stream<List<BarbershopModel>> streamBarbershops({bool? isApproved, bool? isActive}) {
    Query query = _firestore.collection(AppConstants.barbershopsCollection);
    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(BarbershopModel.fromFirestore).toList(),
        );
  }

  Future<BarbershopModel?> getBarbershopById(String id) async {
    final doc = await _firestore.collection(AppConstants.barbershopsCollection).doc(id).get();
    if (!doc.exists) return null;
    return BarbershopModel.fromFirestore(doc);
  }

  Future<void> updateApprovalStatus(String barbershopId, bool isApproved) async {
    await _firestore.collection(AppConstants.barbershopsCollection).doc(barbershopId).update({
      'isApproved': isApproved,
      'isActive': isApproved ? true : false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateActiveStatus(String barbershopId, bool isActive) async {
    await _firestore.collection(AppConstants.barbershopsCollection).doc(barbershopId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitRating({
    required String bookingId,
    required String barbershopId,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating harus antara 1 sampai 5.');
    }

    final bookingRef = _firestore.collection(AppConstants.bookingsCollection).doc(bookingId);
    final barbershopRef = _firestore.collection(AppConstants.barbershopsCollection).doc(barbershopId);

    await _firestore.runTransaction((transaction) async {
      final bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) {
        throw Exception('Booking tidak ditemukan.');
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      if (bookingData['status'] != 'completed') {
        throw Exception('Rating hanya bisa diberikan setelah booking selesai.');
      }
      if (bookingData['isReviewed'] == true) {
        throw Exception('Booking ini sudah diberi rating.');
      }

      final barbershopDoc = await transaction.get(barbershopRef);
      if (!barbershopDoc.exists) {
        throw Exception('Barbershop tidak ditemukan.');
      }

      final barbershopData = barbershopDoc.data() as Map<String, dynamic>;
      final currentRating = (barbershopData['rating'] as num?)?.toDouble() ?? 0.0;
      final currentTotalReviews = (barbershopData['totalReviews'] as num?)?.toInt() ?? 0;
      final newTotalReviews = currentTotalReviews + 1;
      final newRating = ((currentRating * currentTotalReviews) + rating) / newTotalReviews;

      transaction.update(barbershopRef, {
        'rating': newRating,
        'totalReviews': newTotalReviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(bookingRef, {
        'isReviewed': true,
        'barbershopRating': rating,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
