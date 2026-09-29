import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../welcome_screen.dart';
import 'guest_faculties_screen.dart';
import '../campus_map_screen.dart';
import 'guest_services_hub_screen.dart';
import '../university_info_screen.dart';
import 'guest_help_and_contact_screen.dart';

// ── palette ────────────────────────────────────────────────────────────────
const _navy   = Color(0xFF073B4C);
const _gold   = Color(0xFFF5B82E);
const _muted  = Color(0xFF6F7F89);
const _white  = Colors.white;
const _border = Color(0xFFDCE8EE);
const _activeBg = Color(0xFFEAF4FB);

class GuestShell extends StatefulWidget {
  final int initialIndex;
  const GuestShell({super.key, this.initialIndex = 0});

  @override
  State<GuestShell> createState() => _GuestShellState();
}

class _GuestShellState extends State<GuestShell> {
  late int _index;

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded,            label: 'الرئيسية'),
    _NavItem(icon: Icons.account_balance_rounded, label: 'الكليات'),
    _NavItem(icon: Icons.map_rounded,             label: 'الخريطة'),
    _NavItem(icon: Icons.grid_view_rounded,        label: 'الخدمات'),
    _NavItem(icon: Icons.info_outline_rounded,    label: 'عن الجامعة'),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = [
      WelcomeScreen(
        isRootTab: true,
        onNavigateTab: (targetIndex) {
          if (mounted) setState(() => _index = targetIndex);
        },
      ),
      const GuestFacultiesScreen(),
      const CampusMapScreen(),
      GuestServicesHubScreen(
        onNavigateTab: (targetIndex) {
          if (mounted) setState(() => _index = targetIndex);
        },
      ),
      const UniversityInfoScreen(isRootTab: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            heroTag: 'guest_help_contact_fab',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GuestHelpAndContactScreen(),
              ),
            ),
            backgroundColor: _navy,
            foregroundColor: _white,
            elevation: 0,
            highlightElevation: 2,
            shape: const CircleBorder(),
            tooltip: 'الأسئلة والتواصل',
            child: const Icon(Icons.help_outline_rounded, size: 22),
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

// ── custom FAB location: physical right edge above floating nav ─────────────
class _RightAboveNavFabLocation extends FloatingActionButtonLocation {
  const _RightAboveNavFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double bottomInset = scaffoldGeometry.minViewPadding.bottom;
    final double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width - 16.0;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
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
          height: 72,
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
                final item   = items[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // gold indicator dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            color: active ? _gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: active ? _activeBg : Colors.transparent,
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
                              const SizedBox(height: 1),
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
