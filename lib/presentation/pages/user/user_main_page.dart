import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/navigation/user_bottom_navbar.dart';
import 'user_home_page.dart';
import 'user_search_page.dart';
import 'user_bookings_page.dart';
import 'user_favorites_page.dart';
import 'user_profile_page.dart';

class UserMainPage extends StatefulWidget {
  final int? initialIndex;

  const UserMainPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex ?? 0).clamp(0, 4).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const UserHomePage(),
      const UserSearchPage(),
      const UserBookingsPage(),
      UserFavoritesPage(),
      const UserProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: UserBottomNavbar(
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
