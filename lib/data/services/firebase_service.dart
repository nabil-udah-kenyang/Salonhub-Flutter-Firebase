import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Firebase instances
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseMessaging get messaging => _messaging;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;

  // Initialize Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Configure Firestore settings
      await _firestore.settings.copyWith(
        persistenceEnabled: true,
        cacheSizeBytes: 10485760, // 10MB
      );

      // Request notification permissions
      await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
      }

      print('Firebase initialized successfully');
    } catch (e) {
      print('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  // Auth helper methods
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore helper methods
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get barbershopsCollection => _firestore.collection('barbershops');
  CollectionReference get stylistsCollection => _firestore.collection('stylists');
  CollectionReference get servicesCollection => _firestore.collection('services');
  CollectionReference get bookingsCollection => _firestore.collection('bookings');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get paymentsCollection => _firestore.collection('payments');
  CollectionReference get promosCollection => _firestore.collection('promos');

  // Storage helper methods
  Reference get usersStorage => _storage.ref().child('users');
  Reference get barbershopsStorage => _storage.ref().child('barbershops');
  Reference get servicesStorage => _storage.ref().child('services');

  // Utility methods
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> logError(String error, StackTrace stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
