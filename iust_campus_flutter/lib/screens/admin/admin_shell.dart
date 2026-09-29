import 'package:flutter/material.dart';
import 'widgets/admin_bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_account_screen.dart';

/// The central shell for the Admin module, housing the floating 5-tab bottom navigation.
class AdminShell extends StatefulWidget {
  final int initialTabIndex;

  const AdminShell({super.key, this.initialTabIndex = 0});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _currentIndex;

  static const List<AdminNavItem> _navItems = [
    AdminNavItem(
      icon: Icons.dashboard_rounded,
      label: 'لوحة التحكم',
    ),
    AdminNavItem(
      icon: Icons.manage_accounts_rounded,
      label: 'الإدارة',
    ),
    AdminNavItem(
      icon: Icons.assignment_rounded,
      label: 'الطلبات',
    ),
    AdminNavItem(
      icon: Icons.bar_chart_rounded,
      label: 'التقارير',
    ),
    AdminNavItem(
      icon: Icons.person_rounded,
      label: 'حسابي',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  String? _managementFilter;
  String? _requestsFilter;

  void _onTabSelected(int index, {String? filter}) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _managementFilter = filter;
      } else if (index == 2) {
        _requestsFilter = filter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // 5 tabs preserved via IndexedStack
            IndexedStack(
              index: _currentIndex,
              children: [
                AdminDashboardScreen(
                  onNavigateToTab: (index, {filter}) => _onTabSelected(index, filter: filter),
                ),
                AdminManagementScreen(initialFilter: _managementFilter),
                AdminRequestsScreen(initialFilter: _requestsFilter),
                const AdminReportsScreen(),
                const AdminAccountScreen(),
              ],
            ),

            // Floating 5-tab bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AdminFloatingBottomNav(
                selectedIndex: _currentIndex,
                items: _navItems,
                onTap: _onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
