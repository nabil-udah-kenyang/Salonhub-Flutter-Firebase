import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw Exception('User not found');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = UserModel.fromFirestore(userDoc);
        String? seedOwnerId;
        if (user.email == 'admin@barberking.com') {
          seedOwnerId = 'admin_barberking';
        } else if (user.email == 'admin@urbangroom.com') {
          seedOwnerId = 'admin_urban_groom';
        }

        if (seedOwnerId != null && userData.role != AppConstants.adminRole) {
          final updatedPreferences = Map<String, dynamic>.from(userData.preferences ?? {});
          updatedPreferences['barbershopOwnerId'] = seedOwnerId;
          await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
            'role': AppConstants.adminRole,
            'preferences': updatedPreferences,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return userData.copyWith(
            role: AppConstants.adminRole,
            preferences: updatedPreferences,
          );
        }

        if (seedOwnerId != null) {
          final currentSeedOwnerId = userData.preferences?['barbershopOwnerId']?.toString();
          if (currentSeedOwnerId != seedOwnerId) {
            final updatedPreferences = Map<String, dynamic>.from(userData.preferences ?? {});
            updatedPreferences['barbershopOwnerId'] = seedOwnerId;
            await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
              'preferences': updatedPreferences,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            return userData.copyWith(preferences: updatedPreferences);
          }
        }

        return userData;
      }

      String userRole = AppConstants.userRole;
      if (user.email == 'superadmin@salonhub.com') {
        userRole = AppConstants.superadminRole;
      } else if (user.email == 'admin@salonhub.com' ||
          user.email == 'admin@barberking.com' ||
          user.email == 'admin@urbangroom.com') {
        userRole = AppConstants.adminRole;
      }

      String? seedOwnerId;
      if (user.email == 'admin@barberking.com') {
        seedOwnerId = 'admin_barberking';
      } else if (user.email == 'admin@urbangroom.com') {
        seedOwnerId = 'admin_urban_groom';
      }

      final userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        role: userRole,
        isActive: true,
        isEmailVerified: user.emailVerified,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
        preferences: seedOwnerId == null ? null : {'barbershopOwnerId': seedOwnerId},
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));
      
      print('Login successful: ${user.email}, role: ${userModel.role}');
      return userModel;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = AppConstants.userRole,
    String? barbershopName,
    String? barbershopAddress,
  }) async {
    try {
      // Create user with email and password
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Send email verification
      await user.sendEmailVerification();

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        isEmailVerified: false,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      if (role == AppConstants.adminRole) {
        final trimmedBarbershopName = barbershopName?.trim() ?? '';
        final trimmedBarbershopAddress = barbershopAddress?.trim() ?? '';

        if (trimmedBarbershopName.isEmpty || trimmedBarbershopAddress.isEmpty) {
          throw Exception('Nama dan alamat barbershop wajib diisi');
        }

        final barbershopRef = _firestore.collection(AppConstants.barbershopsCollection).doc();
        await barbershopRef.set({
          'name': trimmedBarbershopName,
          'description': 'Barbershop partner SalonHub',
          'address': trimmedBarbershopAddress,
          'photos': <String>[],
          'gallery': <String>[],
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'whatsapp': phone.trim(),
          'operatingHours': <String, Map<String, dynamic>>{
            'monday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'tuesday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'wednesday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'thursday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'friday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'saturday': {'isOpen': true, 'open': '09:00', 'close': '21:00'},
            'sunday': {'isOpen': true, 'open': '10:00', 'close': '20:00'},
          },
          'closedDays': <String>[],
          'rating': 0.0,
          'totalReviews': 0,
          'ownerId': user.uid,
          'isActive': true,
          'isApproved': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return userModel;
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      // Safely extract data with proper type checking
      final data = userDoc.data() as Map<String, dynamic>;
      final resolvedName = data['name']?.toString().trim().isNotEmpty == true
          ? data['name'].toString()
          : data['fullName']?.toString().trim().isNotEmpty == true
              ? data['fullName'].toString()
              : data['displayName']?.toString().trim().isNotEmpty == true
                  ? data['displayName'].toString()
                  : data['username']?.toString().trim().isNotEmpty == true
                      ? data['username'].toString()
                      : user.displayName ?? 'User';
      final resolvedPhone = data['phone']?.toString().trim().isNotEmpty == true
          ? data['phone'].toString()
          : data['phoneNumber']?.toString().trim().isNotEmpty == true
              ? data['phoneNumber'].toString()
              : null;
      final resolvedPhotoUrl = data['photoUrl']?.toString().trim().isNotEmpty == true
          ? data['photoUrl'].toString()
          : data['avatar']?.toString().trim().isNotEmpty == true
              ? data['avatar'].toString()
              : user.photoURL;

      return UserModel(
        id: userDoc.id,
        name: resolvedName,
        email: data['email']?.toString() ?? user.email ?? '',
        phone: resolvedPhone,
        photoUrl: resolvedPhotoUrl,
        role: data['role']?.toString() ?? AppConstants.userRole,
        isActive: data['isActive'] as bool? ?? true,
        isEmailVerified: data['isEmailVerified'] as bool? ?? user.emailVerified,
        createdAt: data['createdAt'] as Timestamp?,
        updatedAt: data['updatedAt'] as Timestamp?,
        preferences: data['preferences'] as Map<String, dynamic>?,
        deviceId: data['deviceId']?.toString(),
      );
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updateData['name'] = name;
        updateData['fullName'] = name;
        updateData['displayName'] = name;
        updateData['username'] = name;
      }
      updateData['phone'] = phone;
      updateData['phoneNumber'] = phone;
      updateData['photoUrl'] = photoUrl;
      updateData['avatar'] = photoUrl;
      if (preferences != null) updateData['preferences'] = preferences;

      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        if (name != null && name.isNotEmpty) {
          await firebaseUser.updateDisplayName(name);
        }
        if (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http')) {
          await firebaseUser.updatePhotoURL(photoUrl);
        }
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Check if user is admin or superadmin
  Future<bool> isAdmin() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      return user.role == AppConstants.adminRole || 
             user.role == AppConstants.superadminRole;
    } catch (e) {
      return false;
    }
  }

  // Check if user is superadmin
  Future<bool> isSuperAdmin() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      return user.role == AppConstants.superadminRole;
    } catch (e) {
      return false;
    }
  }

  // Stream auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role
  Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }
}
