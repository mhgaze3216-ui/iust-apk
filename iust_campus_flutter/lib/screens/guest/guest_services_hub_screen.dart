import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../guest_inquiry_screen.dart';
import 'guest_help_and_contact_screen.dart';
import 'widgets/guest_header.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class _ServiceHubItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;
  final String? route;
  final VoidCallback? customTap;

  const _ServiceHubItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
    this.route,
    this.customTap,
  });
}

class GuestServicesHubScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const GuestServicesHubScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final List<_ServiceHubItem> items = [
      _ServiceHubItem(
        icon: Icons.card_membership_rounded,
        iconColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        title: 'المنح والتخفيضات',
        description: 'شروط ونسب منح التفوق والتخفيضات للأخوة وأبناء الشهداء.',
        route: '/info/scholarships',
      ),
      _ServiceHubItem(
        icon: Icons.description_rounded,
        iconColor: const Color(0xFF16A34A),
        bgColor: const Color(0xFFDCFCE7),
        title: 'الوثائق والمستندات',
        description: 'الأوراق المطلوبة للتسجيل الجديد والتحويل ومعادلة الساعات.',
        route: '/info/documents',
      ),
      _ServiceHubItem(
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF0284C7),
        bgColor: const Color(0xFFE0F2FE),
        title: 'الرسوم والإجراءات المالية',
        description: 'دليل الرسوم الدراسية وحسابات البنوك وإجراءات الانسحاب.',
        route: '/info/financial',
      ),
      _ServiceHubItem(
        icon: Icons.contact_support_rounded,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF3E8FF),
        title: 'الأسئلة والتواصل',
        description: 'إجابات الأسئلة المتكررة والتواصل المباشر مع إدارة الجامعة.',
        customTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuestHelpAndContactScreen()),
          );
        },
      ),
      _ServiceHubItem(
        icon: Icons.directions_bus_rounded,
        iconColor: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFEDD5),
        title: 'النقل والمواصلات',
        description: 'شبكة حافلات الجامعة ومسارات دمشق ودرعا والسويداء.',
        customTap: () {
          _showTransportDialog(context);
        },
      ),
      _ServiceHubItem(
        icon: Icons.send_rounded,
        iconColor: _navy,
        bgColor: _lightBlue,
        title: 'تقديم استفسار للإدارة',
        description: 'إرسال طلب أو استفسار مباشر والحصول على رقم مرجعي محلي.',
        customTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuestInquiryScreen()),
          );
        },
      ),
      _ServiceHubItem(
        icon: Icons.map_rounded,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
        title: 'الخريطة التفاعلية',
        description: 'تحديد مواقع المباني والمخابر والمدرجات داخل الحرم الجامعي.',
        customTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(2); // Jump to map tab
          } else {
            Navigator.pushNamed(context, '/map');
          }
        },
      ),
      _ServiceHubItem(
        icon: Icons.info_outline_rounded,
        iconColor: _blue,
        bgColor: _lightBlue,
        title: 'عن الجامعة ونظام الدراسة',
        description: 'الرؤية والرسالة ونظام الساعات المعتمدة والاعتماد الأكاديمي.',
        customTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(4); // Jump to university info tab
          } else {
            Navigator.pushNamed(context, '/info/university');
          }
        },
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const GuestHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_navy, _blue],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'دليل خدمات الزوار',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'جميع الخدمات والمعلومات والإجراءات التي تهم الطلاب المستجدين والزوار في مكان واحد.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section Title
              Text(
                'الخدمات والمعاملات المتاحة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 12),

              // 2-column Grid of Service Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return _buildServiceCard(context, item);
                },
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

  Widget _buildServiceCard(BuildContext context, _ServiceHubItem item) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.customTap != null) {
              item.customTap!();
            } else if (item.route != null) {
              Navigator.of(context).pushNamed(item.route!);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    item.description,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: _textSub,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.directions_bus_rounded, color: _navy, size: 24),
              const SizedBox(width: 8),
              Text(
                'النقل الجامعي',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توفر الجامعة حافلات نقل مريحة ومكيفة تنطلق يومياً من المحطات التالية:',
                  style: GoogleFonts.cairo(fontSize: 12.5, color: _textMain, height: 1.45),
                ),
                const SizedBox(height: 10),
                _bulletItem('دمشق: البرامكة، المزة، أوتوستراد المزة، كفرسوسة، الميدان'),
                _bulletItem('ريف دمشق: السيدة زينب، صحنايا، الكسوة، جرمانا'),
                _bulletItem('محافظة درعا: درعا المحطة، الصنمين، إزرع، الشيخ مسكين'),
                _bulletItem('محافظة السويداء: مركز الانطلاق الغربي، المزرعة'),
                _bulletItem('محافظة القنيطرة: خان أرنبة، البعث'),
                const SizedBox(height: 10),
                Text(
                  'للاشتراك أو الاستفسار عن المواعيد والتعرفة يرجى مراجعة مكتب النقل في الإدارة العامة.',
                  style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(fontSize: 12, color: _textMain),
            ),
          ),
        ],
      ),
    );
  }
}
