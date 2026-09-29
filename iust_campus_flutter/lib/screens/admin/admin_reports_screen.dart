import 'package:flutter/material.dart';
import '../../data/admin_demo_data.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_weekly_chart.dart';
import 'subpages/admin_notifications_screen.dart';
import 'subpages/admin_create_report_sheet.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0F2537);
    const slateGray = Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              AdminHeader(
                title: 'التقارير والإحصائيات',
                subtitle: 'مؤشرات الأداء الجامعي ومعدلات استخدام الخدمات',
                showNotificationBell: true,
                unreadCount: AdminDemoData.unreadNotificationsCount,
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  children: [
                    // 1. KPI Cards Row
                    _buildKpiRow(),
                    const SizedBox(height: 18),

                    // 2. Weekly Activity Chart Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'النشاط الأسبوعي على المنظومة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: navyDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'نسب التفاعل اليومية للطلاب والأساتذة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: slateGray,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: Color(0xFF0F6CBD)),
                                    SizedBox(width: 4),
                                    Text(
                                      'الأسبوع الحالي',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F6CBD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const AdminWeeklyChart(data: AdminDemoData.weeklyActivity),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Most Used Services Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الخدمات الأكثر استخداماً',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: navyDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ترتيب الميزات حسب حجم التفاعل خلال الفصل الحالي',
                            style: TextStyle(
                              fontSize: 12,
                              color: slateGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...AdminDemoData.mostUsedServices.map((srv) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          srv.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: navyDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${srv.visits} (${srv.percentage}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: srv.percentage / 100.0,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F6CBD)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Create / Export Report Button
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => const AdminCreateReportSheet(),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'تصدير تقرير إداري تحليلي (PDF / Excel)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2537),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Disclaimer Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: slateGray),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'البيانات الإحصائية أعلاه مجمعة من أنشطة الخدمات خلال الأسبوع الأخير لأغراض التحليل والمتابعة.',
                              style: TextStyle(
                                fontSize: 11,
                                color: slateGray,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'استخدام المنظومة',
            value: AdminDemoData.reportKpis['appUsage']['value'] as String,
            trend: AdminDemoData.reportKpis['appUsage']['trend'] as String,
            isPositive: true,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'متوسط الاستجابة',
            value: AdminDemoData.reportKpis['avgProcessTime']['value'] as String,
            trend: AdminDemoData.reportKpis['avgProcessTime']['trend'] as String,
            isPositive: true,
            icon: Icons.speed_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'رضا المستفيدين',
            value: AdminDemoData.reportKpis['userSatisfaction']['value'] as String,
            trend: AdminDemoData.reportKpis['userSatisfaction']['trend'] as String,
            isPositive: true,
            icon: Icons.star_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: const Color(0xFF0F6CBD)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2537),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11,
                color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 2),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
