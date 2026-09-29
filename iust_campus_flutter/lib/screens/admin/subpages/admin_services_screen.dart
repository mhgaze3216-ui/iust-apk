import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_header.dart';
import '../admin_management_screen.dart';
import '../admin_requests_screen.dart';
import '../admin_reports_screen.dart';
import 'admin_permissions_screen.dart';
import 'admin_maintenance_screen.dart';
import 'admin_announcements_moderation_screen.dart';
import 'admin_system_details_screen.dart';
import 'admin_system_log_screen.dart';
import 'admin_add_account_dialog.dart';
import '../../../data/academic_calendar_data.dart';
import '../../../data/transport_data.dart';
import '../../university_services/university_services_shell.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        appBar: AdminHeader(
          showBackButton: true,
          showNotificationBell: false,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'دليل الخدمات الإدارية',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'كافة الخدمات والأنظمة والعمليات المتاحة لإدارة الجامعة المركزية.',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: _textSub,
                ),
              ),
              const SizedBox(height: 16),

              // ── Featured Banner: الإدارة الجامعية ────────────────────────
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UniversityServicesShell(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_navy, Color(0xFF0F6CBD)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.hub_rounded, color: Color(0xFFF5B82E), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'الإدارة الجامعية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5B82E),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'خدمات رقمية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _navy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'منظومة الخدمات الإدارية الموحدة للطلاب والدكاترة والموظفين',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── 1. الحسابات والصلاحيات ───────────────────────────────
              _buildCategoryHeader('الحسابات والصلاحيات'),
              const SizedBox(height: 8),
              _buildServiceGrid(context, [
                _ServiceTile(
                  icon: Icons.people_alt_rounded,
                  iconBg: const Color(0xFFEAF4FB),
                  iconColor: const Color(0xFF0F6CBD),
                  title: 'إدارة الطلاب',
                  subtitle: 'سجلات وبيانات الطلاب',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminManagementScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.school_rounded,
                  iconBg: const Color(0xFFF5F0FF),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'إدارة أعضاء الهيئة',
                  subtitle: 'كادر التدريس والمقررات',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminManagementScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.person_add_alt_1_rounded,
                  iconBg: const Color(0xFFEDFAF1),
                  iconColor: const Color(0xFF2E9B5F),
                  title: 'إضافة حساب',
                  subtitle: 'إنشاء حساب طالب أو دكتور',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AdminAddAccountDialog(
                        onAccountCreated: (newAcc) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إنشاء حساب ${newAcc.name} بنجاح', style: GoogleFonts.cairo()),
                              backgroundColor: const Color(0xFF2E9B5F),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.security_rounded,
                  iconBg: const Color(0xFFFFF4D6),
                  iconColor: const Color(0xFFB78103),
                  title: 'إدارة الصلاحيات',
                  subtitle: 'تعديل أذونات المجموعات',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminPermissionsScreen()),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 20),

              // ── 2. الطلبات والمعاملات ───────────────────────────────
              _buildCategoryHeader('الطلبات والمعاملات'),
              const SizedBox(height: 8),
              _buildServiceGrid(context, [
                _ServiceTile(
                  icon: Icons.assignment_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  title: 'الطلبات والمعاملات',
                  subtitle: 'متابعة المعاملات الجارية',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminRequestsScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.build_circle_rounded,
                  iconBg: const Color(0xFFFEF2F2),
                  iconColor: const Color(0xFFDC2626),
                  title: 'بلاغات الصيانة',
                  subtitle: 'أعطال المرافق والتجهيزات',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminMaintenanceScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.rule_folder_rounded,
                  iconBg: const Color(0xFFFFFBEB),
                  iconColor: const Color(0xFFD97706),
                  title: 'الاعتراضات',
                  subtitle: 'مراجعة طلبات إعادة التصحيح',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminRequestsScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.history_edu_rounded,
                  iconBg: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF475569),
                  title: 'المعاملات الأكاديمية',
                  subtitle: 'شؤون الامتحانات والوثائق',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminRequestsScreen()),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 20),

              // ── 3. المحتوى والخدمات ──────────────────────────────────
              _buildCategoryHeader('المحتوى والخدمات'),
              const SizedBox(height: 8),
              _buildServiceGrid(context, [
                _ServiceTile(
                  icon: Icons.campaign_rounded,
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFEA580C),
                  title: 'الإعلانات والتعاميم',
                  subtitle: 'مراجعة واعتماد النشر',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminAnnouncementsModerationScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.directions_bus_rounded,
                  iconBg: const Color(0xFFFFF4D6),
                  iconColor: const Color(0xFFB78103),
                  title: 'النقل الجامعي',
                  subtitle: 'جداول ومسارات الحافلات',
                  onTap: () => _openTransportSheet(context),
                ),
                _ServiceTile(
                  icon: Icons.calendar_month_rounded,
                  iconBg: const Color(0xFFEDFAF1),
                  iconColor: const Color(0xFF2E9B5F),
                  title: 'التقويم الأكاديمي',
                  subtitle: 'مواعيد الامتحانات والتسجيل',
                  onTap: () => _openCalendarSheet(context),
                ),
                _ServiceTile(
                  icon: Icons.domain_rounded,
                  iconBg: const Color(0xFFF5F0FF),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'القاعات والمرافق',
                  subtitle: 'إشغال المدرجات والمخابر',
                  onTap: () => _openRoomsSheet(context),
                ),
              ]),

              const SizedBox(height: 20),

              // ── 4. النظام ──────────────────────────────────────────
              _buildCategoryHeader('النظام والأداء'),
              const SizedBox(height: 8),
              _buildServiceGrid(context, [
                _ServiceTile(
                  icon: Icons.bar_chart_rounded,
                  iconBg: const Color(0xFFEAF4FB),
                  iconColor: const Color(0xFF0F6CBD),
                  title: 'التقارير والإحصائيات',
                  subtitle: 'مؤشرات الأداء الجامعي',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.dns_rounded,
                  iconBg: const Color(0xFFEDFAF1),
                  iconColor: const Color(0xFF2E9B5F),
                  title: 'حالة الخدمات',
                  subtitle: 'صحة الخوادم والاتصال',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminSystemDetailsScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.cloud_sync_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  title: 'النسخ الاحتياطي',
                  subtitle: 'إدارة قواعد البيانات',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminSystemDetailsScreen()),
                    );
                  },
                ),
                _ServiceTile(
                  icon: Icons.history_rounded,
                  iconBg: const Color(0xFFF5F0FF),
                  iconColor: const Color(0xFF7C3AED),
                  title: 'سجل العمليات',
                  subtitle: 'تدقيق الأنشطة الإدارية',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminSystemLogScreen()),
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, List<_ServiceTile> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          onTap: item.onTap,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: _textSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTransportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة النقل الجامعي',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'حالة الخطوط ومواعيد انطلاق الحافلات الرسمية.',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
              const SizedBox(height: 12),
              ...kMorning1.take(3).map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.directions_bus_outlined, color: _blue),
                    title: Text(r.area, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('موعد الانطلاق: ${r.departureTime} · الاتجاه: إلى الجامعة', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                    trailing: const Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _openCalendarSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التقويم الأكاديمي للجامعة',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'المواعيد الرسمية المعتمدة للفصل الدراسي الحالي.',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
              const SizedBox(height: 12),
              ...kAcademicCalendar.take(3).map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined, color: Color(0xFF2E9B5F)),
                    title: Text(e.titleAr, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('${e.startDate.toString().split(' ')[0]} · ${e.type.labelAr}', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _openRoomsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إشغال القاعات والمرافق',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'نسبة الإشغال الإجمالية: 91% (ضمن المعدل الطبيعي).',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.domain_outlined, color: Color(0xFF7C3AED)),
                title: Text('مبنى الهندسات والمعلوماتية', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text('34 قاعة ومخبر · الإشغال 94%', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.domain_outlined, color: Color(0xFF7C3AED)),
                title: Text('مبنى طب الأسنان والصيدلة', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text('28 مدرج وعيادة · الإشغال 88%', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
