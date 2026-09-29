import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin_session.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _gold = Color(0xFFF5B82E);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminAccountScreenV2 extends StatefulWidget {
  const AdminAccountScreenV2({super.key});

  @override
  State<AdminAccountScreenV2> createState() => _AdminAccountScreenV2State();
}

class _AdminAccountScreenV2State extends State<AdminAccountScreenV2> {
  String _selectedLanguage = 'العربية';
  bool _notificationsEnabled = true;
  String _currentTheme = 'الوضع الفاتح (الافتراضي)';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'لغة التطبيق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
          ),
          content: RadioGroup<String>(
            groupValue: _selectedLanguage,
            onChanged: (val) {
              if (val == null) return;
              setState(() => _selectedLanguage = val);
              Navigator.pop(ctx);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              RadioListTile<String>(
                title: Text('العربية (الافتراضية)', style: GoogleFonts.cairo()),
                value: 'العربية',
                activeColor: _navy,
              ),
              RadioListTile<String>(
                title: Text('English', style: GoogleFonts.cairo()),
                value: 'English',
                activeColor: _navy,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'مظهر التطبيق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
          ),
          content: RadioGroup<String>(
            groupValue: _currentTheme,
            onChanged: (val) {
              if (val == null) return;
              setState(() => _currentTheme = val);
              Navigator.pop(ctx);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              RadioListTile<String>(
                title: Text('الوضع الفاتح (الافتراضي)', style: GoogleFonts.cairo()),
                value: 'الوضع الفاتح (الافتراضي)',
                activeColor: _navy,
              ),
              RadioListTile<String>(
                title: Text('الوضع الداكن', style: GoogleFonts.cairo()),
                value: 'الوضع الداكن',
                activeColor: _navy,
              ),
              RadioListTile<String>(
                title: Text('تلقائي حسب النظام', style: GoogleFonts.cairo()),
                value: 'تلقائي حسب النظام',
                activeColor: _navy,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'تغيير كلمة المرور',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _textMain),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  labelStyle: GoogleFonts.cairo(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  labelStyle: GoogleFonts.cairo(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث كلمة المرور بنجاح'),
                    backgroundColor: _navy,
                  ),
                );
              },
              child: Text('حفظ التعديل', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionsInfoDialog() {
    final perms = [
      'إدارة جميع طلبات وبلاغات الطلاب والكادر',
      'جدولة وتأكيد المواعيد الإدارية',
      'تحديث دليل المعاملات والمستندات',
      'تفعيل وتعطيل حسابات المستخدمين',
      'نشر الأخبار والتعاميم والتنبيهات',
      'إدارة الأسئلة الشائعة والاستفسارات',
      'إدارة وتحديث جداول حافلات الجامعة',
    ];

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'صلاحيات الحساب الإداري',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _navy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: perms.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p,
                          style: GoogleFonts.cairo(fontSize: 12.5, color: _textMain),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('المساعدة والدعم التقني', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _navy)),
          content: Text(
            'للحصول على الدعم الإداري والتقني يمكنكم التواصل مع دائرة تكنولوجيا المعلومات:\n\nالهاتف الداخلي: 104\nالبريد: it.support@iust.edu.sy\nالمكتب: الإدارة العامة - الطابق الثاني',
            style: GoogleFonts.cairo(fontSize: 13, height: 1.5, color: _textMain),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _navy),
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('عن التطبيق', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: _navy)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('دليل الجامعة الدولية الخاصة للعلوم والتكنولوجيا (IUST Guide)',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: _navy)),
              const SizedBox(height: 8),
              Text('الإصدار: 2.4.0 (إدارة الخدمات الإلكترونية)',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
              const SizedBox(height: 4),
              Text('تطبيق رسمي صادر عن الجامعة لتسهيل المعاملات والخدمات الأكاديمية والإدارية.',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textMain, height: 1.4)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _navy),
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
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
            'هل أنت متأكد أنك تريد تسجيل الخروج من واجهة الأدمن؟',
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
              child: Text('خروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // Page Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    'حسابي',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                ),
              ),

              // Profile Card
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
                          color: _navy.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar Initials
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
                            'ر',
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'الأدمن (مدير النظام)  •  ADM-018',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'مسؤولة النظام والخدمات',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Stat Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatTile(label: 'الطلبات النشطة', value: '12'),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatTile(label: 'مواعيد اليوم', value: '8'),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatTile(label: 'المعاملات المعتمدة', value: '12'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Account Information Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('معلومات الحساب'),
                      const SizedBox(height: 8),
                      _InfoGroup(items: const [
                        _InfoRow(icon: Icons.badge_outlined, label: 'الاسم الكامل', value: 'م. رنا الحسن'),
                        _InfoRow(icon: Icons.work_outline_rounded, label: 'المسمى الوظيفي', value: 'مسؤولة النظام والخدمات'),
                        _InfoRow(icon: Icons.domain_rounded, label: 'الجهة التابعة', value: 'شؤون النظام والخدمات الجامعية'),
                        _InfoRow(icon: Icons.fingerprint_rounded, label: 'الرقم الإداري', value: 'ADM-018'),
                        _InfoRow(icon: Icons.account_circle_outlined, label: 'اسم المستخدم', value: 'admin'),
                        _InfoRow(icon: Icons.email_outlined, label: 'البريد المؤسسي', value: 'rana.hassan@iust.edu.sy'),
                        _InfoRow(icon: Icons.security_rounded, label: 'نوع الصلاحية', value: 'مدير نظام كامل (Super Admin)'),
                      ]),

                      // Preferences Section
                      const SizedBox(height: 16),
                      _SectionLabel('التفضيلات'),
                      const SizedBox(height: 8),
                      _SettingsGroup(items: [
                        _SettingsItem(
                          icon: Icons.language_rounded,
                          iconBg: const Color(0xFFEDFAF1),
                          iconColor: const Color(0xFF2E9B5F),
                          label: 'لغة التطبيق',
                          trailing: _selectedLanguage,
                          onTap: _showLanguageDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.notifications_rounded,
                          iconBg: const Color(0xFFFFF8E1),
                          iconColor: const Color(0xFFD4900A),
                          label: 'الإشعارات',
                          trailing: _notificationsEnabled ? 'مفعلة' : 'متوقفة',
                          onTap: () {
                            setState(() => _notificationsEnabled = !_notificationsEnabled);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_notificationsEnabled ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        _SettingsItem(
                          icon: Icons.palette_outlined,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _blue,
                          label: 'مظهر التطبيق',
                          trailing: _currentTheme.contains('الفاتح') ? 'فاتح' : 'مخصص',
                          onTap: _showThemeDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.lock_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          label: 'تغيير كلمة المرور',
                          onTap: _showChangePasswordDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _navy,
                          label: 'إدارة الصلاحيات',
                          onTap: _showPermissionsInfoDialog,
                        ),
                      ]),

                      // Support Section
                      const SizedBox(height: 16),
                      _SectionLabel('الدعم والمساعدة'),
                      const SizedBox(height: 8),
                      _SettingsGroup(items: [
                        _SettingsItem(
                          icon: Icons.help_outline_rounded,
                          iconBg: const Color(0xFFF5F0FF),
                          iconColor: const Color(0xFF7C3AED),
                          label: 'المساعدة والدعم',
                          onTap: _showHelpDialog,
                        ),
                        _SettingsItem(
                          icon: Icons.info_outline_rounded,
                          iconBg: const Color(0xFFEAF4FB),
                          iconColor: _blue,
                          label: 'عن التطبيق',
                          trailing: 'v2.4.0',
                          onTap: _showAboutDialog,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFE53E3E), size: 18),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
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
}

// ── Shared Subcomponents Matching Student/Doctor Account Style ──────────────

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
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
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _navy,
        ),
      );
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.items});
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16, color: _border),
            ],
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _blue),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _textMain,
              ),
            ),
          ],
        ),
      );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16, color: _border),
            ],
          ],
        ),
      );
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textMain,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _textSub),
            ],
          ),
        ),
      );
}
