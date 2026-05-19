class AppConstants {
  // App Info
  static const String appName = 'SalonHub';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String barbershopsCollection = 'barbershops';
  static const String stylistsCollection = 'stylists';
  static const String servicesCollection = 'services';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String paymentsCollection = 'payments';
  static const String promosCollection = 'promos';
  
  // User Roles
  static const String superadminRole = 'superadmin';
  static const String adminRole = 'admin';
  static const String userRole = 'user';
  
  // Booking Status
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingInProgress = 'in_progress';
  static const String bookingCompleted = 'completed';
  static const String bookingCancelled = 'cancelled';
  
  // Payment Methods
  static const String paymentQris = 'qris';
  static const String paymentCash = 'cash';
  static const String paymentTransfer = 'transfer';
  static const String paymentEwallet = 'ewallet';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Image Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Time
  static const int bookingTimeSlotDuration = 30; // minutes
  static const int maxBookingDaysAdvance = 30; // days
}
