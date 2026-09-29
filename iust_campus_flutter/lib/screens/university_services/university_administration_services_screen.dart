import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/university_services_header.dart';
import 'subpages/university_appointments_screen.dart';
import 'subpages/new_inquiry_screen.dart';
import 'subpages/university_faq_screen.dart';
import 'subpages/university_departments_screen.dart';
import 'transactions_guide_screen.dart';
import 'university_news_screen.dart';
import 'university_requests_screen.dart';
import 'subpages/administrative_student_schedule_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityAdministrationServicesScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const UniversityAdministrationServicesScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              UniversityServicesHeader(
                title: 'الإدارة الجامعية',
                showBackButton: Navigator.canPop(context),
                onBack: () => Navigator.maybePop(context),
              ),

              // Main Scrollable Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  children: [
                    // 1. Top Hero Card: إدارة الجامعة
                    _buildHeroCard(context),
                    const SizedBox(height: 16),

                    // 2. Home Summary Cards (طلبات جديدة / مواعيد اليوم)
                    _buildSummaryCards(context),
                    const SizedBox(height: 20),

                    // 3. Section Title: الخدمات الرئيسية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الخدمات الإدارية الرئيسية',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _navy,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UniversityDepartmentsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'دليل الإدارات',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 4. Main 2-Column Services Grid (6 services)
                    _buildServicesGrid(context),
                    const SizedBox(height: 20),

                    // 5. University Departments Hub Banner
                    _buildDepartmentsBanner(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus image header
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/img/iust.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _navy,
                    child: const Center(
                      child: Icon(Icons.apartment_rounded, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _navy.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5B82E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.corporate_fare_rounded, size: 18, color: _navy),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إدارة الجامعة',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content and CTA
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعرف على الجهات الإدارية وخدماتها وآليات التواصل معها في مكان واحد.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: _textMain,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UniversityDepartmentsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'عرض الخدمات والجهات',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        // 1. طلبات جديدة
        Expanded(
          child: InkWell(
            onTap: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(1); // Go to Requests tab
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UniversityRequestsScreen()),
                );
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: _blue, size: 18),
                      ),
                      Text(
                        '12',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'طلبات جديدة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  Text(
                    'تحتاج إلى متابعة',
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. مواعيد اليوم
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UniversityAppointmentsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFAF1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF16A34A), size: 18),
                      ),
                      Text(
                        '8',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'مواعيد اليوم',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  Text(
                    'موعد قادم اليوم',
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      (
        title: 'الطلبات الإدارية',
        subtitle: 'قدم وتابع طلباتك الإدارية بسهولة',
        icon: Icons.assignment_rounded,
        iconBg: const Color(0xFFEAF4FB),
        iconColor: _blue,
        onTap: () {
          if (onNavigateToTab != null) {
            onNavigateToTab!(1);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UniversityRequestsScreen()),
            );
          }
        },
      ),
      (
        title: 'حجز المواعيد',
        subtitle: 'احجز موعداً مع الجهة المختصة',
        icon: Icons.event_available_rounded,
        iconBg: const Color(0xFFEDFAF1),
        iconColor: const Color(0xFF16A34A),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UniversityAppointmentsScreen()),
          );
        },
      ),
      (
        title: 'دليل المعاملات',
        subtitle: 'تعرف على الإجراءات والمتطلبات بالتفصيل',
        icon: Icons.description_rounded,
        iconBg: const Color(0xFFFFF4D6),
        iconColor: const Color(0xFFD97706),
        onTap: () {
          if (onNavigateToTab != null) {
            onNavigateToTab!(2);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsGuideScreen()),
            );
          }
        },
      ),
      (
        title: 'الأخبار',
        subtitle: 'تابع آخر أخبار الجامعة والإعلانات المهمة',
        icon: Icons.newspaper_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {
          if (onNavigateToTab != null) {
            onNavigateToTab!(3);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UniversityNewsScreen()),
            );
          }
        },
      ),
      (
        title: 'استفسار جديد',
        subtitle: 'أرسل استفسارك إلى الإدارة المختصة',
        icon: Icons.outgoing_mail,
        iconBg: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFDC2626),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewInquiryScreen()),
          );
        },
      ),
      (
        title: 'الأسئلة الشائعة',
        subtitle: 'إجابات سريعة لأكثر الاستفسارات شيوعاً',
        icon: Icons.help_center_rounded,
        iconBg: const Color(0xFFEAF4FB),
        iconColor: _navy,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UniversityFaqScreen()),
          );
        },
      ),
      (
        title: 'إدارة جداول الطلاب',
        subtitle: 'تعديل الشعب والمواعيد والقاعات',
        icon: Icons.calendar_month_rounded,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdministrativeStudentScheduleScreen(),
            ),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.28,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final srv = services[index];

        return InkWell(
          onTap: srv.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: srv.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(srv.icon, color: srv.iconColor, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      srv.title,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      srv.subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        color: _textSub,
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
      },
    );
  }

  Widget _buildDepartmentsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBCE0F7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.domain_rounded, color: _navy, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10 إدارات وجهات جامعية',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                  ),
                ),
                Text(
                  'شؤون الطلاب، القبول والتسجيل، المالية، الامتحانات وغيرها...',
                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UniversityDepartmentsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              'استعراض',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
