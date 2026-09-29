import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/doctor_session.dart';
import '../../services/mock_auth_service.dart';
import '../../services/admin_preview_session.dart';
import 'doctor_edit_profile_screen.dart';
import 'doctor_settings_screen.dart';
import 'doctor_transport_screen.dart';
import 'doctor_help_screen.dart';
import '../about_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold = Color(0xFFF5B82E);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorAccountScreen extends StatefulWidget {
  const DoctorAccountScreen({super.key});

  @override
  State<DoctorAccountScreen> createState() => _DoctorAccountScreenState();
}

class _DoctorAccountScreenState extends State<DoctorAccountScreen> {
  String _selectedLanguage = 'العربية';

  // Notification preferences
  bool _notifyQuestions = true;
  bool _notifySubmissions = true;
  bool _notifyCourses = true;
  bool _notifyAnnouncements = true;
  bool _notifySchedule = true;

  @override
  Widget build(BuildContext context) {
    final p = DoctorSession.currentProfile;

    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // ── Page Title & Subtitle ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حسابي',
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'بيانات الحساب وإعدادات تجربة التطبيق.',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: _textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFAF1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          'بيانات تجريبية',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Doctor Profile Card ────────────────────────────────────
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
                      boxShadow: [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.20),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar — initials inside gold circle
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Text(
                            p.fullName.isNotEmpty && p.fullName != 'غير مضاف بعد'
                                ? p.fullName[0]
                                : 'د',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.fullName.isNotEmpty && p.fullName != 'غير مضاف بعد'
                              ? p.fullName
                              : 'لوحة الدكتور',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.department.isNotEmpty &&
                                  p.department != 'غير مضاف بعد' &&
                                  p.department != 'غير متوفر'
                              ? 'عضو هيئة تدريس · ${p.department}'
                              : 'عضو هيئة تدريس',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Edit profile button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => const DoctorEditProfileScreen(),
                                ),
                              );
                              if (updated == true && mounted) {
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                            label: Text(
                              'تعديل البيانات',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
              ),

              // ── Professional Information Section ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('المعلومات الأكاديمية'),
                      const SizedBox(height: 8),
                      _InfoGroup(items: [
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'الاسم',
                          value: p.fullName.isNotEmpty ? p.fullName : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.meeting_room_rounded,
                          label: 'المكتب',
                          value: p.office != null &&
                                  p.office!.isNotEmpty &&
                                  p.office != 'غير محدد'
                              ? p.office!
                              : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'أيام الدوام',
                          value: p.workingDays != null && p.workingDays!.isNotEmpty
                              ? p.workingDays!
                              : 'السبت',
                        ),
                        _InfoRow(
                          icon: Icons.access_time_rounded,
                          label: 'الساعات المكتبية',
                          value: p.officeHours != null && p.officeHours!.isNotEmpty
                              ? p.officeHours!
                              : 'السبت 13:00 - 14:00',
                        ),
                        _InfoRow(
                          icon: Icons.school_rounded,
                          label: 'الكلية',
                          value: p.faculty.isNotEmpty && p.faculty != 'غير مضافة بعد'
                              ? p.faculty
                              : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.biotech_rounded,
                          label: 'القسم',
                          value: p.department.isNotEmpty && p.department != 'غير مضاف بعد'
                              ? p.department
                              : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'الرتبة الأكاديمية',
                          value: p.academicRank.isNotEmpty && p.academicRank != 'غير مضاف بعد'
                              ? p.academicRank
                              : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          label: 'الرقم الوظيفي',
                          value: p.doctorId.isNotEmpty ? p.doctorId : 'غير متوفر',
                        ),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'البريد الجامعي',
                          value: p.email != null && p.email!.isNotEmpty && p.email != 'غير متوفر'
                              ? p.email!
                              : 'غير متوفر',
                        ),
                      ]),

                      // ── Teaching Summary Section ───────────────────────
                      const SizedBox(height: 16),
                      const _SectionLabel('ملخص التدريس'),
                      const SizedBox(height: 8),
                      _InfoGroup(items: [
                        _InfoRow(
                          icon: Icons.menu_book_rounded,
                          label: 'المقررات الحالية',
                          value: '${p.coursesCount}',
                        ),
                        _InfoRow(
                          icon: Icons.groups_rounded,
                          label: 'عدد الشعب',
                          value: '${p.sectionsCount}',
                        ),
                        _InfoRow(
                          icon: Icons.people_rounded,
                          label: 'عدد الطلاب',
                          value: '${p.studentsCount}',
                        ),
                        _InfoRow(
                          icon: Icons.assignment_turned_in_rounded,
                          label: 'التسليمات للمراجعة',
                          value: '${p.reviewSubmissionsCount}',
                        ),
                        _InfoRow(
                          icon: Icons.question_answer_rounded,
                          label: 'أسئلة الطلاب',
                          value: '${p.newQuestionsCount}',
                        ),
                        _InfoRow(
                          icon: Icons.description_rounded,
                          label: 'نماذج الامتحانات المسودة',
                          value: '${p.draftTemplatesCount}',
                        ),
                      ]),

                      // ── Services Section ───────────────────────────────
                      const SizedBox(height: 16),
                      const _SectionLabel('الخدمات الجامعية'),
                      const SizedBox(height: 8),
                      _SettingsGroup(items: [
                        _SettingsItem(
                          icon: Icons.directions_bus_rounded,
                          iconBg: const Color(0xFFFFF4D6),
                          iconColor: const Color(0xFFB78103),
                          label: 'النقل الجامعي',
                          trailing: 'المواعيد وأقرب رحلة',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DoctorTransportScreen(),
                            ),
                          ),
                        ),
                      ]),

                      // ── Preferences Section ────────────────────────────
                      const SizedBox(height: 16),
                      const _SectionLabel('التفضيلات'),
                      const SizedBox(height: 8),
                      _SettingsGroup(items: [
                        _SettingsItem(
                          icon: Icons.language_rounded,
                          iconBg: const Color(0xFFEDFAF1),
                          iconColor: const Color(0xFF2E9B5F),
                          label: 'لغة التطبيق',
                          trailing: _selectedLanguage,
                          onTap: _openLanguageSelector,
                        ),
                        _SettingsItem(
                          icon: Icons.notifications_rounded,
                          iconBg: const Color(0xFFFFF8E1),
                          iconColor: const Color(0xFFD4900A),
                          label: 'الإشعارات',
                          onTap: _openNotificationSettings,
                        ),
                        _SettingsItem(
                          icon: Icons.lock_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          label: 'تغيير كلمة المرور',
                          onTap: _openChangePasswordDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.settings_rounded,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _blue,
                          label: 'الإعدادات',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DoctorSettingsScreen(),
                            ),
                          ),
                        ),
                      ]),

                      // ── Support Section ────────────────────────────────
                      const SizedBox(height: 16),
                      const _SectionLabel('الدعم'),
                      const SizedBox(height: 8),
                      _SettingsGroup(items: [
                        _SettingsItem(
                          icon: Icons.help_outline_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          label: 'المساعدة والدعم',
                          onTap: _openHelpDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.info_outline_rounded,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _blue,
                          label: 'عن التطبيق',
                          trailing: 'v1.0.0',
                          onTap: _openAboutDialog,
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // ── Logout Button ──────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFE53E3E),
                            size: 18,
                          ),
                          label: Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53E3E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      // Bottom spacing to avoid overlap with bottom nav & floating button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Handlers & Dialogs ───────────────────────────────────────────────────

  void _openLanguageSelector() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر لغة التطبيق',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                title: Text('العربية (الافتراضية)', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedLanguage == 'العربية'
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'العربية');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('English', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedLanguage == 'English'
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'English');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNotificationSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                Text(
                  'إعدادات إشعارات الدكتور',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر التنبيهات التي ترغب في استلامها فورياً',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  title: 'إشعارات أسئلة الطلاب',
                  value: _notifyQuestions,
                  onChanged: (val) {
                    setModalState(() => _notifyQuestions = val);
                    setState(() => _notifyQuestions = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'إشعارات التسليمات والواجبات',
                  value: _notifySubmissions,
                  onChanged: (val) {
                    setModalState(() => _notifySubmissions = val);
                    setState(() => _notifySubmissions = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'إشعارات المقررات والشعب',
                  value: _notifyCourses,
                  onChanged: (val) {
                    setModalState(() => _notifyCourses = val);
                    setState(() => _notifyCourses = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'إشعارات الإعلانات الجامعية',
                  value: _notifyAnnouncements,
                  onChanged: (val) {
                    setModalState(() => _notifyAnnouncements = val);
                    setState(() => _notifyAnnouncements = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'إشعارات المواعيد الأكاديمية',
                  value: _notifySchedule,
                  onChanged: (val) {
                    setModalState(() => _notifySchedule = val);
                    setState(() => _notifySchedule = val);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('حفظ الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: GoogleFonts.cairo(fontSize: 13, color: _textMain)),
          ),
          Switch(
            value: value,
            activeThumbColor: _navy,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _openChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              'تغيير كلمة المرور',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16, color: _textMain),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: true,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFE53E3E)),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
              ),
              ElevatedButton(
                onPressed: () {
                  final cur = currentPassCtrl.text.trim();
                  final nxt = newPassCtrl.text.trim();
                  final conf = confirmPassCtrl.text.trim();

                  if (cur.isEmpty || nxt.isEmpty || conf.isEmpty) {
                    setDialogState(() => errorText = 'يرجى ملء جميع الحقول');
                    return;
                  }
                  if (nxt != conf) {
                    setDialogState(() => errorText = 'كلمتا المرور غير متطابقتين');
                    return;
                  }
                  if (nxt.length < 4) {
                    setDialogState(() => errorText = 'كلمة المرور يجب أن لا تقل عن 4 رموز');
                    return;
                  }

                  final success = MockAuthService.changeDoctorPassword(
                    currentPassword: cur,
                    newPassword: nxt,
                  );

                  if (success) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تغيير كلمة المرور بنجاح', style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFF2E9B5F),
                      ),
                    );
                  } else {
                    setDialogState(() => errorText = 'كلمة المرور الحالية غير صحيحة');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openHelpDialog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DoctorHelpScreen()),
    );
  }

  void _openAboutDialog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
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
              'أنت تتصفح واجهة الدكتور بصلاحيات الإدارة. هل تريد العودة إلى لوحة الإدارة أم تسجيل خروج حساب الإدارة؟',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'هل تريد تسجيل الخروج؟',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
          ),
          content: Text(
            'سيتم إنهاء جلستك الحالية والعودة إلى شاشة تسجيل الدخول.',
            style: GoogleFonts.cairo(color: _textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                DoctorSession.clearSession();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Visual Components (identical to StudentAccountScreen) ────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textSub,
        ),
      );
}

class _InfoRow {
  final IconData icon;
  final String label, value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final row = items[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(row.icon, color: _blue, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Text(
                        row.label,
                        style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 5,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, color: _border, indent: 62),
            ],
          );
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
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
  });
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(18) : Radius.zero,
                  bottom: i == items.length - 1 ? const Radius.circular(18) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.label,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textMain,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.trailing != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Text(
                            item.trailing!,
                            style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: _textSub,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, color: _border, indent: 64),
            ],
          );
        }),
      ),
    );
  }
}
