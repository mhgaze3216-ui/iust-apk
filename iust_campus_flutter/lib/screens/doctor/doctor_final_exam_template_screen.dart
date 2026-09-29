import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorFinalExamTemplateScreen extends StatelessWidget {
  const DoctorFinalExamTemplateScreen({super.key});

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
          title: 'نموذج الامتحان النهائي',
          subtitle: 'معاينة ورقة أسئلة الامتحان النهائي وسلالم التصحيح',
          showBackButton: true,
        ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            // PDF Document Sheet
            Container(
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الجامعة الدولية الخاصة للعلوم والتكنولوجيا',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _navy,
                              ),
                            ),
                            Text(
                              'كلية الهندسة المعلوماتية والاتصالات',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _textSub,
                              ),
                            ),
                            Text(
                              'الامتحان النهائي · الفصل الصيفي 2025/2026',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/img/logo iust.webp',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, e, s) => const Icon(
                            Icons.school_rounded,
                            size: 36,
                            color: _navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(thickness: 1.5, color: _navy),
                  const SizedBox(height: 12),

                  // Metadata Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetaRow('المقرر',
                                  'الاحتمالات والإشارات العشوائية (DEMO-422)'),
                            ),
                            Expanded(
                              child: _buildMetaRow('الشعبة', '2'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetaRow(
                                  'الدكتور', 'د. محمد مازن محايري'),
                            ),
                            Expanded(
                              child: _buildMetaRow('المدة', '120 دقيقة'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetaRow('العلامة', '100 درجة'),
                            ),
                            Expanded(
                              child: _buildMetaRow('القاعة', '4212'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Instructions Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: Color(0xFFB78103)),
                            const SizedBox(width: 6),
                            Text(
                              'تعليمات عامة للطلاب:',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7A5200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• أجب عن جميع الأسئلة.\n• اكتب خطوات الحل بوضوح.\n• يمنع استخدام الهاتف المحمول.\n• تحقق من عدد أوراق الامتحان قبل البدء.',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF2C2500),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Questions Structure
                  _buildQuestionItem(
                    title: 'السؤال الأول — 20 علامة',
                    subtitle: 'أسئلة اختيار من متعدد',
                    content:
                        'أجب عن الأسئلة التالية المتعلقة بدوال الكثافة الاحتمالية، دوال التوزيع التراكمي، ومتغيرات بواسون وغاوص المستمرة.',
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionItem(
                    title: 'السؤال الثاني — 25 علامة',
                    subtitle: 'مسائل تطبيقية',
                    content:
                        'ليكن X متغيراً عشوائياً مستمراً تابعاً للتوزيع الطبيعي المعياري N(0, 1). احسب الاحتمالات المطلوبة ومصفوفة التغاير المشترك للإشارات.',
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionItem(
                    title: 'السؤال الثالث — 25 علامة',
                    subtitle: 'تحليل وشرح',
                    content:
                        'اشرح مفهوم الاستقرار بالمعنى الواسع (WSS) للعمليات العشوائية، وبيّن شروط مصفوفة الترابط الذاتي ودوال كثافة القدرة الطيفية.',
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionItem(
                    title: 'السؤال الرابع — 30 علامة',
                    subtitle: 'مسألة شاملة',
                    content:
                        'نظام اتصالات يمرر إشارة عشوائية عبر مرشح خطي ثابت مع الزمن LTI. أوجد استجابة النظام، تابع التباين عند الخرج، ونسبة الإشارة إلى الضجيج SNR.',
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'مع تمنياتنا بالتوفيق والنجاح',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تفعيل وضع المعاينة للنموذج النهائي',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: _navy,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.preview_rounded, size: 18),
                    label: Text('معاينة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _navy),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم فتح النموذج النهائي للتحرير والتعديل',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: _blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: Text('تعديل النموذج',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم نسخ نموذج الامتحان النهائي بنجاح',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: const Color(0xFF2E9B5F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text('نسخ النموذج',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E9B5F)),
                      foregroundColor: const Color(0xFF2E9B5F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10.5, color: _textSub),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: _textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem({
    required String title,
    required String subtitle,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: _textMain,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
