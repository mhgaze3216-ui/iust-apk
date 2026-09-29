import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/doctor_session.dart';
import 'doctor_home_screen.dart';
import 'doctor_courses_screen.dart';
import 'doctor_attendance_screen.dart';
import 'doctor_community_screen.dart';
import 'doctor_account_screen.dart';
import 'doctor_chat_screen.dart';
import '../../data/doctor_repository.dart';

// ── palette matching app identity ──────────────────────────────────────────
const _navy = Color(0xFF073B4C);
const _gold = Color(0xFFF5B82E);
const _muted = Color(0xFF6F7F89);
const _white = Colors.white;
const _border = Color(0xFFDCE8EE);

class DoctorShell extends StatefulWidget {
  final String? doctorId;
  const DoctorShell({super.key, this.doctorId});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _index = 0;

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'مقرراتي'),
    _NavItem(icon: Icons.how_to_reg_rounded, label: 'الحضور'),
    _NavItem(icon: Icons.forum_rounded, label: 'المجتمع'),
    _NavItem(icon: Icons.person_rounded, label: 'حسابي'),
  ];

  late final List<Widget> _pages;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final docId = widget.doctorId ?? DoctorSession.currentDoctorId;
    if (docId.isNotEmpty && docId != DoctorSession.currentDoctorId) {
      DoctorSession.setActiveDoctorId(docId);
    }
    _loadFuture = DoctorRepository.initializeFromApi();
    _pages = [
      DoctorHomeScreen(onSelectTab: _onTabSelected),
      const DoctorCoursesScreen(),
      const DoctorAttendanceScreen(),
      const DoctorCommunityScreen(),
      const DoctorAccountScreen(),
    ];
  }

  String _resolveDoctorId() {
    final routeArg = ModalRoute.of(context)?.settings.arguments as String?;
    final did = widget.doctorId ?? routeArg ?? DoctorSession.currentDoctorId;
    if (did.isNotEmpty && did != DoctorSession.currentDoctorId) {
      DoctorSession.setActiveDoctorId(did);
    }
    return did;
  }

  void _onTabSelected(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _resolveDoctorId();
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
                  const Text('تعذر تحميل بيانات عضو هيئة التدريس من الخادم.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _loadFuture = DoctorRepository.initializeFromApi(),
                    ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            heroTag: 'doctor_chat_fab',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DoctorChatScreen(doctorId: _resolveDoctorId()),
              ),
            ),
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 2,
            shape: const CircleBorder(),
            tooltip: 'محادثات الطلاب',
            child: const Icon(Icons.chat_rounded, size: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: const _RightAboveNavFabLocation(),
      bottomNavigationBar: _DoctorFloatingBottomNav(
        selectedIndex: _index,
        items: _navItems,
        onTap: _onTabSelected,
      ),
    );
  }
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _DoctorFloatingBottomNav extends StatelessWidget {
  const _DoctorFloatingBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  final int selectedIndex;
  final List<_NavItem> items;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: _white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: List.generate(items.length, (i) {
                final active = i == selectedIndex;
                final item = items[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // gold indicator bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 3),
                          decoration: BoxDecoration(
                            color: active ? _gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? _gold.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: active ? _navy : _muted,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: GoogleFonts.cairo(
                                  fontSize: 9.5,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active ? _navy : _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
