import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/student_repository.dart';
import '../../../models/student_models.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

/// Screen for Administrative Staff (Admissions & Registration) to manage student schedules.
/// Allows selecting a student, viewing their registered courses and schedule sessions,
/// adding, editing, and deleting schedule sessions with confirmation.
class AdministrativeStudentScheduleScreen extends StatefulWidget {
  final String? initialStudentId;

  const AdministrativeStudentScheduleScreen({super.key, this.initialStudentId});

  @override
  State<AdministrativeStudentScheduleScreen> createState() =>
      _AdministrativeStudentScheduleScreenState();
}

class _AdministrativeStudentScheduleScreenState
    extends State<AdministrativeStudentScheduleScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late String _selectedStudentId;
  late Future<void> _loadFuture;
  String _searchFilter = '';

  final List<String> _daysOfWeekAr = const [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStudentId = '';
    _loadFuture = _loadStudents();

    _searchCtrl.addListener(() {
      setState(() {
        _searchFilter = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadStudents() async {
    await StudentRepository.initializeAdminStudents();
    final all = StudentRepository.allStudents;
    _selectedStudentId =
        widget.initialStudentId != null &&
            StudentRepository.hasStudent(widget.initialStudentId!)
        ? widget.initialStudentId!
        : all.isNotEmpty
        ? all.first.studentId
        : '';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  StudentProfile? get _currentStudent =>
      StudentRepository.getStudent(_selectedStudentId);

  List<StudentProfile> get _filteredStudents {
    final all = StudentRepository.allStudents;
    if (_searchFilter.isEmpty) return all;
    return all.where((s) {
      return s.fullName.toLowerCase().contains(_searchFilter) ||
          s.universityId.toLowerCase().contains(_searchFilter) ||
          s.facultyNameAr.toLowerCase().contains(_searchFilter);
    }).toList();
  }

  void _openAddOrEditSessionModal([ScheduleSession? existingSession]) {
    final isEditing = existingSession != null;
    final student = _currentStudent;
    if (student == null) return;

    final availableCourses = StudentRepository.getAvailableCourseTuples(
      _selectedStudentId,
    );

    String selectedCourseName = isEditing
        ? existingSession.courseId
        : (availableCourses.isNotEmpty ? availableCourses.first.name : '');
    if (isEditing) {
      final match = availableCourses.firstWhere(
        (c) => c.id == existingSession.courseId,
        orElse: () =>
            (id: existingSession.courseId, name: existingSession.courseId),
      );
      selectedCourseName = match.name;
    }

    final sectionCtrl = TextEditingController(
      text: isEditing ? existingSession.sectionId : 'الشعبة 1',
    );
    String selectedDay = isEditing
        ? (_daysOfWeekAr.contains(existingSession.dayOfWeekAr)
              ? existingSession.dayOfWeekAr
              : _daysOfWeekAr.first)
        : _daysOfWeekAr.first;

    final startCtrl = TextEditingController(
      text: isEditing ? existingSession.startTime : '08:30',
    );
    final endCtrl = TextEditingController(
      text: isEditing ? existingSession.endTime : '10:00',
    );
    final roomCtrl = TextEditingController(
      text: isEditing ? existingSession.roomDisplay : 'قاعة 101',
    );
    final buildingCtrl = TextEditingController(
      text: isEditing
          ? (existingSession.buildingNameAr ?? 'المبنى الرئيسي')
          : 'المبنى الرئيسي',
    );
    String selectedType = isEditing ? existingSession.activityTypeAr : 'نظري';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        isEditing
                            ? 'تعديل جلسة في الجدول'
                            : 'إضافة جلسة جديدة إلى الجدول',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. المقرر
                      Text(
                        'المقرر الدراسي',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (availableCourses.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: _border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedCourseName,
                              items: availableCourses.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.name,
                                  child: Text(
                                    c.name,
                                    style: GoogleFonts.cairo(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedCourseName = val);
                                }
                              },
                            ),
                          ),
                        )
                      else
                        TextFormField(
                          initialValue: selectedCourseName,
                          decoration: InputDecoration(
                            hintText: 'اسم المقرر',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (v) => selectedCourseName = v,
                        ),
                      const SizedBox(height: 12),

                      // 2. الشعبة ونوع الجلسة
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الشعبة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: sectionCtrl,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نوع الجلسة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _border),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedType,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'نظري',
                                          child: Text('نظري'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'عملي',
                                          child: Text('عملي'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(
                                            () => selectedType = val,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. اليوم
                      Text(
                        'اليوم',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedDay,
                            items: _daysOfWeekAr.map((d) {
                              return DropdownMenuItem<String>(
                                value: d,
                                child: Text(
                                  d,
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedDay = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. وقت البداية ووقت النهاية
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'وقت البداية (HH:MM)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: startCtrl,
                                  decoration: InputDecoration(
                                    hintText: '08:30',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'وقت النهاية (HH:MM)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: endCtrl,
                                  decoration: InputDecoration(
                                    hintText: '10:00',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 5. القاعة والمبنى
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'القاعة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: roomCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'قاعة 101',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المبنى',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: buildingCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'المبنى الرئيسي',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: GoogleFonts.cairo(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final selectedCourse = availableCourses
                                    .where(
                                      (course) =>
                                          course.name == selectedCourseName,
                                    )
                                    .firstOrNull;
                                if (selectedCourse == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'لا توجد مادة مسجلة يمكن إضافتها إلى الجدول.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final session = ScheduleSession(
                                  scheduleId: existingSession?.scheduleId ?? '',
                                  courseId: selectedCourse.id,
                                  sectionId: sectionCtrl.text.trim(),
                                  doctorId: existingSession?.doctorId ?? '',
                                  doctorName: existingSession?.doctorName ?? '',
                                  activityType: selectedType == 'عملي'
                                      ? 'practical'
                                      : 'theory',
                                  activityTypeAr: selectedType,
                                  dayOfWeek: selectedDay,
                                  dayOfWeekAr: selectedDay,
                                  startTime: startCtrl.text.trim(),
                                  endTime: endCtrl.text.trim(),
                                  roomId: roomCtrl.text.trim(),
                                  roomDisplay: roomCtrl.text.trim(),
                                  buildingNameAr: buildingCtrl.text.trim(),
                                  termId: existingSession?.termId,
                                  isAdminOverride: true,
                                );
                                try {
                                  if (isEditing) {
                                    await StudentRepository.updateScheduleSession(
                                      _selectedStudentId,
                                      session,
                                    );
                                  } else {
                                    await StudentRepository.addScheduleSession(
                                      _selectedStudentId,
                                      session,
                                    );
                                  }
                                  if (!mounted ||
                                      !ctx.mounted ||
                                      !context.mounted) {
                                    return;
                                  }
                                  Navigator.pop(ctx);
                                  setState(() {});
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'تم حفظ الجلسة في جدول الطالب.',
                                          ),
                                        ),
                                      );
                                } catch (error) {
                                  if (!mounted || !context.mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('تعذر حفظ الجلسة: $error'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'حفظ التعديلات',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                                horizontal: 20,
                              ),
                              side: const BorderSide(color: _border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: _textSub,
                                fontWeight: FontWeight.w600,
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
          },
        );
      },
    );
  }

  void _confirmDeleteSession(ScheduleSession session) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تأكيد حذف الجلسة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _navy),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف جلسة (${StudentRepository.getCourseName(_selectedStudentId, session.courseId)}) من جدول الطالب؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: _textSub,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await StudentRepository.removeScheduleSession(
                    _selectedStudentId,
                    session.scheduleId,
                  );
                  if (!mounted || !ctx.mounted) return;
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الجلسة.')),
                  );
                } catch (error) {
                  if (!mounted || !ctx.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر حذف الجلسة: $error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'تأكيد الحذف',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _loadFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعذر تحميل قائمة الطلاب من الخادم.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _loadFuture = _loadStudents()),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        );
      }
      return _buildScheduleScreen(context);
    },
  );

  Widget _buildScheduleScreen(BuildContext context) {
    final student = _currentStudent;
    final sessions = student != null
        ? StudentRepository.getScheduleSessions(_selectedStudentId)
        : <ScheduleSession>[];
    final enrolledCourses = student != null
        ? StudentRepository.getEnrolledCourses(_selectedStudentId)
        : <Course>[];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              UniversityServicesHeader(
                title: 'إدارة جداول الطلاب',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // Search & Student Selection Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن طالب بالاسم أو الرقم الجامعي...',
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _navy,
                          size: 20,
                        ),
                        suffixIcon: _searchFilter.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => _searchCtrl.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: _lightBg,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
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
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                    const SizedBox(height: 10),

                    // Quick Student Switcher
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filteredStudents.map((s) {
                          final isSelected = s.studentId == _selectedStudentId;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text('${s.fullName} (${s.universityId})'),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedStudentId = s.studentId;
                                });
                              },
                              selectedColor: const Color(0xFFEAF4FB),
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? _blue : _textMain,
                              ),
                              side: BorderSide(
                                color: isSelected ? _blue : _border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    if (student != null) ...[
                      // 1. Student Summary Banner Card
                      Container(
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
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFF5B82E),
                              child: Text(
                                student.firstName.isNotEmpty
                                    ? student.firstName[0]
                                    : 'ط',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: _navy,
                                    ),
                                  ),
                                  Text(
                                    '${student.facultyNameAr}  •  السنة ${student.academicYear}  •  ${student.universityId}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: _textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Registered courses summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المقررات المسجلة (${enrolledCourses.length})',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
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
                              '${student.currentRegisteredCreditHours} ساعات معتمدة',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: enrolledCourses.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  size: 14,
                                  color: _blue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  c.courseNameAr,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _textMain,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 3. Schedule Sessions List Header + Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'جلسات الجدول الدراسي (${sessions.length})',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openAddOrEditSessionModal(),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text(
                              'إضافة جلسة',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Sessions List
                      if (sessions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 40,
                                color: _textSub,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'لا توجد جلسات مجدولة لهذا الطالب حالياً',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: _textSub,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _openAddOrEditSessionModal(),
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(
                                  'إضافة الجلسة الأولى',
                                  style: GoogleFonts.cairo(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sessions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final courseName = StudentRepository.getCourseName(
                              _selectedStudentId,
                              session.courseId,
                            );

                            return Container(
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
                                  // Top row: Course name + Action buttons
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              session.activityType ==
                                                  'practical'
                                              ? const Color(0xFFFFF4D6)
                                              : const Color(0xFFEAF4FB),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          session.activityType == 'practical'
                                              ? Icons.biotech_rounded
                                              : Icons.school_rounded,
                                          color:
                                              session.activityType ==
                                                  'practical'
                                              ? const Color(0xFFD97706)
                                              : _blue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              courseName,
                                              style: GoogleFonts.cairo(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: _navy,
                                              ),
                                            ),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFF1F5F9,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    session.sectionId,
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 10,
                                                      color: _navy,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        session.activityType ==
                                                            'practical'
                                                        ? const Color(
                                                            0xFFFFF8E1,
                                                          )
                                                        : const Color(
                                                            0xFFE8F4FD,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    session.activityTypeAr,
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 10,
                                                      color:
                                                          session.activityType ==
                                                              'practical'
                                                          ? const Color(
                                                              0xFFB45309,
                                                            )
                                                          : _blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit and Delete icons are for manual entries only.
                                      if (session.isAdminOverride)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: _blue,
                                              ),
                                              tooltip: 'تعديل الجلسة',
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                              onPressed: () =>
                                                  _openAddOrEditSessionModal(
                                                    session,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: Color(0xFFDC2626),
                                              ),
                                              tooltip: 'حذف الجلسة',
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                              onPressed: () =>
                                                  _confirmDeleteSession(
                                                    session,
                                                  ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Details Row: Day, Time, Room, Building
                                  Wrap(
                                    spacing: 14,
                                    runSpacing: 6,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 13,
                                            color: _blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            session.dayOfWeekAr,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: _textMain,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 13,
                                            color: _blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${session.startTime} - ${session.endTime}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: _textMain,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.meeting_room_outlined,
                                            size: 13,
                                            color: _blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            session.roomDisplay,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: _textMain,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (session.buildingNameAr != null &&
                                          session.buildingNameAr!.isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.apartment_rounded,
                                              size: 13,
                                              color: _blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              session.buildingNameAr!,
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: _textMain,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ] else
                      Center(
                        child: Text(
                          'يرجى اختيار طالب من القائمة أعلاه',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: _textSub,
                          ),
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
}
