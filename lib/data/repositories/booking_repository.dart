import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new booking
  Future<String> createBooking(BookingModel booking) async {
    try {
      final bookingId = await _generateUniqueBookingId();
      await _firestore.collection('bookings').doc(bookingId).set(booking.toFirestore());
      return bookingId;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<String> _generateUniqueBookingId() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final bookingId = _generateBookingId();
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) return bookingId;
    }

    throw Exception('Failed to generate unique booking ID');
  }

  String _generateBookingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final codeLength = 6 + random.nextInt(3);
    final code = List.generate(
      codeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    return 'BOOK-$code';
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Get bookings by user ID
  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();

      return query.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  // Get bookings by barbershop ID
  Future<List<BookingModel>> getBookingsByBarbershopId(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('barbershopId', isEqualTo: barbershopId)
          .orderBy('bookingDate', descending: true)
          .get();

      return query.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get barbershop bookings: $e');
    }
  }

  // Get bookings by status
  Future<List<BookingModel>> getBookingsByStatus(String status) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: status)
          .orderBy('bookingDate', descending: true)
          .get();

      return query.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings by status: $e');
    }
  }

  // Get bookings by date range
  Future<List<BookingModel>> getBookingsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('bookingDate', isGreaterThanOrEqualTo: startDate)
          .where('bookingDate', isLessThanOrEqualTo: endDate)
          .orderBy('bookingDate', descending: true)
          .get();

      return query.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings by date range: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update booking
  Future<void> updateBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  Future<void> updatePaymentInfo(
    String bookingId, {
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment info: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Reschedule booking
  Future<void> rescheduleBooking(String bookingId, DateTime newDate, String newTime) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'bookingDate': newDate,
        'bookingTime': newTime,
        'status': 'rescheduled',
        'rescheduledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reschedule booking: $e');
    }
  }

  // Get today's bookings for barbershop
  Future<List<BookingModel>> getTodayBookings(String barbershopId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final query = await _firestore
          .collection('bookings')
          .where('barbershopId', isEqualTo: barbershopId)
          .where('bookingDate', isGreaterThanOrEqualTo: today)
          .where('bookingDate', isLessThan: tomorrow)
          .orderBy('bookingTime')
          .get();

      return query.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today bookings: $e');
    }
  }

  // Get booking statistics
  Future<Map<String, int>> getBookingStats(String barbershopId) async {
    try {
      final query = await _firestore
          .collection('bookings')
          .where('barbershopId', isEqualTo: barbershopId)
          .get();

      final stats = <String, int>{};
      for (final doc in query.docs) {
        final status = doc['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get booking stats: $e');
    }
  }

  // Stream bookings by barbershop ID
  Stream<List<BookingModel>> streamBookingsByBarbershopId(String barbershopId) {
    return _firestore
        .collection('bookings')
        .where('barbershopId', isEqualTo: barbershopId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
          bookings.sort((a, b) {
            final dateCompare = b.bookingDate.compareTo(a.bookingDate);
            if (dateCompare != 0) return dateCompare;
            return b.bookingTime.compareTo(a.bookingTime);
          });
          return bookings;
        });
  }

  // Stream bookings by user ID
  Stream<List<BookingModel>> streamBookingsByUserId(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }
}
