import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String userId;
  final String barbershopId;
  final String stylistId;
  final List<String> serviceIds;
  final DateTime bookingDate;
  final String bookingTime;
  final double totalPrice;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? notes;
  final String? promoCode;
  final double? discountAmount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? completedAt;
  final String? cancellationReason;
  final bool isReviewed;

  BookingModel({
    this.id,
    required this.userId,
    required this.barbershopId,
    required this.stylistId,
    required this.serviceIds,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalPrice,
    this.status = 'pending',
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.notes,
    this.promoCode,
    this.discountAmount,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancellationReason,
    this.isReviewed = false,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      barbershopId: data['barbershopId'] ?? '',
      stylistId: data['stylistId'] ?? '',
      serviceIds: List<String>.from(data['serviceIds'] ?? []),
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      bookingTime: data['bookingTime'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'pending',
      notes: data['notes'],
      promoCode: data['promoCode'],
      discountAmount: data['discountAmount']?.toDouble(),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      completedAt: data['completedAt'],
      cancellationReason: data['cancellationReason'],
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'barbershopId': barbershopId,
      'stylistId': stylistId,
      'serviceIds': serviceIds,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingTime': bookingTime,
      'totalPrice': totalPrice,
      'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      if (notes != null) 'notes': notes,
      if (promoCode != null) 'promoCode': promoCode,
      if (discountAmount != null) 'discountAmount': discountAmount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (completedAt != null) 'completedAt': completedAt,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'isReviewed': isReviewed,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? barbershopId,
    String? stylistId,
    List<String>? serviceIds,
    DateTime? bookingDate,
    String? bookingTime,
    double? totalPrice,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? notes,
    String? promoCode,
    double? discountAmount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? completedAt,
    String? cancellationReason,
    bool? isReviewed,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barbershopId: barbershopId ?? this.barbershopId,
      stylistId: stylistId ?? this.stylistId,
      serviceIds: serviceIds ?? this.serviceIds,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      promoCode: promoCode ?? this.promoCode,
      discountAmount: discountAmount ?? this.discountAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel{id: $id, userId: $userId, status: $status}';
  }
}
