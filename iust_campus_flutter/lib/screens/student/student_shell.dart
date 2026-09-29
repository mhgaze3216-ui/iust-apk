import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'student_home_screen.dart';
import 'student_courses_screen.dart';
import 'student_class_feed_screen.dart';
import 'student_account_screen.dart';
import '../campus_map_screen.dart';
import 'student_doctor_chat_screen.dart';

import '../../services/student_session.dart';
import '../../data/student_repository.dart';

// ── palette ────────────────────────────────────────────────────────────────
const _navy = Color(0xFF073B4C);
const _gold = Color(0xFFF5B82E);
const _muted = Color(0xFF6F7F89);
const _white = Colors.white;
const _border = Color(0xFFDCE8EE);

class StudentShell extends StatefulWidget {
  final String? studentId;
  const StudentShell({super.key, this.studentId});
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'موادي'),
    _NavItem(icon: Icons.forum_rounded, label: 'Class Feed'),
    _NavItem(icon: Icons.map_rounded, label: 'الخريطة'),
    _NavItem(icon: Icons.person_rounded, label: 'حسابي'),
  ];

  List<Widget>? _pages;
  String? _cachedStudentId;
  Future<void>? _loadFuture;
  String? _loadingStudentId;

  List<Widget> _getPages(String sid) {
    if (_pages == null || _cachedStudentId != sid) {
      _cachedStudentId = sid;
      _pages = [
        StudentHomeScreen(studentId: sid),
        StudentCoursesScreen(studentId: sid),
        StudentClassFeedScreen(studentId: sid),
        const CampusMapScreen(),
        StudentAccountScreen(studentId: sid),
      ];
    }
    return _pages!;
  }

  String _resolveStudentId() {
    final routeArg = ModalRoute.of(context)?.settings.arguments as String?;
    final sid = widget.studentId ?? routeArg ?? StudentSession.currentStudentId;
    if (sid != StudentSession.currentStudentId && sid.isNotEmpty) {
      StudentSession.setActiveStudentId(sid);
    }
    return sid;
  }

  @override
  Widget build(BuildContext context) {
    final sid = _resolveStudentId();
    if (_loadingStudentId != sid) {
      _loadingStudentId = sid;
      _loadFuture = StudentRepository.initializeFromApi(sid);
    }
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
                  const Text('تعذر تحميل بيانات الطالب من الخادم.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _loadFuture = StudentRepository.initializeFromApi(
                        sid,
                      ),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildShell(sid);
      },
    );
  }

  Widget _buildShell(String sid) {
    final pages = _getPages(sid);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
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
            heroTag: 'student_doctor_chat_fab',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StudentDoctorChatScreen(studentId: sid),
              ),
            ),
            backgroundColor: const Color(0xFF073B4C),
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 2,
            shape: const CircleBorder(),
            tooltip: 'التواصل مع الأساتذة',
            child: const Icon(Icons.chat_rounded, size: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: const _RightAboveNavFabLocation(),
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: _index,
        items: _navItems,
        onTap: (i) => setState(() => _index = i),
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

// ── nav item model ─────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── floating bottom nav ────────────────────────────────────────────────────
class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
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
                        // gold indicator dot
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
                                  fontSize: 9.0,
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
