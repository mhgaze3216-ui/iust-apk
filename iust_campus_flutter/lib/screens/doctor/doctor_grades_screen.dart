import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/doctor_repository.dart';
import '../../models/doctor_models.dart';
import 'doctor_academic_submission_screen.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorGradesScreen extends StatefulWidget {
  final String? initialCourseId;
  const DoctorGradesScreen({super.key, this.initialCourseId});

  @override
  State<DoctorGradesScreen> createState() => _DoctorGradesScreenState();
}

class _DoctorGradesScreenState extends State<DoctorGradesScreen> {
  late String _selectedCourseId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCourseId =
        widget.initialCourseId ??
        (DoctorRepository.courses.isNotEmpty
            ? DoctorRepository.courses.first.courseId
            : '');
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditGradeDialog(DoctorStudentGrade gradeItem) {
    final midtermCtrl = TextEditingController(
      text: '${gradeItem.midtermGrade}',
    );
    final courseworkCtrl = TextEditingController(
      text: '${gradeItem.courseworkGrade}',
    );
    final finalExamCtrl = TextEditingController(
      text: '${gradeItem.finalExamGrade}',
    );
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          int m = int.tryParse(midtermCtrl.text.trim()) ?? 0;
          int c = int.tryParse(courseworkCtrl.text.trim()) ?? 0;
          int f = int.tryParse(finalExamCtrl.text.trim()) ?? 0;
          int total = m + c + f;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'تعديل مفردات الدرجة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: _textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFAF1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'المجموع: $total/100',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E9B5F),
                      ),
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
                      gradeItem.studentName,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _blue,
                      ),
                    ),
                    Text(
                      gradeItem.studentId,
                      style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                    ),
                    const SizedBox(height: 14),
                    // Midterm
                    TextField(
                      controller: midtermCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'الامتحان النصفي (30%)',
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Coursework
                    TextField(
                      controller: courseworkCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'الأعمال والوظائف (20%)',
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Final exam
                    TextField(
                      controller: finalExamCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: 'الامتحان النهائي (50%)',
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(color: _textSub),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final mid = int.tryParse(midtermCtrl.text.trim());
                    final cw = int.tryParse(courseworkCtrl.text.trim());
                    final fin = int.tryParse(finalExamCtrl.text.trim());
                    if (mid == null ||
                        cw == null ||
                        fin == null ||
                        mid < 0 ||
                        mid > 30 ||
                        cw < 0 ||
                        cw > 20 ||
                        fin < 0 ||
                        fin > 50) {
                      setModalState(() {
                        errorText = 'تأكد من أن: النصفي ≤ 30، العملي ≤ 20، النهائي ≤ 50';
                      });
                      return;
                    }

                    final newTotal = mid + cw + fin;
                    try {
                      await DoctorRepository.updateGrade(
                        _selectedCourseId,
                        gradeItem.studentId,
                        newTotal,
                        midterm: mid,
                        coursework: cw,
                        finalExam: fin,
                      );
                    } catch (error) {
                      setModalState(
                        () => errorText = 'تعذر حفظ العلامة: $error',
                      );
                      return;
                    }

                    if (!mounted || !ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم تعديل علامة ${gradeItem.studentName} إلى $newTotal (نصفي: $mid، عملي: $cw، نهائي: $fin)',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: const Color(0xFF2E9B5F),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'حفظ التعديل',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      midtermCtrl.dispose();
      courseworkCtrl.dispose();
      finalExamCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allGrades = DoctorRepository.getGradesForCourse(_selectedCourseId);
    final filteredGrades = _searchQuery.isEmpty
        ? allGrades
        : allGrades
              .where(
                (g) =>
                    g.studentName.contains(_searchQuery) ||
                    g.studentId.contains(_searchQuery),
              )
              .toList();

    // Statistics calculations
    final gradesValues = allGrades.map((g) => g.numericGrade).toList();
    final count = gradesValues.length;
    final maxGrade = gradesValues.isNotEmpty
        ? gradesValues.reduce((curr, next) => curr > next ? curr : next)
        : 0;
    final minGrade = gradesValues.isNotEmpty
        ? gradesValues.reduce((curr, next) => curr < next ? curr : next)
        : 0;
    final avgGrade = count > 0
        ? (gradesValues.reduce((a, b) => a + b) / count).toStringAsFixed(1)
        : '0';
    final passCount = gradesValues.where((g) => g >= 60).length;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'سجل العلامات الأكاديمي',
          subtitle: 'مفردات الدرجة والاعتماد الإلكتروني',
          showBackButton: true,
          badgeText: 'بيانات تجريبية',
          badgeColor: Color(0xFF16A34A),
          badgeBgColor: Color(0xFFEDFAF1),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: _white,
            border: const Border(top: BorderSide(color: _border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const DoctorAcademicSubmissionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'اعتماد وإرسال للإدارة الرقمية',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Course selection tabs
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: _white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCourseTab(
                            id: 'doctor-course-001',
                            title: 'معالج دقيق',
                            section: 'الشعبة 1 (40 طالباً)',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCourseTab(
                            id: 'doctor-course-002',
                            title: 'الاحتمالات والإشارات',
                            section: 'الشعبة 2 (40 طالباً)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'بحث باسم الطالب أو المعرف الجامعي...',
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _textSub,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _lightBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistical summary banner (4 indicators)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildStatItem('الطلاب', '$count', _navy)),
                    Expanded(child: _buildStatItem('المتوسط', avgGrade, _blue)),
                    Expanded(
                      child: _buildStatItem(
                        'أعلى علامة',
                        '$maxGrade',
                        const Color(0xFF2E9B5F),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'أدنى علامة',
                        '$minGrade',
                        const Color(0xFFE67E22),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'الناجحون',
                        '$passCount (${(passCount / (count == 0 ? 1 : count) * 100).round()}%)',
                        const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),

              // Weights breakdown info bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                color: const Color(0xFFEFF6FF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'توزيع العلامة: نصفي (30%) · أعمال وفصل (20%) · نهائي (50%)',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D4ED8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF1D4ED8),
                    ),
                  ],
                ),
              ),

              // Students grades list
              Expanded(
                child: filteredGrades.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد نتائج مطابقة لبحثك',
                          style: GoogleFonts.cairo(
                            color: _textSub,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: filteredGrades.length,
                        itemBuilder: (context, index) {
                          final item = filteredGrades[index];
                          final isPass = item.numericGrade >= 60;
                          final isExcellence = item.numericGrade >= 90;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
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
                              children: [
                                Row(
                                  children: [
                                    // Serial index
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _textSub,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Student Name and ID
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.studentName,
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _textMain,
                                            ),
                                          ),
                                          Text(
                                            item.studentId,
                                            style: GoogleFonts.cairo(
                                              fontSize: 10.5,
                                              color: _textSub,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Numeric Total Grade Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isExcellence
                                            ? const Color(0xFFFFFBEB)
                                            : (isPass
                                                  ? const Color(0xFF2E9B5F)
                                                        .withValues(alpha: 0.12)
                                                  : const Color(
                                                      0xFFE53E3E,
                                                    ).withValues(alpha: 0.12)),
                                        border: Border.all(
                                          color: isExcellence
                                              ? const Color(0xFFFCD34D)
                                              : (isPass
                                                    ? const Color(0xFF86EFAC)
                                                    : const Color(0xFFFCA5A5)),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isExcellence) ...[
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFD97706),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            '${item.numericGrade} / 100',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isExcellence
                                                  ? const Color(0xFFB45309)
                                                  : (isPass
                                                        ? const Color(
                                                            0xFF2E9B5F,
                                                          )
                                                        : const Color(
                                                            0xFFE53E3E,
                                                          )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: _blue,
                                      ),
                                      onPressed: () =>
                                          _openEditGradeDialog(item),
                                      tooltip: 'تعديل الدرجة',
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Breakdown Chips (Midterm 30%, Coursework 20%, Final 50%)
                                Row(
                                  children: [
                                    _buildGradePill(
                                      'النصفي',
                                      '${item.midtermGrade}/30',
                                      _blue,
                                      const Color(0xFFEFF6FF),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildGradePill(
                                      'العملي/الأعمال',
                                      '${item.courseworkGrade}/20',
                                      const Color(0xFF8E44AD),
                                      const Color(0xFFF4ECF7),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildGradePill(
                                      'النهائي',
                                      '${item.finalExamGrade}/50',
                                      const Color(0xFF16A34A),
                                      const Color(0xFFDCFCE7),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: _textSub)),
      ],
    );
  }

  Widget _buildGradePill(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: _textSub,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseTab({
    required String id,
    required String title,
    required String section,
  }) {
    final isSelected =
        _selectedCourseId == id ||
        (_selectedCourseId == 'doc-course-microprocessor' &&
            id == 'doctor-course-001') ||
        (_selectedCourseId == 'doc-course-probabilities' &&
            id == 'doctor-course-002');

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCourseId = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _navy : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _navy : _border),
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textMain,
              ),
            ),
            Text(
              section,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: isSelected ? _gold : _textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
