import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/pages/auth/splash_screen.dart';
import '../presentation/pages/auth/signin_screen.dart';
import '../presentation/pages/user/user_main_page.dart';
import '../presentation/pages/admin/admin_main_page.dart';
import '../presentation/pages/superadmin/superadmin_main_page.dart';
import '../presentation/controllers/auth_controller.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String signin = '/signin';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // User routes
  static const String userHome = '/user';
  static const String userSearch = '/user/search';
  static const String userProfile = '/user/profile';
  static const String userBookings = '/user/bookings';
  static const String userFavorites = '/user/favorites';
  static const String barbershopDetail = '/user/barbershop-detail';
  static const String bookingFlow = '/user/booking-flow';
  static const String payment = '/user/payment';
  static const String paymentSuccess = '/user/payment-success';
  static const String paymentFailed = '/user/payment-failed';
  static const String invoice = '/user/invoice';
  
  // Admin routes
  static const String adminHome = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminBarbershop = '/admin/barbershop';
  static const String adminStylists = '/admin/stylists';
  static const String adminServices = '/admin/services';
  static const String adminBookings = '/admin/bookings';
  static const String adminReports = '/admin/reports';
  static const String adminReviews = '/admin/reviews';
  static const String adminPromos = '/admin/promos';
  
  // Superadmin routes
  static const String superadminHome = '/superadmin';
  static const String superadminDashboard = '/superadmin/dashboard';
  static const String superadminUsers = '/superadmin/users';
  static const String superadminBarbershops = '/superadmin/barbershops';
  static const String superadminReports = '/superadmin/reports';
  static const String superadminMonitoring = '/superadmin/monitoring';
  static const String superadminSettings = '/superadmin/settings';

  static List<GetPage> routes = [
    // Auth routes
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: signin,
      page: () => const SignInScreen(),
    ),
    
    // User routes
    GetPage(
      name: userHome,
      page: () => const UserMainPage(),
      middlewares: [RoleMiddleware(['user'])],
    ),
    
    // Admin routes
    GetPage(
      name: adminHome,
      page: () => const AdminMainPage(),
      middlewares: [RoleMiddleware(['admin', 'superadmin'])],
    ),
    
    // Superadmin routes
    GetPage(
      name: superadminHome,
      page: () => const SuperadminMainPage(),
      middlewares: [RoleMiddleware(['superadmin'])],
    ),
  ];
}

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;
  
  RoleMiddleware(this.allowedRoles);

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (!authController.isLoggedIn) {
      return RouteSettings(name: AppRoutes.signin);
    }
    
    final userRole = authController.user?.role;
    if (userRole == null || !allowedRoles.contains(userRole)) {
      // Redirect to appropriate home based on role
      switch (userRole) {
        case 'superadmin':
          return RouteSettings(name: AppRoutes.superadminHome);
        case 'admin':
          return RouteSettings(name: AppRoutes.adminHome);
        case 'user':
          return RouteSettings(name: AppRoutes.userHome);
        default:
          return RouteSettings(name: AppRoutes.signin);
      }
    }
    
    return null;
  }
}
