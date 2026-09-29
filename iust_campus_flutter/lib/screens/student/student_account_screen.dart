import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';
import '../../services/admin_preview_session.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentAccountScreen extends StatelessWidget {
  final String? studentId;
  const StudentAccountScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final p = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;

    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // ── page title ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text('حسابي',
                      style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                ),
              ),

              // ── profile card ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF073B4C), Color(0xFF0F6CBD)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(children: [
                      // avatar — initials only (no profile image available)
                      Container(
                        width: 72, height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _gold, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 2),
                        ),
                        child: Text(
                          p.firstName.isNotEmpty
                              ? p.firstName[0]
                              : (p.fullName.isNotEmpty ? p.fullName[0] : 'ط'),
                          style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _navy),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(p.fullName,
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        '${p.universityId}  ·  ${p.facultyNameAr}  ·  ${p.academicYear}',
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // stat row
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatTile(
                                label: 'المعدل التراكمي',
                                value: p.cumulativeGpa.toStringAsFixed(2)),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatTile(
                                label: 'المعدل الفصلي',
                                value: p.semesterGpa.toStringAsFixed(2)),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatTile(
                                label: 'الساعات المجتازة',
                                value: '${p.completedCreditHours}'),
                          ]),
                    ]),
                  ),
                ),
              ),

              // ── academic details section ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('المعلومات الأكاديمية'),
                        const SizedBox(height: 8),
                        _InfoGroup(items: [
                          _InfoRow(icon: Icons.school_rounded,            label: 'الكلية',                 value: p.facultyNameAr),
                          _InfoRow(icon: Icons.biotech_rounded,           label: 'الاختصاص',               value: p.majorNameAr),
                          _InfoRow(icon: Icons.calendar_today_rounded,    label: 'السنة الدراسية',          value: p.academicYear),
                          _InfoRow(icon: Icons.how_to_reg_rounded,        label: 'سنة القبول',              value: '${p.admissionYear}'),
                          _InfoRow(icon: Icons.verified_rounded,          label: 'الحالة الأكاديمية',       value: p.academicStatusAr),
                          _InfoRow(icon: Icons.event_note_rounded,        label: 'الفصل الحالي',            value: p.currentSemesterNameAr),
                          _InfoRow(icon: Icons.numbers_rounded,           label: 'الرقم الجامعي',           value: p.universityId),
                          _InfoRow(icon: Icons.email_outlined,            label: 'البريد الجامعي',          value: p.universityEmail ?? 'غير متوفر'),
                          _InfoRow(icon: Icons.person_search_rounded,     label: 'المرشد الأكاديمي',        value: p.academicAdvisorName ?? 'غير متوفر'),
                        ]),

                        const SizedBox(height: 16),
                        _SectionLabel('الساعات الدراسية'),
                        const SizedBox(height: 8),
                        _InfoGroup(items: [
                          _InfoRow(icon: Icons.check_circle_rounded,      label: 'الساعات المجتازة',        value: '${p.completedCreditHours}'),
                          _InfoRow(icon: Icons.radio_button_unchecked,    label: 'الساعات المطلوبة',        value: '${p.requiredCreditHours}'),
                          _InfoRow(icon: Icons.hourglass_bottom_rounded,  label: 'الساعات المتبقية',        value: '${p.remainingCreditHours}'),
                          _InfoRow(icon: Icons.app_registration_rounded,  label: 'الساعات المسجلة حاليًا', value: '${p.currentRegisteredCreditHours}'),
                          _InfoRow(icon: Icons.menu_book_rounded,         label: 'المواد الحالية',          value: '${p.currentCoursesCount}'),
                        ]),

                        // ── settings ─────────────────────────────────────
                        const SizedBox(height: 16),
                        _SectionLabel('التفضيلات'),
                        const SizedBox(height: 8),
                        _SettingsGroup(items: const [
                          _SettingsItem(icon: Icons.language_rounded,      iconBg: Color(0xFFEDFAF1), iconColor: Color(0xFF2E9B5F), label: 'لغة التطبيق',         trailing: 'العربية'),
                          _SettingsItem(icon: Icons.notifications_rounded, iconBg: Color(0xFFFFF8E1), iconColor: Color(0xFFD4900A), label: 'الإشعارات'),
                          _SettingsItem(icon: Icons.lock_rounded,          iconBg: Color(0xFFF5F0FF), iconColor: Color(0xFF7C3AED), label: 'تغيير كلمة المرور'),
                          _SettingsItem(icon: Icons.settings_rounded,      iconBg: Color(0xFFEAF4FB), iconColor: _blue,            label: 'الإعدادات'),
                        ]),

                        const SizedBox(height: 16),
                        _SectionLabel('الدعم'),
                        const SizedBox(height: 8),
                        _SettingsGroup(items: const [
                          _SettingsItem(icon: Icons.help_outline_rounded,  iconBg: Color(0xFFF5F0FF), iconColor: Color(0xFF7C3AED), label: 'المساعدة والدعم'),
                          _SettingsItem(icon: Icons.info_outline_rounded,  iconBg: Color(0xFFEAF4FB), iconColor: _blue,            label: 'عن التطبيق', trailing: 'v1.0.0'),
                        ]),

                        const SizedBox(height: 16),

                        // logout button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmLogout(context),
                            icon: const Icon(Icons.logout_rounded,
                                color: Color(0xFFE53E3E), size: 18),
                            label: Text('تسجيل الخروج',
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53E3E))),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    if (AdminPreviewSession.isAdminPreview) {
      showDialog<void>(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              'أنت في وضع المعاينة الإدارية',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
            ),
            content: Text(
              'أنت تتصفح واجهة الطالب بصلاحيات الإدارة. هل تريد العودة إلى لوحة الإدارة أم تسجيل خروج حساب الإدارة؟',
              style: GoogleFonts.cairo(color: _textSub),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AdminPreviewSession.logoutAdmin(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('تسجيل خروج الإدارة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AdminPreviewSession.exitPreview(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('العودة إلى الإدارة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('تسجيل الخروج',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800, color: _textMain)),
          content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟',
              style: GoogleFonts.cairo(color: _textSub)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                StudentSession.clearSession();
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (r) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('خروج',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── widgets ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70)),
      ]);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w700, color: _textSub));
}

class _InfoRow {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.items});
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final row = items[i];
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(row.icon, color: _blue, size: 17),
                ),
                const SizedBox(width: 12),
                Text(row.label,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: _textSub)),
                const Spacer(),
                Text(row.value,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textMain)),
              ]),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: _border, indent: 62),
          ]);
        }),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _SettingsItem(
      {required this.icon,
      required this.iconBg,
      required this.iconColor,
      required this.label,
      this.trailing}) : onTap = null;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<_SettingsItem> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(children: [
            InkWell(
              onTap: () {
                if (item.onTap != null) {
                  item.onTap!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('هذه الخدمة ستتوفر قريباً',
                          style: GoogleFonts.cairo()),
                      backgroundColor: const Color(0xFF073B4C),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(18) : Radius.zero,
                bottom: i == items.length - 1
                    ? const Radius.circular(18)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon, color: item.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textMain)),
                  ),
                  if (item.trailing != null)
                    Text(item.trailing!,
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: _textSub)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_left_rounded,
                      color: _textSub, size: 18),
                ]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: _border, indent: 64),
          ]);
        }),
      ),
    );
  }
}
