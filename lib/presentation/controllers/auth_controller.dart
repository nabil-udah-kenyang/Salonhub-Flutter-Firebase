import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive variables
  var currentUser = Rxn<UserModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Getters
  UserModel? get user => currentUser.value;
  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?.role == AppConstants.adminRole;
  bool get isSuperAdmin => currentUser.value?.role == AppConstants.superadminRole;
  bool get isUser => currentUser.value?.role == AppConstants.userRole;

  @override
  void onInit() {
    super.onInit();
    // Only load current user if already logged in (don't use authStateChanges to avoid conflicts)
    if (_auth.currentUser != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        currentUser.value = userData;
      } else {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          currentUser.value = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? currentUser.value?.name ?? 'User',
            email: firebaseUser.email ?? currentUser.value?.email ?? '',
            phone: currentUser.value?.phone,
            photoUrl: firebaseUser.photoURL ?? currentUser.value?.photoUrl,
            role: currentUser.value?.role ?? AppConstants.userRole,
            isActive: currentUser.value?.isActive ?? true,
            isEmailVerified: firebaseUser.emailVerified,
            createdAt: currentUser.value?.createdAt ?? Timestamp.fromDate(DateTime.now()),
            updatedAt: Timestamp.fromDate(DateTime.now()),
            preferences: currentUser.value?.preferences,
          );
        }
      }
    } catch (e) {
      // Don't show error message on load, just log it
      print('Failed to load user data: $e');
      // If we have Firebase auth user but no Firestore data, create basic user model
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        currentUser.value = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          role: AppConstants.userRole,
          isActive: true,
          isEmailVerified: firebaseUser.emailVerified,
          createdAt: Timestamp.fromDate(DateTime.now()),
          updatedAt: Timestamp.fromDate(DateTime.now()),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentUser.value = user;
      print('Login successful: ${user.email}, role: ${user.role}');
      print('isLoggedIn: ${isLoggedIn}');
      return true;
    } catch (e) {
      // Better error messages
      String errorText = 'Login gagal. Silakan coba lagi.';
      if (e.toString().contains('user-not-found')) {
        errorText = 'Email tidak ditemukan. Silakan daftar terlebih dahulu.';
      } else if (e.toString().contains('wrong-password')) {
        errorText = 'Password salah. Silakan coba lagi.';
      } else if (e.toString().contains('invalid-email')) {
        errorText = 'Format email tidak valid.';
      } else if (e.toString().contains('too-many-requests')) {
        errorText = 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      } else {
        // Show actual error for debugging
        errorText = 'Login gagal: ${e.toString()}';
      }
      errorMessage.value = errorText;
      print('Login failed: $errorText');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = AppConstants.userRole,
    String? barbershopName,
    String? barbershopAddress,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authRepository.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        barbershopName: barbershopName,
        barbershopAddress: barbershopAddress,
      );

      currentUser.value = user;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.signOut();
      currentUser.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authRepository.resetPassword(email);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentUser.value != null) {
        final previousUser = currentUser.value!;
        await _authRepository.updateUserProfile(
          userId: previousUser.id!,
          name: name,
          phone: phone,
          photoUrl: photoUrl,
          preferences: preferences,
        );

        currentUser.value = previousUser.copyWith(
          name: name ?? previousUser.name,
          phone: phone,
          photoUrl: photoUrl ?? previousUser.photoUrl,
          preferences: preferences ?? previousUser.preferences,
          updatedAt: Timestamp.fromDate(DateTime.now()),
        );

        await refreshUserData();
        currentUser.refresh();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    await _loadUserData();
    currentUser.refresh();
  }
}
