import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/navigation/admin_bottom_navbar.dart';
import 'admin_home_page.dart';
import 'admin_stylists_page.dart';
import 'admin_services_page.dart';
import 'admin_bookings_page.dart';
import 'admin_barbershop_profile_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomePage(),
    AdminStylistsPage(),
    AdminServicesPage(),
    const AdminBookingsPage(),
    const AdminBarbershopProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
