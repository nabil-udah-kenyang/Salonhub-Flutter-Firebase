import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/navigation/superadmin_bottom_navbar.dart';
import 'superadmin_home_page.dart';
import 'superadmin_users_page.dart';
import 'superadmin_barbershops_page.dart';
import 'superadmin_analytics_page.dart';

class SuperadminMainPage extends StatefulWidget {
  const SuperadminMainPage({super.key});

  @override
  State<SuperadminMainPage> createState() => _SuperadminMainPageState();
}

class _SuperadminMainPageState extends State<SuperadminMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SuperadminHomePage(),
    const SuperadminUsersPage(),
    const SuperadminBarbershopsPage(),
    const SuperadminAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SuperadminBottomNavbar(
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
