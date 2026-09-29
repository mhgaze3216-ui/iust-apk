import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_admin_repository.dart';
import '../../../data/student_repository.dart';
import '../../../data/doctor_repository.dart';
import '../../../services/admin_preview_session.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final AdminUserAccount account;

  const AdminUserDetailsScreen({
    super.key,
    required this.account,
  });

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  late AdminUserAccount _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
  }

  void _toggleStatus() {
    setState(() {
      _account.isActive = !_account.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _account.isActive
              ? 'تم تفعيل حساب ${_account.name} بنجاح'
              : 'تم إيقاف حساب ${_account.name}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _account.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editPermissions() {
    final availablePermissions = [
      'الوصول إلى البوابة',
      'الخطة الدراسية',
      'التكليفات',
      'الجدول الأكاديمي',
      'تسجيل المقررات',
      'متابعة العلامات',
      'إدارة المقررات',
      'رصد العلامات',
      'رفع النتائج للإدارة',
      'قوائم الحرمان',
      'إدارة المستخدمين',
      'التحكم بالصلاحيات',
      'إدارة الطلبات',
      'النظام والخدمات',
    ];

    final tempPerms = List<String>.from(_account.permissions);

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF073B4C), size: 22),
                const SizedBox(width: 8),
                Text(
                  'تعديل الصلاحيات',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availablePermissions.map((perm) {
                    final isSelected = tempPerms.contains(perm);
                    return FilterChip(
                      label: Text(
                        perm,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF073B4C) : const Color(0xFF6F7F89),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF5B82E).withValues(alpha: 0.35),
                      checkmarkColor: const Color(0xFF073B4C),
                      backgroundColor: const Color(0xFFF6F9FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFF5B82E) : const Color(0xFFDCE8EE),
                        ),
                      ),
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            tempPerms.add(perm);
                          } else {
                            tempPerms.remove(perm);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF6F7F89))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073B4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    _account.permissions = List<String>.from(tempPerms);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث صلاحيات الحساب بنجاح', style: GoogleFonts.cairo()),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                },
                child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);
    const goldCol = Color(0xFFF5B82E);

    // Contextual academic data if student
    final studentData = _account.role == 'طالب'
        ? StudentRepository.getStudent(_account.targetId)
        : null;

    // Contextual doctor courses if doctor
    final doctorCourses = _account.role == 'دكتور' && _account.targetId == 'doctor-001'
        ? DoctorRepository.courses
        : null;

    final roleActionLabel = _account.role == 'طالب'
        ? 'دخول لواجهة الطالب'
        : (_account.role == 'دكتور'
            ? 'دخول لواجهة الدكتور'
            : (_account.role == 'أدمن' ? 'واجهة الأدمن' : 'دخول لواجهة الإداري'));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: navyCol, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'بيانات الحساب',
            style: GoogleFonts.cairo(
              color: navyCol,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _account.isActive ? Icons.check_circle_rounded : Icons.block_rounded,
                color: _account.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
              tooltip: _account.isActive ? 'الحساب نشط' : 'الحساب معطل',
              onPressed: _toggleStatus,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // ── Main Profile Header Card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardCol,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: _getRoleBgColor(_account.role),
                        child: Text(
                          _account.name.isNotEmpty ? _account.name[0] : 'U',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _getRoleColor(_account.role),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _account.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: textMain,
                                    ),
                                  ),
                                ),
                                if (_account.isDemo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'DEMO',
                                      style: GoogleFonts.cairo(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _account.jobTitle.isNotEmpty
                                  ? _account.jobTitle
                                  : _account.facultyOrDept,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: textSec,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getRoleBgColor(_account.role),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _account.role,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getRoleColor(_account.role),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _account.isActive
                                        ? const Color(0xFFEDFAF1)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _account.isActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _account.isActive ? 'نشط' : 'معطل',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _account.isActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Quick Enter Interface CTA ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldCol,
                        foregroundColor: navyCol,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => AdminPreviewSession.launchUserPreview(context, _account),
                      icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                      label: Text(
                        roleActionLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Account Details List ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardCol,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المعلومات الأساسية',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: navyCol,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('الاسم الكامل', _account.name),
                  _buildDetailRow('الرقم الجامعي / الوظيفي', _account.userNumber),
                  _buildDetailRow('اسم المستخدم', _account.username.isNotEmpty ? _account.username : _account.userNumber),
                  _buildDetailRow('الدور الأكاديمي / الوظيفي', _account.role),
                  _buildDetailRow('الكلية / القسم', _account.facultyOrDept),
                  _buildDetailRow('البريد الإلكتروني', _account.email),
                  _buildDetailRow('حالة الحساب', _account.isActive ? 'مفعل ومتاح للاستخدام' : 'موقوف مؤقتاً'),
                  _buildDetailRow('آخر دخول للنظام', 'اليوم، 10:14 ص'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Academic / Specialized Summary ───────────────────────────────
            if (studentData != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardCol,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, color: blueCol, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'الملخص الأكاديمي (سجل الطالب)',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: navyCol,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('الكلية', studentData.facultyNameAr),
                    _buildDetailRow('المعدل التراكمي', studentData.cumulativeGpa.toStringAsFixed(2)),
                    _buildDetailRow('المعدل الفصلي', studentData.semesterGpa.toStringAsFixed(2)),
                    _buildDetailRow('الساعات المنجزة', '${studentData.completedCreditHours} ساعة معتمدة'),
                    _buildDetailRow('السنة الدراسية', studentData.academicYear),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (doctorCourses != null && doctorCourses.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardCol,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: Color(0xFF7C3AED), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'المقررات المسندة',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: navyCol,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...doctorCourses.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${c.courseName} (${c.courseCode}) - ${c.studentCount} طالب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    color: textMain,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Permissions Section ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardCol,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الصلاحيات الممنوحة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: navyCol,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _editPermissions,
                        icon: const Icon(Icons.edit_rounded, size: 16, color: blueCol),
                        label: Text(
                          'تعديل الصلاحيات',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: blueCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _account.permissions.map((perm) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F9FC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderCol),
                        ),
                        child: Text(
                          perm,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textMain,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions Row ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _account.isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      side: BorderSide(
                        color: _account.isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggleStatus,
                    icon: Icon(
                      _account.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _account.isActive ? 'إيقاف الحساب' : 'تفعيل الحساب',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyCol,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _editPermissions,
                    icon: const Icon(Icons.security_rounded, size: 18),
                    label: Text(
                      'تعديل الصلاحيات',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF6F7F89),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B2E3B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'أدمن':
        return const Color(0xFFD97706);
      case 'طالب':
        return const Color(0xFF0F6CBD);
      case 'دكتور':
        return const Color(0xFF7C3AED);
      case 'إداري':
      case 'موظف':
      default:
        return const Color(0xFF073B4C);
    }
  }

  Color _getRoleBgColor(String role) {
    switch (role) {
      case 'أدمن':
        return const Color(0xFFFEF3C7);
      case 'طالب':
        return const Color(0xFFEAF4FB);
      case 'دكتور':
        return const Color(0xFFF5F0FF);
      case 'إداري':
      case 'موظف':
      default:
        return const Color(0xFFFFF4D6);
    }
  }
}
