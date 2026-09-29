import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/doctor_repository.dart';
import '../../models/doctor_models.dart';
import '../../theme/app_theme.dart';
import 'widgets/doctor_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorAttendanceScreen extends StatefulWidget {
  final String? initialCourseId;
  final bool showBack;
  const DoctorAttendanceScreen({
    super.key,
    this.initialCourseId,
    this.showBack = false,
  });

  @override
  State<DoctorAttendanceScreen> createState() => _DoctorAttendanceScreenState();
}

class _DoctorAttendanceScreenState extends State<DoctorAttendanceScreen> {
  late String _selectedCourseId;
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isViewingPastSession = false;

  final List<String> _filters = ['الكل', 'حاضر', 'متأخر', 'غائب'];

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

  Future<void> _markAllPresent() async {
    final roster = DoctorRepository.getRosterForCourse(_selectedCourseId);
    await Future.wait(
      roster.map(
        (student) => DoctorRepository.setStudentAttendance(
          _selectedCourseId,
          student.id,
          AttendanceStatus.present,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديد حضور ${roster.length} طالباً. احفظ لتثبيت البيانات.',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E9B5F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _resetSession() async {
    try {
      await DoctorRepository.clearAttendance(_selectedCourseId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر استعادة الحضور من الخادم: $error')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إعادة تحميل الحضور المحفوظ من الخادم',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveSession() async {
    try {
      await DoctorRepository.saveAttendance(_selectedCourseId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر حفظ الحضور: $error')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ واعتماد جلسة الحضور بنجاح',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  AttendanceStatus? _getStudentStatus(
    String studentId,
    Map<String, AttendanceStatus> liveMap,
  ) {
    return liveMap[studentId];
  }

  @override
  Widget build(BuildContext context) {
    final roster = DoctorRepository.getRosterForCourse(_selectedCourseId);
    final liveAttendanceMap = DoctorRepository.getAttendanceForCourse(
      _selectedCourseId,
    );

    // Counts
    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;

    for (final status in liveAttendanceMap.values) {
      if (status == AttendanceStatus.present) presentCount++;
      if (status == AttendanceStatus.late) lateCount++;
      if (status == AttendanceStatus.absent) absentCount++;
    }

    // Filter students
    final filteredRoster = roster.where((s) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          s.name.contains(_searchQuery) ||
          s.id.contains(_searchQuery);

      if (!matchesSearch) return false;

      final status = _getStudentStatus(s.id, liveAttendanceMap);
      if (_selectedFilter == 'حاضر') return status == AttendanceStatus.present;
      if (_selectedFilter == 'متأخر') return status == AttendanceStatus.late;
      if (_selectedFilter == 'غائب') return status == AttendanceStatus.absent;
      return true;
    }).toList();

    final scaffold = Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            DoctorHeader(showBackButton: widget.showBack),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 105),
                  children: [
                    _buildTopCard(
                      context,
                      presentCount,
                      lateCount,
                      absentCount,
                    ),
                    const SizedBox(height: 14),
                    _buildSessionToggle(),
                    const SizedBox(height: 14),
                    _buildCourseSelector(),
                    const SizedBox(height: 14),
                    _buildFiltersAndSearch(),
                    const SizedBox(height: 14),
                    if (!_isViewingPastSession) ...[
                      _buildActionButtons(),
                      const SizedBox(height: 14),
                    ],
                    _buildStudentsList(filteredRoster, liveAttendanceMap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.showBack) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) DoctorBackButton.safePop(context);
        },
        child: scaffold,
      );
    }
    return scaffold;
  }

  Widget _buildSessionToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isViewingPastSession = false;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isViewingPastSession ? _white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isViewingPastSession
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fiber_manual_record_rounded,
                        size: 9,
                        color: !_isViewingPastSession
                            ? const Color(0xFF2E9B5F)
                            : _textSub,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'جلسة اليوم (مباشر)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: !_isViewingPastSession
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: !_isViewingPastSession ? _navy : _textSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isViewingPastSession = true;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isViewingPastSession ? _white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isViewingPastSession
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 13,
                        color: _isViewingPastSession ? _blue : _textSub,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'الجلسة السابقة (29-08)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: _isViewingPastSession
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _isViewingPastSession ? _navy : _textSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(
    BuildContext context,
    int presentCount,
    int lateCount,
    int absentCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.how_to_reg_outlined,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'تسجيل الحضور والغياب',
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFAF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'بيانات تجريبية',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E9B5F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isViewingPastSession
                          ? 'جلسة معتمدة سابقة بتاريخ السبت 2026-08-29'
                          : 'جلسة رصد تفاعلية حية لقائمة الطلاب (40 طالباً)',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'حاضر',
                  '$presentCount',
                  const Color(0xFF2E9B5F),
                  const Color(0xFFEDFAF1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'متأخر',
                  '$lateCount',
                  const Color(0xFFE67E22),
                  const Color(0xFFFDF2E9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'غائب',
                  '$absentCount',
                  const Color(0xFFE74C3C),
                  const Color(0xFFFDEDEC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCourseTabButton(
              id: 'doctor-course-001',
              title: 'معالج دقيق',
              section: 'الشعبة 1',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildCourseTabButton(
              id: 'doctor-course-002',
              title: 'الاحتمالات والإشارات',
              section: 'الشعبة 2',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTabButton({
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
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? _navy : _textSub,
              ),
            ),
            Text(
              section,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: isSelected ? _blue : _textSub,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Column(
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.cairo(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'بحث باسم الطالب أو المعرف...',
              hintStyle: GoogleFonts.cairo(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _markAllPresent,
            icon: const Icon(
              Icons.done_all_rounded,
              size: 16,
              color: Color(0xFF2E9B5F),
            ),
            label: Text(
              'حضور الكل',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E9B5F),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E9B5F)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: const Color(0xFFEDFAF1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetSession,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: _textSub),
            label: Text(
              'إعادة تعيين',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _textSub,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _border),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: _white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveSession,
            icon: const Icon(Icons.save_outlined, size: 16, color: _white),
            label: Text(
              'حفظ الجلسة',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList(
    List<({String id, String name})> students,
    Map<String, AttendanceStatus> liveAttendanceMap,
  ) {
    if (students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Center(
          child: Text(
            'لا توجد نتائج مطابقة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textSub,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final status = _getStudentStatus(student.id, liveAttendanceMap);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _white,
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _navy.withValues(alpha: 0.08),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                    Text(
                      student.id,
                      style: GoogleFonts.cairo(fontSize: 10.5, color: _textSub),
                    ),
                  ],
                ),
              ),
              // If past session, show fixed badge, otherwise show interactive status buttons
              if (_isViewingPastSession) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == AttendanceStatus.present
                        ? const Color(0xFFEDFAF1)
                        : (status == AttendanceStatus.late
                              ? const Color(0xFFFDF2E9)
                              : const Color(0xFFFDEDEC)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status == AttendanceStatus.present
                          ? const Color(0xFF86EFAC)
                          : (status == AttendanceStatus.late
                                ? const Color(0xFFFDBA74)
                                : const Color(0xFFFCA5A5)),
                    ),
                  ),
                  child: Text(
                    status == AttendanceStatus.present
                        ? 'حاضر (معتمد)'
                        : (status == AttendanceStatus.late
                              ? 'متأخر (معتمد)'
                              : 'غائب (معتمد)'),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: status == AttendanceStatus.present
                          ? const Color(0xFF2E9B5F)
                          : (status == AttendanceStatus.late
                                ? const Color(0xFFE67E22)
                                : const Color(0xFFE74C3C)),
                    ),
                  ),
                ),
              ] else ...[
                // Attendance Status Toggles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusButton(
                      student.id,
                      AttendanceStatus.present,
                      'حاضر',
                      status == AttendanceStatus.present,
                      const Color(0xFF2E9B5F),
                    ),
                    const SizedBox(width: 4),
                    _buildStatusButton(
                      student.id,
                      AttendanceStatus.late,
                      'متأخر',
                      status == AttendanceStatus.late,
                      const Color(0xFFE67E22),
                    ),
                    const SizedBox(width: 4),
                    _buildStatusButton(
                      student.id,
                      AttendanceStatus.absent,
                      'غائب',
                      status == AttendanceStatus.absent,
                      const Color(0xFFE74C3C),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(
    String studentId,
    AttendanceStatus targetStatus,
    String label,
    bool isSelected,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          DoctorRepository.setStudentAttendance(
            _selectedCourseId,
            studentId,
            targetStatus,
          );
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? _white : color,
          ),
        ),
      ),
    );
  }
}
