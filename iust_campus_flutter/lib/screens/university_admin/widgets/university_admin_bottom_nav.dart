import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF073B4C);
const _gold = Color(0xFFF5B82E);
const _muted = Color(0xFF6F7F89);
const _white = Colors.white;
const _border = Color(0xFFDCE8EE);
const _lightBlue = Color(0xFFEAF4FB);

class UniversityAdminNavItem {
  final IconData icon;
  final String label;

  const UniversityAdminNavItem({required this.icon, required this.label});
}

class UniversityAdminBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const List<UniversityAdminNavItem> items = [
    UniversityAdminNavItem(
      icon: Icons.dashboard_rounded,
      label: 'لوحة التحكم',
    ),
    UniversityAdminNavItem(
      icon: Icons.people_alt_rounded,
      label: 'إدارة البيانات',
    ),
    UniversityAdminNavItem(
      icon: Icons.assignment_rounded,
      label: 'الطلبات',
    ),
    UniversityAdminNavItem(
      icon: Icons.description_rounded,
      label: 'التقارير',
    ),
    UniversityAdminNavItem(
      icon: Icons.shield_rounded,
      label: 'الحساب والأمان',
    ),
  ];

  const UniversityAdminBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
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
                        // Small gold indicator on top
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
                        // Tab button with light blue active background
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: active ? _lightBlue : Colors.transparent,
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
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                                  color: active ? _navy : _muted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
