import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  bool _darkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        safeDoctorPop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          centerTitle: true,
          leading: const DoctorBackButton(),
        title: Text(
          'الإعدادات العامة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _textMain,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('المظهر والعرض'),
            const SizedBox(height: 8),
            _buildCard([
              _buildSwitchRow(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع الداكن',
                subtitle: 'تفعيل المظهر الليلي',
                value: _darkMode,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val ? 'تم تفعيل الوضع الداكن' : 'تم تفعيل الوضع الفاتح',
                        style: GoogleFonts.cairo(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: _border, indent: 56),
              _buildActionRow(
                icon: Icons.language_outlined,
                title: 'لغة التطبيق',
                value: _selectedLanguage,
                onTap: () => _selectLanguage(context),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader('الصوت والاهتزاز'),
            const SizedBox(height: 8),
            _buildCard([
              _buildSwitchRow(
                icon: Icons.volume_up_outlined,
                title: 'أصوات التنبيهات',
                subtitle: 'تشغيل نغمة عند ورود إشعار جديد',
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
              ),
              const Divider(height: 1, color: _border, indent: 56),
              _buildSwitchRow(
                icon: Icons.vibration_rounded,
                title: 'الاهتزاز',
                subtitle: 'اهتزاز الجهاز مع التنبيهات المهمة',
                value: _vibrationEnabled,
                onChanged: (val) => setState(() => _vibrationEnabled = val),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionHeader('التخزين والبيانات'),
            const SizedBox(height: 8),
            _buildCard([
              _buildActionRow(
                icon: Icons.cleaning_services_outlined,
                title: 'مسح الذاكرة المؤقتة (Cache)',
                value: '14.2 MB',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تفريغ الذاكرة المؤقتة بنجاح', style: GoogleFonts.cairo()),
                      backgroundColor: const Color(0xFF2E9B5F),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }

  void _selectLanguage(BuildContext context) {
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _textSub,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textMain,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                ),
              ],
            ),
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

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _blue, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textMain,
                ),
              ),
            ),
            Text(value, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
          ],
        ),
      ),
    );
  }
}
