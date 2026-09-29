import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  final Map<String, List<({String key, String title, String subtitle, bool enabled})>> _rolesPermissions = {
    'إدارة الطلاب': [
      (key: 'student_portal', title: 'الوصول إلى البوابة الجامعية', subtitle: 'تسجيل الدخول واستعراض البيانات', enabled: true),
      (key: 'course_registration', title: 'تسجيل المقررات إلكترونياً', subtitle: 'إضافة وإسقاط المواد خلال فترة التثبيت', enabled: true),
      (key: 'grade_view', title: 'الاطلاع على كشوف العلامات', subtitle: 'عرض نتائج الفصول والمعدل التراكمي', enabled: true),
      (key: 'objection_submit', title: 'تقديم طلبات الاعتراض', subtitle: 'رفع اعتراضات الامتحانات إلكترونياً', enabled: true),
    ],
    'إدارة الهيئة التدريسية': [
      (key: 'grades_entry', title: 'رصد العلامات والنتائج', subtitle: 'إدخال درجات الأعمال والامتحانات', enabled: true),
      (key: 'attendance_tracking', title: 'تسجيل وتدقيق الحضور والغياب', subtitle: 'إدارة قوائم الحضور وحرمان الغياب', enabled: true),
      (key: 'announcement_post', title: 'نشر إعلانات المقررات', subtitle: 'إرسال تعميمات للطلاب المسجلين بالشعبة', enabled: true),
      (key: 'template_upload', title: 'رفع النماذج الامتحانية', subtitle: 'تقديم مسودات الامتحانات لرئاسة القسم', enabled: true),
    ],
    'إدارة النظام والخدمات': [
      (key: 'user_management', title: 'إنشاء وتعديل الحسابات', subtitle: 'إدارة وتفعيل وتجميد حسابات المنظومة', enabled: true),
      (key: 'tickets_response', title: 'البت في المعاملات والطلبات', subtitle: 'اعتماد ونقل الشعب والاعتراضات', enabled: true),
      (key: 'reports_export', title: 'تصدير التقارير الإدارية', subtitle: 'تحميل كشوفات الأداء ومعدلات الاستخدام', enabled: true),
      (key: 'system_backup', title: 'إدارة النسخ الاحتياطي', subtitle: 'تشغيل وتحديث قواعد البيانات المركزية', enabled: true),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        appBar: AdminHeader(
          showBackButton: true,
          showNotificationBell: false,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'إدارة الصلاحيات والأدوار',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تحديد مستويات الوصول والأذونات للمجموعات المختلفة على المنظومة.',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: _textSub,
                ),
              ),
              const SizedBox(height: 16),

              ..._rolesPermissions.entries.map((entry) {
                final groupName = entry.key;
                final perms = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(perms.length, (idx) {
                            final p = perms[idx];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.title,
                                              style: GoogleFonts.cairo(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: _textMain,
                                              ),
                                            ),
                                            Text(
                                              p.subtitle,
                                              style: GoogleFonts.cairo(
                                                fontSize: 11.5,
                                                color: _textSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: p.enabled,
                                        activeThumbColor: _blue,
                                        onChanged: (val) {
                                          setState(() {
                                            perms[idx] = (
                                              key: p.key,
                                              title: p.title,
                                              subtitle: p.subtitle,
                                              enabled: val,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (idx < perms.length - 1)
                                  const Divider(height: 1, color: _border, indent: 14, endIndent: 14),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حفظ وتطبيق تحديثات الصلاحيات بنجاح', style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFF2E9B5F),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).maybePop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ],
          ),
        ),
      ),
    );
  }
}
