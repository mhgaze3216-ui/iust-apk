import 'package:flutter/material.dart';

import 'widgets/university_admin_bottom_nav.dart';
import 'university_administration_home_screen.dart';
import 'admin_requests_screen_v2.dart';
import 'admin_transactions_guide_screen.dart';
import 'subpages/admin_user_management_screen.dart';
import 'admin_account_screen_v2.dart';
import '../../data/university_admin_repository.dart';

class UniversityAdministrationShell extends StatefulWidget {
  final int initialTab;

  const UniversityAdministrationShell({super.key, this.initialTab = 0});

  @override
  State<UniversityAdministrationShell> createState() =>
      _UniversityAdministrationShellState();
}

class _UniversityAdministrationShellState
    extends State<UniversityAdministrationShell> {
  late int _selectedIndex;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _loadFuture = UniversityAdminRepository.initializeFromApi();
  }

  void _retryLoad() {
    setState(() {
      _loadFuture = UniversityAdminRepository.initializeFromApi();
    });
  }

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تعذر تحميل بيانات الإدارة من الخادم.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retryLoad,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildShell();
      },
    );
  }

  Widget _buildShell() {
    final screens = <Widget>[
      UniversityAdministrationHomeScreen(onNavigateTab: _onTabTapped),
      const AdminUserManagementScreen(isRootTab: true),
      const AdminRequestsScreenV2(isRootTab: true),
      const AdminTransactionsGuideScreen(isRootTab: true),
      const AdminAccountScreenV2(),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F9FC),
          extendBody: true,
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: UniversityAdminBottomNav(
            selectedIndex: _selectedIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
