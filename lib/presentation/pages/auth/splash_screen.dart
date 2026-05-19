import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final authController = Get.find<AuthController>();
    
    if (authController.isLoggedIn) {
      final userRole = authController.user?.role;
      switch (userRole) {
        case 'superadmin':
          Get.offAllNamed(AppRoutes.superadminHome);
          break;
        case 'admin':
          Get.offAllNamed(AppRoutes.adminHome);
          break;
        case 'user':
          Get.offAllNamed(AppRoutes.userHome);
          break;
        default:
          Get.offAllNamed(AppRoutes.signin);
      }
    } else {
      Get.offAllNamed(AppRoutes.signin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Image(
          image: AssetImage('lib/assets/images/logo.png'),
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
