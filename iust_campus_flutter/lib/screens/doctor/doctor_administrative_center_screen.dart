import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_academic_submission_screen.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorAdministrativeCenterScreen extends StatelessWidget {
  const DoctorAdministrativeCenterScreen({super.key});

  void _showDetailModal(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textMain,
                          ),
                        ),
                        Text(
                          subtitle,
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
              const SizedBox(height: 16),
              content,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          centerTitle: true,
          leading: const DoctorBackButton(),
        title: Text(
          'المعاملات الأكاديمية',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textMain,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'بيانات تجريبية',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB78103),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 18),
            Text(
              'المعاملات والإجراءات الرسمية',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              context,
              title: 'رفع النتائج للإدارة',
              subtitle: 'المعاملات الرقمية لإرسال وتدقيق العلامات إلكترونياً',
              icon: Icons.cloud_upload_outlined,
              iconColor: _blue,
              iconBg: const Color(0xFFEAF4FB),
              badge: '3 معاملات',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorAcademicSubmissionScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              title: 'قوائم الحرمان',
              subtitle: 'معالجة الطلاب المتجاوزين لنسب الغياب المقررة قانونياً',
              icon: Icons.person_off_outlined,
              iconColor: const Color(0xFFE74C3C),
              iconBg: const Color(0xFFFDEDEC),
              badge: 'طالبان (مسودة)',
              onTap: () => _showDeprivationListModal(context),
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              title: 'الاعتراضات',
              subtitle: 'متابعة طلبات إعادة تصحيح وتدقيق علامات الطلاب',
              icon: Icons.rule_folder_outlined,
              iconColor: const Color(0xFFE67E22),
              iconBg: const Color(0xFFFDF2E9),
              badge: 'طلب واحد قيد المراجعة',
              onTap: () => _showObjectionsModal(context),
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              title: 'غير المكتمل',
              subtitle: 'طلبات تأجيل الامتحانات بعذر طبي أو رسمي معتمد',
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xFF8E44AD),
              iconBg: const Color(0xFFF4ECF7),
              badge: 'طلب معتمد',
              onTap: () => _showIncompleteModal(context),
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              title: 'محاضر النتائج',
              subtitle: 'محاضر الاعتماد النهائي الموقعة من رئيس القسم والعمادة',
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF2E9B5F),
              iconBg: const Color(0xFFEDFAF1),
              badge: 'محضر جاهز',
              onTap: () => _showMinutesModal(context),
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              title: 'أرشيف الإرساليات',
              subtitle: 'استعراض السجلات الأكاديمية والنتائج المرفوعة سابقاً',
              icon: Icons.history_rounded,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              badge: '3 إرساليات',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorAcademicSubmissionScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _showDeprivationListModal(BuildContext context) {
    _showDetailModal(
      context,
      title: 'قوائم الحرمان الأكاديمي',
      subtitle: 'حرمان الطلاب المتجاوزين لنسبة الغياب المسموحة (15%)',
      icon: Icons.person_off_outlined,
      iconColor: const Color(0xFFE74C3C),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDEC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF5C6CB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE74C3C), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المقرر: معالج دقيق — الشعبة 1 · عدد الطلاب المحرومين: 2',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF721C24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildStudentRow('1', 'طالب تجريبي A', 'نسبة الغياب: 22%', 'مسودة'),
          const SizedBox(height: 8),
          _buildStudentRow('2', 'طالب تجريبي B', 'نسبة الغياب: 18%', 'مسودة'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال قائمة الحرمان لعمادة الكلية للمراجعة والاعتماد',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: _navy,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('اعتماد وإرسال القائمة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showObjectionsModal(BuildContext context) {
    _showDetailModal(
      context,
      title: 'طلبات الاعتراضات الأكاديمية',
      subtitle: 'مراجعة جمع درجات ورقة الطالب الرسمية',
      icon: Icons.rule_folder_outlined,
      iconColor: const Color(0xFFE67E22),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFAD7A0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الاحتمالات والإشارات العشوائية',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'قيد المراجعة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE67E22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الطالب: طالب تجريبي · العلامة المرصودة سابقاً: 72 / 100',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الطلب: مراجعة جمع درجات السؤال الثالث من الامتحان النصفي.',
                  style: GoogleFonts.cairo(fontSize: 11.5, color: _navy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تثبيت العلامة السابقة (72) دون تعديل',
                            style: GoogleFonts.cairo()),
                        backgroundColor: _navy,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('رفض التعديل وتثبيت العلامة',
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: _textSub)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم قبول التعديل ورفع العلامة المعدلة للإدارة',
                            style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFF2E9B5F),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9B5F),
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('قبول وتعديل العلامة',
                      style: GoogleFonts.cairo(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIncompleteModal(BuildContext context) {
    _showDetailModal(
      context,
      title: 'امتحانات غير المكتمل (Incomplete)',
      subtitle: 'الطلاب المؤجل امتحاناتهم بأعذار رسمية معتمدة',
      icon: Icons.pending_actions_rounded,
      iconColor: const Color(0xFF8E44AD),
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4ECF7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8DAEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معالج دقيق — الشعبة 1',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'الطالب: طالب تجريبي C · رقم القرار: MED-2026-90',
              style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
            ),
            const SizedBox(height: 4),
            Text(
              'تأجيل جلسة الامتحان النهائي للدورة الاستثنائية بتقرير طبي معتمد.',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E44AD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMinutesModal(BuildContext context) {
    _showDetailModal(
      context,
      title: 'محاضر اعتماد النتائج',
      subtitle: 'محاضر جلسات تدقيق الدرجات والامتحانات',
      icon: Icons.verified_outlined,
      iconColor: const Color(0xFF2E9B5F),
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDFAF1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD5F5E3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'محضر نتائج الامتحان النصفي للفصل الصيفي 2025/2026',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'المقرر: معالج دقيق (DEMO-421) — الشعبة 1 (40 طالباً)',
              style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
            ),
            const SizedBox(height: 6),
            Text(
              'الحالة: جاهز للأرشفة بعد التوقيع الإلكتروني وتثبيت الدرجات بنجاح.',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E9B5F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStudentRow(
    String index,
    String name,
    String reason,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _navy.withValues(alpha: 0.08),
                child: Text(index,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _navy)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  Text(reason,
                      style:
                          GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status,
                style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE67E22))),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_outlined,
                color: _navy, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز المعاملات الأكاديمية',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                Text(
                  'متابعة الإرساليات والاعتراضات وقوائم الحرمان إلكترونياً',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: iconColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: _textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: _textSub),
            ],
          ),
        ),
      ),
    );
  }
}
