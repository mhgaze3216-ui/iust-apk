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

class DoctorExamInstructionsScreen extends StatelessWidget {
  const DoctorExamInstructionsScreen({super.key});

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
          title: 'تعليمات الامتحانات',
          subtitle: 'الضوابط الأكاديمية قبل وأثناء وبعد الامتحان والاعتراضات',
          showBackButton: true,
        ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 16),
            _buildInstructionCard(
              title: 'قبل الامتحان',
              icon: Icons.assignment_outlined,
              iconColor: _blue,
              points: const [
                'التأكد من اعتماد نموذج الأسئلة النهائي لدى عمادة الكلية ورئاسة القسم.',
                'التأكد من وضوح توزيع العلامات وتدوين سلم التصحيح بشكل دقيق.',
                'إرسال النسخة المطلوبة ضمن الموعد المحدد قبل بدء الدورة الامتحانية.',
                'مراجعة أسماء المقررات والشعب والقاعات المخصصة لكل جلسة.',
                'التأكد من مدة الامتحان وتجهيز الأوراق الامتحانية المطبوعة بعدد الطلاب.',
              ],
            ),
            const SizedBox(height: 14),
            _buildInstructionCard(
              title: 'أثناء الامتحان',
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFF2E9B5F),
              points: const [
                'الحضور إلى القاعة الامتحانية قبل بدء الامتحان بـ 20 دقيقة على الأقل.',
                'التأكد من هوية الطالب وبطاقته الجامعية ومطابقتها مع قائمة الحضور.',
                'توضيح التعليمات العامة للطلاب دون شرح الإجابات أو تقديم تلميحات.',
                'تسجيل أي حالة طارئة أو مخالفة في محضر الضبط الرسمي.',
                'عدم السماح باستخدام الهاتف المحمول إلا وفق تعليمات وضوابط الجامعة.',
              ],
            ),
            const SizedBox(height: 14),
            _buildInstructionCard(
              title: 'بعد الامتحان',
              icon: Icons.fact_check_outlined,
              iconColor: const Color(0xFF8E44AD),
              points: const [
                'استلام جميع أوراق الإجابة والتأكد من توقيع كل طالب على كشف الحضور.',
                'مطابقة عدد الأوراق المسلمة مع عدد الطلاب الحاضرين بدقة تامة.',
                'تصحيح الأوراق ضمن الفترة الزمنية المحددة بالتقويم الأكاديمي.',
                'تدقيق العلامات والجمع الحسابي قبل الاعتماد النهائي.',
                'رفع النتائج إلكترونياً إلى الإدارة عبر لوحة النتائج الرقمية.',
                'الاحتفاظ بنسخة من كشف العلامات المعتمد للأرشيف الأكاديمي.',
              ],
            ),
            const SizedBox(height: 14),
            _buildInstructionCard(
              title: 'الاعتراضات',
              icon: Icons.rate_review_outlined,
              iconColor: const Color(0xFFE67E22),
              points: const [
                'مراجعة ورقة الطالب عند وجود طلب اعتراضي رسمي محال من إدارة الكلية.',
                'توثيق أي تعديل على العلامة في نموذج محضر الاعتراض الأكاديمي.',
                'إرسال نتيجة دراسة الاعتراض إلى الإدارة إلكترونياً لاعتمادها.',
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rule_folder_rounded,
                color: _navy, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دليل الإرشادات والتعليمات الامتحانية',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                Text(
                  'الضوابط الأكاديمية لإدارة وضبط الامتحانات وتدقيق النتائج',
                  style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...points.map((pt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pt,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textMain,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
