import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorHelpScreen extends StatefulWidget {
  const DoctorHelpScreen({super.key});

  @override
  State<DoctorHelpScreen> createState() => _DoctorHelpScreenState();
}

class _DoctorHelpScreenState extends State<DoctorHelpScreen> {
  final List<(String, String)> _faqs = [
    (
      'كيف يتم رفع نتائج الامتحان النهائي إلكترونياً؟',
      'يمكنك الدخول إلى قسم "رفع النتائج للإدارة" واختيار المقرر ثم الضغط على "رفع جديد" لتأكيد علامات السعي والامتحان النهائي رقمياً بدون الحاجة لأوراق مطبوعة.',
    ),
    (
      'ما هي المهلة المحددة لتسجيل حضور وغياب المحاضرة؟',
      'يُفضل تسجيل الحضور أثناء المحاضرة أو خلال 24 ساعة من انتهائها عبر شاشة "تسجيل الحضور" لضمان تحديث سجلات الطلاب ونسب الحرمان بدقة.',
    ),
    (
      'كيف أضيف إعلاناً أو واجباً لشعبة محددة؟',
      'من خلال "إعلانات المقرر" أو "التكليفات"، اضغط على إضافة جديد وحدد المقرر والشعبة المستهدفة، وسيصل تنبيه فوري لجميع طلاب الشعبة.',
    ),
    (
      'أين أجد نماذج الامتحانات النصفية والنهائية؟',
      'في "مركز الامتحانات"، تتوفر نماذج معتمدة للامتحان النصفي والنهائي وفق المعايير الأكاديمية لجامعة القلمون/IUST ويمكن معاينتها وتعديلها.',
    ),
    (
      'كيف يتم الرد على استفسارات الطلاب الأكاديمية؟',
      'من خلال شاشة "أسئلة الطلاب"، يمكنك استعراض كافة أسئلة الطلاب غير المجاب عنها وكتابة الرد الأكاديمي المباشر أو تعديل إجابة سابقة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'المساعدة والدعم الأكاديمي',
          subtitle: 'الدليل الإرشادي والتواصل مع الدعم الفني',
          showBackButton: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Contact Admin Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFAF1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Color(0xFF2E9B5F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شؤون الأساتذة والعمادة',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _textMain,
                                ),
                              ),
                              Text(
                                'كلية الهندسة المعلوماتية والاتصالات',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  color: _textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: _border),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'البريد الأكاديمي:',
                          style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'academic@iust.edu.sy',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المكتب الإداري:',
                          style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'مبنى الهندسة - الطابق الرابع (4202)',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // FAQs Section
              Text(
                'الأسئلة الشائعة للأساتذة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 10),
              ..._faqs.map((faq) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: _white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: _border),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                        iconColor: _navy,
                        collapsedIconColor: _textSub,
                        title: Text(
                          faq.$1,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textMain,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Text(
                              faq.$2,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: const Color(0xFF334155),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // Report an issue button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم تسجيل بلاغك وسيقوم الدعم الفني بمتابعة الطلب.',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: _navy,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.bug_report_outlined, size: 18, color: Color(0xFFE53E3E)),
                  label: Text(
                    'الإبلاغ عن مشكلة فنية في المنصة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE53E3E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: const Color(0xFFE53E3E).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
