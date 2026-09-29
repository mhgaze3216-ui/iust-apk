import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/administrative_staff_session.dart';
import '../../services/admin_preview_session.dart';
import '../../services/mock_auth_service.dart';
import 'widgets/university_services_header.dart';
import 'subpages/university_notifications_screen.dart';
import 'subpages/university_faq_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _gold = Color(0xFFF5B82E);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

/// Administrative Staff Account / Settings screen.
/// Follows the standard visual UI pattern used in Student and Doctor screens
/// with the unified IUST Administrative Header.
class UniversityAccountScreen extends StatefulWidget {
  final bool showBackButton;

  const UniversityAccountScreen({super.key, this.showBackButton = false});

  @override
  State<UniversityAccountScreen> createState() => _UniversityAccountScreenState();
}

class _UniversityAccountScreenState extends State<UniversityAccountScreen> {
  String _selectedLanguage = 'العربية';
  String _selectedTheme = 'فاتح';

  @override
  Widget build(BuildContext context) {
    final staffName = AdministrativeStaffSession.hasActiveSession
        ? AdministrativeStaffSession.currentStaffName
        : 'محمود العلي';
    final department = AdministrativeStaffSession.hasActiveSession
        ? AdministrativeStaffSession.currentDepartment
        : 'القبول والتسجيل';
    final jobTitle = AdministrativeStaffSession.hasActiveSession
        ? AdministrativeStaffSession.currentJobTitle
        : 'موظف شؤون الطلاب والقبول';
    final userNumber = AdministrativeStaffSession.hasActiveSession
        ? AdministrativeStaffSession.currentUserNumber
        : 'ADM-071';
    final initial = staffName.trim().isNotEmpty ? staffName.trim()[0] : 'إ';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Header with IUST Logo & Name ───────────────────
              UniversityServicesHeader(
                title: 'حسابي',
                showBackButton: widget.showBackButton || Navigator.canPop(context),
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // ── Scrollable Settings Content ─────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    // ── Compact Profile Card (Matching Student & Doctor) ───
                    Container(
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
                              initial,
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _navy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            staffName,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$userNumber  ·  $department  ·  $jobTitle',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Stat row
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  label: 'الرقم الوظيفي',
                                  value: userNumber,
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white24),
                              const Expanded(
                                child: _StatTile(
                                  label: 'الصفة الوظيفية',
                                  value: 'موظف إداري',
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white24),
                              const Expanded(
                                child: _StatTile(
                                  label: 'حالة الحساب',
                                  value: 'نشط',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 1. الحساب ─────────────────────────────────────
                    const _SectionLabel('الحساب'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.badge_outlined,
                        iconBg: const Color(0xFFEAF4FB),
                        iconColor: _blue,
                        label: 'بيانات الحساب الوظيفي',
                        onTap: () => _showStaffDetailsDialog(context),
                      ),
                      _SettingsItem(
                        icon: Icons.edit_note_rounded,
                        iconBg: const Color(0xFFEDFAF1),
                        iconColor: const Color(0xFF16A34A),
                        label: 'تعديل البيانات المسموحة',
                        onTap: () => _showEditAllowedDetailsDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── 2. التفضيلات ──────────────────────────────────
                    const _SectionLabel('التفضيلات'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.language_rounded,
                        iconBg: const Color(0xFFEDFAF1),
                        iconColor: const Color(0xFF2E9B5F),
                        label: 'اللغة',
                        trailing: _selectedLanguage,
                        onTap: () => _openLanguageSelector(context),
                      ),
                      _SettingsItem(
                        icon: Icons.dark_mode_outlined,
                        iconBg: const Color(0xFFFFF4D6),
                        iconColor: const Color(0xFFD97706),
                        label: 'الوضع الداكن / الفاتح',
                        trailing: _selectedTheme,
                        onTap: () => _openThemeSelector(context),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_rounded,
                        iconBg: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFD4900A),
                        label: 'الإشعارات',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UniversityNotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── 3. الأمان ──────────────────────────────────────
                    const _SectionLabel('الأمان'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.lock_rounded,
                        iconBg: const Color(0xFFF5F0FF),
                        iconColor: const Color(0xFF7C3AED),
                        label: 'تغيير كلمة المرور',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── 4. الدعم ───────────────────────────────────────
                    const _SectionLabel('الدعم'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        iconBg: const Color(0xFFF5F0FF),
                        iconColor: const Color(0xFF7C3AED),
                        label: 'المساعدة والدعم الفني',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UniversityFaqScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        iconBg: const Color(0xFFEAF4FB),
                        iconColor: _blue,
                        label: 'عن التطبيق',
                        trailing: 'v1.0.0',
                        onTap: () => _openAboutDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── 5. تسجيل الخروج (Outlined Red Button) ────────
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
                    // Bottom clearance for floating bottom nav & FAB
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs & Handlers ───────────────────────────────────────────────────

  void _showStaffDetailsDialog(BuildContext context) {
    final staffName = AdministrativeStaffSession.currentStaffName;
    final staffNumber = AdministrativeStaffSession.currentUserNumber;
    final department = AdministrativeStaffSession.currentDepartment;
    final jobTitle = AdministrativeStaffSession.currentJobTitle;
    final email = AdministrativeStaffSession.currentEmail;
    final perms = AdministrativeStaffSession.currentPermissions;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: mq.size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'بيانات الحساب الوظيفي',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('الاسم الكامل', staffName),
                            _buildInfoRow('الرقم الوظيفي', staffNumber),
                            _buildInfoRow('الدور الوظيفي', 'موظف إداري'),
                            _buildInfoRow('الجهة الإدارية', department),
                            _buildInfoRow('المسمى الوظيفي', jobTitle),
                            _buildInfoRow('البريد الجامعي', email),
                            const SizedBox(height: 12),
                            Text(
                              'الصلاحيات الإدارية:',
                              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _navy),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: perms.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF4FB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBCE0FD)),
                                  ),
                                  child: Text(
                                    p,
                                    style: GoogleFonts.cairo(fontSize: 11, color: _blue, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('إغلاق', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Keyboard-safe edit dialog for administrative staff details.
  /// Uses ConstrainedBox, Flexible, and SingleChildScrollView so it never overflows.
  void _showEditAllowedDetailsDialog(BuildContext context) {
    final phoneCtrl = TextEditingController(text: '0988123456');
    final officeCtrl = TextEditingController(text: 'مبنى الإدارة - الطابق الأول - مكتب 104');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: mq.size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title: readable and centered
                    Text(
                      'تعديل البيانات المسموحة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Scrollable content area that adapts gracefully when keyboard opens
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom > 0 ? 8 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description text visible
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBCE0FD)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'يمكنك تعديل بيانات التواصل وموقع المكتب فقط، أما البيانات الرسمية فتعدل من خلال الإدارة العامة.',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: _textMain,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field 1: Phone
                            Text(
                              'رقم الهاتف الداخلي / الجوال',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_outlined, color: _navy, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              style: GoogleFonts.cairo(fontSize: 13),
                            ),
                            const SizedBox(height: 14),

                            // Field 2: Office location
                            Text(
                              'موقع المكتب الإداري',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: officeCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_on_outlined, color: _navy, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              style: GoogleFonts.cairo(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Actions row: buttons stay visible and do not collide
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: _border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                color: _textSub,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم حفظ البيانات بنجاح', style: GoogleFonts.cairo()),
                                  backgroundColor: const Color(0xFF16A34A),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'حفظ التعديل',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: mq.size.height * 0.85,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تغيير كلمة المرور',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom > 0 ? 8 : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('كلمة المرور الحالية',
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _textMain)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: currentCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'أدخل كلمة المرور الحالية',
                                prefixIcon: const Icon(Icons.lock_outline, color: _navy, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('كلمة المرور الجديدة',
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _textMain)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: newCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'أدخل كلمة المرور الجديدة',
                                prefixIcon: const Icon(Icons.lock_reset_rounded, color: _navy, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('تأكيد كلمة المرور الجديدة',
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _textMain)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: confirmCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'أعد إدخال كلمة المرور الجديدة',
                                prefixIcon: const Icon(Icons.check_circle_outline, color: _navy, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: _border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final cur = currentCtrl.text.trim();
                              final nw = newCtrl.text.trim();
                              final cnf = confirmCtrl.text.trim();

                              if (cur.isEmpty || nw.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('يرجى ملء جميع الحقول', style: GoogleFonts.cairo()),
                                    backgroundColor: const Color(0xFFDC2626),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              if (nw != cnf) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('كلمة المرور الجديدة وتأكيدها غير متطابقين', style: GoogleFonts.cairo()),
                                    backgroundColor: const Color(0xFFDC2626),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final ok = MockAuthService.changeAdministrativeStaffPassword(
                                username: 'edari',
                                currentPassword: cur,
                                newPassword: nw,
                              );

                              if (ok) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم تغيير كلمة المرور بنجاح', style: GoogleFonts.cairo()),
                                    backgroundColor: const Color(0xFF16A34A),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('كلمة المرور الحالية غير صحيحة', style: GoogleFonts.cairo()),
                                    backgroundColor: const Color(0xFFDC2626),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('تحديث كلمة المرور',
                                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openLanguageSelector(BuildContext context) {
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

  void _openThemeSelector(BuildContext context) {
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
                'الوضع الداكن / الفاتح',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                title: Text('الوضع الفاتح (الافتراضي)', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedTheme.contains('فاتح')
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedTheme = 'فاتح');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تفعيل الوضع الفاتح', style: GoogleFonts.cairo()),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('الوضع الداكن', style: GoogleFonts.cairo(fontSize: 14)),
                trailing: _selectedTheme == 'داكن'
                    ? const Icon(Icons.check_circle_rounded, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _selectedTheme = 'داكن');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تفعيل الوضع الداكن', style: GoogleFonts.cairo()),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'IUST Campus Portal',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 36, color: _navy),
      children: [
        Text(
          'بوابة الخدمات الإدارية والأكاديمية الموحدة للجامعة الدولية الخاصة للعلوم والتكنولوجيا IUST.',
          style: GoogleFonts.cairo(),
        ),
      ],
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
              'أنت تتصفح واجهة الموظف الإداري بصلاحيات الإدارة. هل تريد العودة إلى لوحة الإدارة أم تسجيل خروج حساب الإدارة؟',
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
            'تسجيل الخروج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: GoogleFonts.cairo(color: _textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                AdministrativeStaffSession.clearSession();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('خروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _textMain),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared UI Pattern Widgets (Strictly Matching Student & Doctor) ──────────

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
          ),
        ],
      );
}

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

class _SettingsItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.onTap,
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
                onTap: () {
                  if (item.onTap != null) {
                    item.onTap!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('هذه الخدمة ستتوفر قريباً', style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFF073B4C),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
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
                        child: Text(
                          item.label,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textMain,
                          ),
                        ),
                      ),
                      if (item.trailing != null)
                        Text(
                          item.trailing!,
                          style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
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
