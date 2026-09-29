import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/admin_demo_data.dart';
import '../widgets/admin_header.dart';

const _navy = Color(0xFF073B4C);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminSystemDetailsScreen extends StatelessWidget {
  const AdminSystemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: const AdminHeader(showBackButton: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            Text(
              'تفاصيل وحالة النظام (DEMO)',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'معلومات الخوادم، النسخ الاحتياطي، ومؤشرات الجاهزية السحابية',
              style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
            ),
            const SizedBox(height: 16),

            // Backup Status Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDFAF1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9B5F).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_done_rounded,
                      color: Color(0xFF2E9B5F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نسخة احتياطية ناجحة',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AdminDemoData.lastBackupText,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: const Color(0xFF14532D),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Server Specs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مواصفات الخادم المركزي',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRow('الخادم النشط', AdminDemoData.backupServerName),
                  const Divider(height: 18, color: _border),
                  _buildRow('حجم قاعدة البيانات', AdminDemoData.backupDatabaseSize),
                  const Divider(height: 18, color: _border),
                  _buildRow('معدل الاستجابة', '42 ms (طبيعي)'),
                  const Divider(height: 18, color: _border),
                  _buildRow('التوفر السنوي', '99.94% SLA'),
                  const Divider(height: 18, color: _border),
                  _buildRow('تشفير البيانات', 'AES-256 (مفعل)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Manual Backup Trigger
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العمليات الإدارية الفورية',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم بدء النسخ الاحتياطي اليدوي لقاعدة البيانات بنجاح (محاكاة)',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: _navy,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.backup_rounded, size: 18),
                    label: Text(
                      'أخذ نسخة احتياطية فورية الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 12.5, color: _textSub)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
