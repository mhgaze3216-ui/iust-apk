import 'package:flutter/material.dart';

import 'widgets/university_services_bottom_nav.dart';
import 'university_administration_services_screen.dart';
import 'university_requests_screen.dart';
import 'transactions_guide_screen.dart';
import 'university_news_screen.dart';
import 'university_account_screen.dart';

import 'subpages/administrative_chat_screen.dart';
import '../../data/university_services_demo_data.dart';

/// The central shell for the University Administrative Services module (الإدارة الجامعية),
/// hosting the 5-tab floating bottom navigation and coordinating tab navigation.
class UniversityServicesShell extends StatefulWidget {
  final int initialTabIndex;

  const UniversityServicesShell({super.key, this.initialTabIndex = 0});

  @override
  State<UniversityServicesShell> createState() =>
      _UniversityServicesShellState();
}

class _UniversityServicesShellState extends State<UniversityServicesShell> {
  late int _currentIndex;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _loadFuture = UniversityServicesRepository.initializeFromApi();
  }

  void _retryLoad() {
    setState(() {
      _loadFuture = UniversityServicesRepository.initializeFromApi();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
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
                  const Text('تعذر تحميل بيانات الخدمات الجامعية من الخادم.'),
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

  Widget _buildShell() => PopScope(
    canPop: _currentIndex == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
        });
      }
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: Stack(
        children: [
          // 5 tabs preserved via IndexedStack
          IndexedStack(
            index: _currentIndex,
            children: [
              UniversityAdministrationServicesScreen(
                onNavigateToTab: _onTabSelected,
              ),
              const UniversityRequestsScreen(),
              const TransactionsGuideScreen(),
              const UniversityNewsScreen(),
              const UniversityAccountScreen(),
            ],
          ),

          // Floating 5-tab bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: UniversityServicesFloatingBottomNav(
              selectedIndex: _currentIndex,
              onTap: _onTabSelected,
            ),
          ),
        ],
      ),
      // Floating chat button on physical right side above floating bottom nav
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF073B4C).withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            heroTag: 'administrative_staff_chat_fab',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdministrativeChatScreen(),
              ),
            ),
            backgroundColor: const Color(0xFF073B4C),
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 2,
            shape: const CircleBorder(),
            tooltip: 'المحادثات الإدارية',
            child: const Icon(Icons.chat_rounded, size: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: const _RightAboveNavFabLocation(),
    ),
  );
}

// ── custom FAB location: fixed to physical right edge above floating nav ────
class _RightAboveNavFabLocation extends FloatingActionButtonLocation {
  const _RightAboveNavFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double bottomInset = scaffoldGeometry.minViewPadding.bottom;
    final double fabX =
        scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16.0;
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        (bottomInset + 96.0);
    return Offset(fabX, fabY);
  }
}
