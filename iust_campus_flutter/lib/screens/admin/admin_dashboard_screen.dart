import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_demo_data.dart';
import 'widgets/admin_header.dart';
import 'subpages/admin_notifications_screen.dart';
import 'subpages/admin_maintenance_screen.dart';
import 'subpages/admin_announcements_moderation_screen.dart';
import 'subpages/admin_services_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _gold = Color(0xFFF5B82E);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex, {String? filter})? onNavigateToTab;

  const AdminDashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Header
              AdminHeader(
                showNotificationBell: true,
                unreadCount: AdminDemoData.unreadNotificationsCount,
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },
              ),

              // Scrollable Dashboard Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  children: [
                    // 2. Compact Administration Profile / Hero
                    _buildCompactHero(),
                    const SizedBox(height: 12),

                    // 3. Important Status / Alert
                    _buildImportantStatusAlert(context),
                    const SizedBox(height: 16),

                    // 4. Overview Section (2x2 Grid)
                    _buildSectionHeader('نظرة عامة على الجامعة'),
                    const SizedBox(height: 8),
                    _buildOverviewGrid(context),
                    const SizedBox(height: 18),

                    // 5. Today's Priorities Section
                    _buildSectionHeader('أولويات اليوم الإدارية'),
                    const SizedBox(height: 8),
                    _buildTodayPriorities(context),
                    const SizedBox(height: 18),

                    // 6. Quick Actions Section (4 cards + "عرض جميع الخدمات")
                    _buildSectionHeader('الوصول السريع'),
                    const SizedBox(height: 8),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _textMain,
      ),
    );
  }

  // ── 2. Compact Administration Hero ─────────────────────────────────────────
  Widget _buildCompactHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Text(
              'رح',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'م. رنا الحسن',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'مركز إدارة الجامعة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'مسؤولة النظام والخدمات',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Important Status / Alert ───────────────────────────────────────────
  Widget _buildImportantStatusAlert(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDFAF1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة المنظومة: جاهزية 96% ومستقرة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                  Text(
                    'جميع خوادم وبوابات الجامعة متصلة وتعمل بصورة اعتيادية.',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: Color(0xFF15803D), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 4. Overview Section (2x2 Grid) ─────────────────────────────────────────
  Widget _buildOverviewGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          title: 'الطلاب',
          value: '2,486',
          subtitle: 'مسجلون رسمياً',
          icon: Icons.people_alt_rounded,
          iconBg: const Color(0xFFEAF4FB),
          iconColor: const Color(0xFF0F6CBD),
          onTap: () {
            onNavigateToTab?.call(1, filter: 'طالب');
          },
        ),
        _buildStatCard(
          title: 'أعضاء هيئة التدريس',
          value: '164',
          subtitle: 'في كافة الفصول',
          icon: Icons.school_rounded,
          iconBg: const Color(0xFFF5F0FF),
          iconColor: const Color(0xFF7C3AED),
          onTap: () {
            onNavigateToTab?.call(1, filter: 'هيئة تدريسية');
          },
        ),
        _buildStatCard(
          title: 'الطلبات المفتوحة',
          value: '23',
          subtitle: '8 بحاجة لمراجعة',
          icon: Icons.assignment_late_rounded,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFEA580C),
          onTap: () {
            onNavigateToTab?.call(2);
          },
        ),
        _buildStatCard(
          title: 'الخدمات',
          value: '29',
          subtitle: 'خدمة نشطة',
          icon: Icons.widgets_rounded,
          iconBg: const Color(0xFFEDFAF1),
          iconColor: const Color(0xFF2E9B5F),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(fontSize: 10, color: _textSub),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. Today's Priorities Section ──────────────────────────────────────────
  Widget _buildTodayPriorities(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriorityTile(
            title: 'طلبات تحتاج مراجعة',
            count: '8',
            subtitle: 'أقدم طلب منذ 3 ساعات',
            icon: Icons.assignment_late_outlined,
            color: const Color(0xFFEA580C),
            bg: const Color(0xFFFFF7ED),
            onTap: () {
              onNavigateToTab?.call(2, filter: 'قيد المراجعة');
            },
          ),
          const Divider(height: 1, color: _border, indent: 56),
          _buildPriorityTile(
            title: 'بلاغات صيانة',
            count: '3',
            subtitle: 'جميعها ضمن كلية الهندسات',
            icon: Icons.build_circle_outlined,
            color: const Color(0xFFDC2626),
            bg: const Color(0xFFFEF2F2),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminMaintenanceScreen()),
              );
            },
          ),
          const Divider(height: 1, color: _border, indent: 56),
          _buildPriorityTile(
            title: 'إعلان بانتظار النشر',
            count: '1',
            subtitle: 'تحديث دوام النقل الجامعي',
            icon: Icons.campaign_outlined,
            color: const Color(0xFF0F6CBD),
            bg: const Color(0xFFEFF6FF),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminAnnouncementsModerationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTile({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
          ],
        ),
      ),
    );
  }

  // ── 6. Quick Actions Section (4 cards in 2x2 + "عرض جميع الخدمات") ──────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: [
            _buildActionCard(
              title: 'إدارة الحسابات',
              subtitle: 'دليل المستخدمين',
              icon: Icons.manage_accounts_rounded,
              color: const Color(0xFF0F6CBD),
              bg: const Color(0xFFEAF4FB),
              onTap: () {
                onNavigateToTab?.call(1);
              },
            ),
            _buildActionCard(
              title: 'إدارة الطلبات',
              subtitle: 'المعاملات والتذاكر',
              icon: Icons.assignment_rounded,
              color: const Color(0xFFEA580C),
              bg: const Color(0xFFFFF7ED),
              onTap: () {
                onNavigateToTab?.call(2);
              },
            ),
            _buildActionCard(
              title: 'التقارير',
              subtitle: 'المؤشرات والتحليلات',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF7C3AED),
              bg: const Color(0xFFF5F0FF),
              onTap: () {
                onNavigateToTab?.call(3);
              },
            ),
            _buildActionCard(
              title: 'إدارة الخدمات',
              subtitle: 'الأنظمة والمرافق',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF2E9B5F),
              bg: const Color(0xFFEDFAF1),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
              );
            },
            icon: const Icon(Icons.apps_rounded, size: 18, color: _navy),
            label: Text(
              'عرض جميع الخدمات',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: _border),
              backgroundColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: _textSub,
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
  }
}
