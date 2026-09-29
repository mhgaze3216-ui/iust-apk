import 'package:flutter/material.dart';
import 'widgets/university_admin_header.dart';
import 'admin_requests_screen_v2.dart';
import 'admin_transactions_guide_screen.dart';
import 'subpages/admin_appointments_screen.dart';
import 'subpages/admin_accounts_screen_v2.dart';
import 'subpages/admin_news_screen.dart';
import 'subpages/admin_transport_management_screen.dart';
import 'subpages/admin_user_management_screen.dart';
import 'subpages/admin_administration_users_screen.dart';

class UniversityAdministrationHomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const UniversityAdministrationHomeScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<UniversityAdministrationHomeScreen> createState() =>
      _UniversityAdministrationHomeScreenState();
}

class _UniversityAdministrationHomeScreenState
    extends State<UniversityAdministrationHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _servicesGridKey = GlobalKey();

  void _scrollToServices() {
    final ctx = _servicesGridKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const goldCol = Color(0xFFF5B82E);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              // Top Header (Logo, notification bell, lang)
              const UniversityAdminHeader(
                showBack: false,
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // ── 1. Hero Card ─────────────────────────────────────────
                    Container(
                      height: 215,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: navyCol.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/img/iust.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              navyCol.withValues(alpha: 0.92),
                              blueCol.withValues(alpha: 0.82),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: goldCol.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: goldCol.withValues(alpha: 0.5)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars_rounded, color: goldCol, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'مركز التحكم والإدارة الشاملة',
                                        style: TextStyle(
                                          color: goldCol,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الإدارة المركزية',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تحكم شامل بكافة حسابات الطلاب والدكاترة والإداريين والخدمات.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldCol,
                                  foregroundColor: navyCol,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: _scrollToServices,
                                icon: const Icon(Icons.dashboard_customize_rounded, size: 16),
                                label: const Text(
                                  'أقسام التحكم',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Compact Home Status Cards ─────────────────────────
                    Row(
                      children: [
                        // Card 1: طلبات جديدة
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(2); // Go to Requests tab (index 2)
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminRequestsScreenV2(isRootTab: false),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardCol,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
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
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'طلبات جديدة',
                                        style: TextStyle(
                                          color: textSec,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: lightBlue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.inbox_rounded, color: blueCol, size: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '12',
                                    style: TextStyle(
                                      color: navyCol,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'تحتاج إلى متابعة',
                                    style: TextStyle(
                                      color: Color(0xFFE67E22),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: مواعيد اليوم
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminAppointmentsScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardCol,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
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
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'مواعيد اليوم',
                                        style: TextStyle(
                                          color: textSec,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF4D6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.calendar_month_rounded, color: goldCol, size: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    '8',
                                    style: TextStyle(
                                      color: navyCol,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'موعداً إدارياً',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── 3. Role Groups Shortcuts (Requirement 13) ────────────
                    Row(
                      children: [
                        const Text(
                          'المجموعات والحسابات',
                          style: TextStyle(
                            color: navyCol,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(1); // Go to Data tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminUserManagementScreen(),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            children: [
                              Text(
                                'إدارة المستخدمين',
                                style: TextStyle(
                                  color: blueCol,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_back_ios_rounded, size: 12, color: blueCol),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 3-Shortcut Row (الطلاب, الدكاترة, الإداريون)
                    Row(
                      children: [
                        // Shortcut 1: الطلاب
                        Expanded(
                          child: _buildRoleShortcut(
                            title: 'الطلاب',
                            count: 'حسابات الطلبة',
                            icon: Icons.school_rounded,
                            iconBg: lightBlue,
                            iconColor: blueCol,
                            cardCol: cardCol,
                            borderCol: borderCol,
                            navyCol: navyCol,
                            textSec: textSec,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminUserManagementScreen(
                                    initialRoleFilter: 'الطلاب',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Shortcut 2: الدكاترة
                        Expanded(
                          child: _buildRoleShortcut(
                            title: 'الدكاترة',
                            count: 'هيئة التدريس',
                            icon: Icons.badge_rounded,
                            iconBg: const Color(0xFFF5F0FF),
                            iconColor: const Color(0xFF7C3AED),
                            cardCol: cardCol,
                            borderCol: borderCol,
                            navyCol: navyCol,
                            textSec: textSec,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminUserManagementScreen(
                                    initialRoleFilter: 'الدكاترة',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Shortcut 3: الإداريون
                        Expanded(
                          child: _buildRoleShortcut(
                            title: 'الإداريون',
                            count: 'الكادر الإداري',
                            icon: Icons.admin_panel_settings_rounded,
                            iconBg: const Color(0xFFFFF4D6),
                            iconColor: const Color(0xFFD97706),
                            cardCol: cardCol,
                            borderCol: borderCol,
                            navyCol: navyCol,
                            textSec: textSec,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminAdministrationUsersScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 4. Main Admin Control Sections (Requirement 14) ──────
                    Row(
                      key: _servicesGridKey,
                      children: [
                        const Text(
                          'أقسام التحكم والإدارة',
                          style: TextStyle(
                            color: navyCol,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '6 محاور رئيسية',
                            style: TextStyle(
                              color: blueCol,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2-Column Clean Master Control Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.18,
                      children: [
                        // 1. إدارة المستخدمين (Requirement 14.1)
                        _buildServiceCard(
                          title: 'إدارة المستخدمين',
                          description: 'إدارة حسابات الطلاب والدكاترة والدخول لواجهاتهم',
                          icon: Icons.manage_accounts_rounded,
                          iconBg: lightBlue,
                          iconColor: blueCol,
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(1); // Go to Users/Data tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminUserManagementScreen(),
                                ),
                              );
                            }
                          },
                        ),

                        // 2. إدارة الطلبات (Requirement 14.2)
                        _buildServiceCard(
                          title: 'إدارة الطلبات',
                          description: 'تابع الطلبات الإدارية واعتمادها واتخاذ الإجراءات',
                          icon: Icons.assignment_turned_in_outlined,
                          iconBg: const Color(0xFFEDFAF1),
                          iconColor: const Color(0xFF16A34A),
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(2);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminRequestsScreenV2(isRootTab: false),
                                ),
                              );
                            }
                          },
                        ),

                        // 3. المحتوى والإعلانات (Requirement 14.3)
                        _buildServiceCard(
                          title: 'المحتوى والإعلانات',
                          description: 'نشر ومتابعة إعلانات وأخبار وتعاليم الجامعة',
                          icon: Icons.campaign_outlined,
                          iconBg: const Color(0xFFFDF2E9),
                          iconColor: const Color(0xFFE67E22),
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminNewsScreen(),
                              ),
                            );
                          },
                        ),

                        // 4. النقل الجامعي (Requirement 14.4)
                        _buildServiceCard(
                          title: 'النقل الجامعي',
                          description: 'إدارة الجداول والمسارات والتنبيهات وحافلات النقل',
                          icon: Icons.directions_bus_outlined,
                          iconBg: const Color(0xFFFFF4D6),
                          iconColor: const Color(0xFFD97706),
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminTransportManagementScreen(),
                              ),
                            );
                          },
                        ),

                        // 5. التقارير (Requirement 14.5)
                        _buildServiceCard(
                          title: 'التقارير والمعاملات',
                          description: 'دليل المعاملات وإحصائيات العمليات الجامعية',
                          icon: Icons.analytics_outlined,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: blueCol,
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(3); // Reports tab
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminTransactionsGuideScreen(isRootTab: false),
                                ),
                              );
                            }
                          },
                        ),

                        // 6. الصلاحيات والنظام (Requirement 14.6)
                        _buildServiceCard(
                          title: 'الصلاحيات والنظام',
                          description: 'التحكم بالصلاحيات وحالة الخدمات والنسخ الاحتياطي',
                          icon: Icons.security_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          cardCol: cardCol,
                          borderCol: borderCol,
                          textMain: textMain,
                          textSec: textSec,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminAccountsScreenV2(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleShortcut({
    required String title,
    required String count,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardCol,
    required Color borderCol,
    required Color navyCol,
    required Color textSec,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: navyCol,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: TextStyle(
                color: textSec,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardCol,
    required Color borderCol,
    required Color textMain,
    required Color textSec,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: textSec,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
