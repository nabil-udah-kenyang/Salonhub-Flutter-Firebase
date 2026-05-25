import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const List<String> _blockingStatuses = [
    'pending',
    'confirmed',
    'in_progress',
    'rescheduled',
  ];

  // Create new booking
  Future<String> createBooking(BookingModel booking) async {
    try {
      final normalizedBooking = booking.copyWith(
        bookingDate: _dateOnly(booking.bookingDate),
      );

      final existingConflict = await _findConflictingBooking(
        stylistId: normalizedBooking.stylistId,
        bookingDate: normalizedBooking.bookingDate,
        bookingTime: normalizedBooking.bookingTime,
      );

      if (existingConflict != null) {
        throw Exception('Slot ini sudah dipesan. Silakan pilih waktu lain.');
      }

      return await _firestore.runTransaction((transaction) async {
        final slotRef = _bookingSlotRef(
          stylistId: normalizedBooking.stylistId,
          bookingDate: normalizedBooking.bookingDate,
          bookingTime: normalizedBooking.bookingTime,
        );
        final slotDoc = await transaction.get(slotRef);
        if (slotDoc.exists) {
          throw Exception('Slot ini sudah dipesan. Silakan pilih waktu lain.');
        }

        final bookingId = await _generateUniqueBookingId(transaction);
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.set(bookingRef, normalizedBooking.toFirestore());
        transaction.set(slotRef, {
          'bookingId': bookingId,
          'stylistId': normalizedBooking.stylistId,
          'barbershopId': normalizedBooking.barbershopId,
          'bookingDate': Timestamp.fromDate(normalizedBooking.bookingDate),
          'bookingTime': normalizedBooking.bookingTime,
          'status': normalizedBooking.status,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return bookingId;
      });
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<String> _generateUniqueBookingId([Transaction? transaction]) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final bookingId = _generateBookingId();
      final docRef = _firestore.collection('bookings').doc(bookingId);
      final doc = transaction == null ? await docRef.get() : await transaction.get(docRef);
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

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  DocumentReference<Map<String, dynamic>> _bookingSlotRef({
    required String stylistId,
    required DateTime bookingDate,
    required String bookingTime,
  }) {
    final date = _dateOnly(bookingDate);
    final slotId = [
      stylistId,
      date.year.toString().padLeft(4, '0'),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
      bookingTime.replaceAll(':', ''),
    ].join('_');

    return _firestore.collection('booking_slots').doc(slotId);
  }

  Future<BookingModel?> _findConflictingBooking({
    required String stylistId,
    required DateTime bookingDate,
    required String bookingTime,
    String? excludeBookingId,
  }) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('stylistId', isEqualTo: stylistId)
        .get();

    for (final doc in snapshot.docs) {
      if (excludeBookingId != null && doc.id == excludeBookingId) {
        continue;
      }

      final booking = BookingModel.fromFirestore(doc);
      if (booking.bookingTime == bookingTime &&
          _isSameDay(booking.bookingDate, bookingDate) &&
          _blockingStatuses.contains(booking.status)) {
        return booking;
      }
    }

    return null;
  }

  Future<bool> isSlotAvailable({
    required String stylistId,
    required DateTime bookingDate,
    required String bookingTime,
    String? excludeBookingId,
  }) async {
    final conflict = await _findConflictingBooking(
      stylistId: stylistId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      excludeBookingId: excludeBookingId,
    );
    return conflict == null;
  }

  Stream<Set<String>> streamBookedTimesForStylist({
    required String stylistId,
    required DateTime bookingDate,
  }) {
    return _firestore
        .collection('bookings')
        .where('stylistId', isEqualTo: stylistId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .where((booking) =>
                  _isSameDay(booking.bookingDate, bookingDate) &&
                  _blockingStatuses.contains(booking.status))
              .map((booking) => booking.bookingTime)
              .toSet();
        });
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
      await _firestore.runTransaction((transaction) async {
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        final bookingDoc = await transaction.get(bookingRef);
        if (!bookingDoc.exists) {
          throw Exception('Booking tidak ditemukan');
        }

        final booking = BookingModel.fromFirestore(bookingDoc);
        transaction.update(bookingRef, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final slotRef = _bookingSlotRef(
          stylistId: booking.stylistId,
          bookingDate: booking.bookingDate,
          bookingTime: booking.bookingTime,
        );

        if (_blockingStatuses.contains(status)) {
          transaction.set(slotRef, {
            'bookingId': bookingId,
            'stylistId': booking.stylistId,
            'barbershopId': booking.barbershopId,
            'bookingDate': Timestamp.fromDate(_dateOnly(booking.bookingDate)),
            'bookingTime': booking.bookingTime,
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          transaction.delete(slotRef);
        }
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
      await _firestore.runTransaction((transaction) async {
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        final bookingDoc = await transaction.get(bookingRef);
        if (!bookingDoc.exists) {
          throw Exception('Booking tidak ditemukan');
        }

        final booking = BookingModel.fromFirestore(bookingDoc);
        transaction.update(bookingRef, {
          'status': 'cancelled',
          'cancellationReason': reason,
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.delete(_bookingSlotRef(
          stylistId: booking.stylistId,
          bookingDate: booking.bookingDate,
          bookingTime: booking.bookingTime,
        ));
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Reschedule booking
  Future<void> rescheduleBooking(String bookingId, DateTime newDate, String newTime) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking tidak ditemukan');
      }

      final currentBooking = BookingModel.fromFirestore(bookingDoc);
      final conflict = await _findConflictingBooking(
        stylistId: currentBooking.stylistId,
        bookingDate: newDate,
        bookingTime: newTime,
        excludeBookingId: bookingId,
      );

      if (conflict != null) {
        throw Exception('Slot ini sudah dipesan. Silakan pilih waktu lain.');
      }

      await _firestore.runTransaction((transaction) async {
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        final currentDoc = await transaction.get(bookingRef);
        if (!currentDoc.exists) {
          throw Exception('Booking tidak ditemukan');
        }

        final currentBookingInTransaction = BookingModel.fromFirestore(currentDoc);
        final newSlotRef = _bookingSlotRef(
          stylistId: currentBookingInTransaction.stylistId,
          bookingDate: newDate,
          bookingTime: newTime,
        );
        final newSlotDoc = await transaction.get(newSlotRef);
        if (newSlotDoc.exists && newSlotDoc.data()?['bookingId'] != bookingId) {
          throw Exception('Slot ini sudah dipesan. Silakan pilih waktu lain.');
        }

        transaction.delete(_bookingSlotRef(
          stylistId: currentBookingInTransaction.stylistId,
          bookingDate: currentBookingInTransaction.bookingDate,
          bookingTime: currentBookingInTransaction.bookingTime,
        ));
        transaction.set(newSlotRef, {
          'bookingId': bookingId,
          'stylistId': currentBookingInTransaction.stylistId,
          'barbershopId': currentBookingInTransaction.barbershopId,
          'bookingDate': Timestamp.fromDate(_dateOnly(newDate)),
          'bookingTime': newTime,
          'status': 'rescheduled',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(bookingRef, {
          'bookingDate': Timestamp.fromDate(_dateOnly(newDate)),
          'bookingTime': newTime,
          'status': 'rescheduled',
          'rescheduledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to reschedule booking: $e');
    }
  }

  Future<void> releaseBookingSlotIfFinal(String bookingId, String status) async {
    if (_blockingStatuses.contains(status)) {
      return;
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        final bookingDoc = await transaction.get(bookingRef);
        if (!bookingDoc.exists) {
          return;
        }

        final booking = BookingModel.fromFirestore(bookingDoc);
        transaction.delete(_bookingSlotRef(
          stylistId: booking.stylistId,
          bookingDate: booking.bookingDate,
          bookingTime: booking.bookingTime,
        ));
      });
    } catch (e) {
      throw Exception('Failed to release booking slot: $e');
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
