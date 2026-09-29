import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_session.dart';
import '../../services/mock_auth_service.dart';
import 'subpages/admin_permissions_screen.dart';
import 'subpages/admin_system_log_screen.dart';
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

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  String _selectedLanguage = 'العربية';
  String _selectedTheme = 'فاتح (تلقائي)';

  // 11. Functional Notification preferences
  bool _notifyNewRequests = true;
  bool _notifyMaintenance = true;
  bool _notifyAccountUpdates = true;
  bool _notifyAnnouncements = true;
  bool _notifyServices = true;
  bool _notifyAcademic = true;

  @override
  Widget build(BuildContext context) {
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
                              'بيانات الحساب وإعدادات مركز الإدارة.',
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
                          'واجهة الإدارة',
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

              // ── 8. Admin Profile Card (Matching Student/Doctor) ───────
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
                            'رح',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'م. رنا الحسن',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'مسؤولة النظام والخدمات · إدارة الجامعة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'ADM-018',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _gold.withValues(alpha: 0.6)),
                              ),
                              child: Text(
                                'واجهة الإدارة',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFDE68A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Role Preview Trigger
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openRolePreviewSheet,
                            icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 16),
                            label: Text(
                              'معاينة واجهات الأدوار (طالب / دكتور)',
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

              // ── 9. Account Information Section ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('معلومات الحساب'),
                      const SizedBox(height: 8),
                      const _InfoGroup(items: [
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          label: 'الرقم الإداري',
                          value: 'ADM-018',
                        ),
                        _InfoRow(
                          icon: Icons.work_outline_rounded,
                          label: 'المسمى الوظيفي',
                          value: 'مسؤولة النظام والخدمات',
                        ),
                        _InfoRow(
                          icon: Icons.domain_rounded,
                          label: 'القسم',
                          value: 'إدارة النظام والخدمات',
                        ),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'البريد الجامعي',
                          value: 'admin.demo@iust.edu.sy',
                        ),
                        _InfoRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'حالة الحساب',
                          value: 'فعال',
                        ),
                      ]),

                      // ── 10. Preferences Section ────────────────────────
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
                          trailing: 'مخصصة',
                          onTap: _openNotificationSettings,
                        ),
                        _SettingsItem(
                          icon: Icons.palette_outlined,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _blue,
                          label: 'مظهر التطبيق',
                          trailing: _selectedTheme,
                          onTap: _openThemeSettings,
                        ),
                        _SettingsItem(
                          icon: Icons.security_rounded,
                          iconBg: const Color(0xFFFFF4D6),
                          iconColor: const Color(0xFFB78103),
                          label: 'إدارة الصلاحيات',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AdminPermissionsScreen()),
                          ),
                        ),
                        _SettingsItem(
                          icon: Icons.lock_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          label: 'تغيير كلمة المرور',
                          onTap: _openChangePasswordDialog,
                        ),
                      ]),

                      // ── 13. Support Section ────────────────────────────
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AboutScreen()),
                          ),
                        ),
                        _SettingsItem(
                          icon: Icons.history_edu_rounded,
                          iconBg: const Color(0xFFEDFAF1),
                          iconColor: const Color(0xFF2E9B5F),
                          label: 'سجل النظام',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AdminSystemLogScreen()),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── 14. Logout Button (Exact Student/Doctor Design) ─
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
                      // Bottom spacing to avoid overlap with floating bottom nav
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

  void _openThemeSettings() {
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
                'مظهر التطبيق',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                title: Text('فاتح (تلقائي مع النظام)', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedTheme.startsWith('فاتح')
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedTheme = 'فاتح (تلقائي)');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('داكن', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedTheme == 'داكن'
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedTheme = 'داكن');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 11. Functional Notification Settings ──────────────────────────────────
  void _openNotificationSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفضيلات الإشعارات الإدارية',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Text(
                  'حدد فئات التنبيهات الفورية التي ترغب باستلامها.',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  title: 'الطلبات الجديدة والمعاملات',
                  value: _notifyNewRequests,
                  onChanged: (v) {
                    setModalState(() => _notifyNewRequests = v);
                    setState(() {});
                  },
                ),
                _buildSwitchTile(
                  title: 'بلاغات الصيانة والأعطال',
                  value: _notifyMaintenance,
                  onChanged: (v) {
                    setModalState(() => _notifyMaintenance = v);
                    setState(() {});
                  },
                ),
                _buildSwitchTile(
                  title: 'تحديثات الحسابات والمستخدمين',
                  value: _notifyAccountUpdates,
                  onChanged: (v) {
                    setModalState(() => _notifyAccountUpdates = v);
                    setState(() {});
                  },
                ),
                _buildSwitchTile(
                  title: 'الإعلانات والتعاميم الرسمية',
                  value: _notifyAnnouncements,
                  onChanged: (v) {
                    setModalState(() => _notifyAnnouncements = v);
                    setState(() {});
                  },
                ),
                _buildSwitchTile(
                  title: 'الخدمات وصحة النظام والخوادم',
                  value: _notifyServices,
                  onChanged: (v) {
                    setModalState(() => _notifyServices = v);
                    setState(() {});
                  },
                ),
                _buildSwitchTile(
                  title: 'التنبيهات الأكاديمية والاعتراضات',
                  value: _notifyAcademic,
                  onChanged: (v) {
                    setModalState(() => _notifyAcademic = v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم حفظ تفضيلات الإشعارات بنجاح', style: GoogleFonts.cairo()),
                          backgroundColor: const Color(0xFF2E9B5F),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('حفظ التفضيلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  ),
                ),
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

  // ── 12. Functional Change Password for edari ──────────────────────────────
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تحديث كلمة مرور حساب الإدارة (edari)',
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      hintText: 'أدخل 12345',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFDC2626)),
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

                  final success = MockAuthService.changeAdminPassword(
                    currentPassword: cur,
                    newPassword: nxt,
                  );

                  if (success) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تغيير كلمة المرور لحساب الإدارة بنجاح', style: GoogleFonts.cairo()),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: _blue),
              const SizedBox(width: 8),
              Text(
                'المساعدة والدعم التقني',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16, color: _textMain),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'فريق الدعم الفني لمديرية النظم والمعلومات متاح للدعم المباشر ومساندة العمليات الإدارية.',
                style: GoogleFonts.cairo(fontSize: 13, color: _textMain, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildHelpRow(Icons.phone_outlined, 'الهاتف الداخلي: 104 - 105'),
              _buildHelpRow(Icons.email_outlined, 'البريد: it.support@iust.edu.sy'),
              _buildHelpRow(Icons.location_on_outlined, 'الموقع: مبنى الإدارة المركزية - الطابق الأول'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('حسناً', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _textSub),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.cairo(fontSize: 12, color: _textMain))),
        ],
      ),
    );
  }

  void _openRolePreviewSheet() {
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
                'معاينة واجهات الأدوار (Role Preview)',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'استعراض تجربة المنصة كطالب أو كدكتور دون تعديل بياناتهم الحقيقية.',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFEAF4FB), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.school_rounded, color: _blue),
                ),
                title: Text('معاينة واجهة الطالب', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                subtitle: Text('استعراض المقررات والجدول وخدمات الطلاب', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: _textSub),
                onTap: () {
                  Navigator.of(context).pop();
                  AdminSession.startPreview('student');
                  Navigator.pushNamed(context, '/student');
                },
              ),
              const Divider(height: 1, color: _border),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF5F0FF), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF7C3AED)),
                ),
                title: Text('معاينة واجهة الدكتور', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                subtitle: Text('استعراض رصد العلامات والحضور وتدريس الشعب', style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: _textSub),
                onTap: () {
                  Navigator.of(context).pop();
                  AdminSession.startPreview('doctor');
                  Navigator.pushNamed(context, '/doctor');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 14. Exact Logout Design ───────────────────────────────────────────────
  void _confirmLogout(BuildContext context) {
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
                AdminSession.clearSession();
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

// ── Supporting Visual Components (identical to StudentAccountScreen/DoctorAccountScreen) ──

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
