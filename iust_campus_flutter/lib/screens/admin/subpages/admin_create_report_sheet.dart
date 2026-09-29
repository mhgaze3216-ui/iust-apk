import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _lightBg = Color(0xFFF8F9FA);

/// Bottom sheet form for generating admin reports
class AdminCreateReportSheet extends StatefulWidget {
  const AdminCreateReportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AdminCreateReportSheet(),
    );
  }

  @override
  State<AdminCreateReportSheet> createState() => _AdminCreateReportSheetState();
}

class _AdminCreateReportSheetState extends State<AdminCreateReportSheet> {
  String _selectedType = 'المستخدمون';
  String _selectedPeriod = 'هذا الأسبوع';
  String _selectedFormat = 'PDF';
  bool _includeCharts = true;
  bool _isGenerating = false;

  final List<String> _reportTypes = [
    'المستخدمون',
    'الطلبات',
    'الخدمات',
    'القاعات',
    'الأداء',
  ];

  final List<String> _periods = [
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
    'مخصصة',
  ];

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isGenerating = false);

    final nav = Navigator.of(context);
    nav.pop();
    _showReportPreviewDialog(nav.context);
  }

  void _showReportPreviewDialog(BuildContext parentCtx) {
    showDialog<void>(
      context: parentCtx,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: _blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معاينة التقرير الإداري',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    _buildPreviewRow('نوع التقرير:', _selectedType),
                    const SizedBox(height: 6),
                    _buildPreviewRow('الفترة:', _selectedPeriod),
                    const SizedBox(height: 6),
                    _buildPreviewRow('الصيغة المعتمدة:', '$_selectedFormat (جاهز للتحميل)'),
                    const SizedBox(height: 6),
                    _buildPreviewRow('الرسوم البيانية:', _includeCharts ? 'متضمنة' : 'مستثناة'),
                    const SizedBox(height: 6),
                    _buildPreviewRow('المسؤول المصدر:', 'م. رنا الحسن (ADM-018)'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تم تجميع وتدقيق كافة المؤشرات الإحصائية ومطابقتها مع السجلات المركزية.',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(parentCtx).showSnackBar(
                  SnackBar(
                    content: Text('بدأ تحميل ملف التقرير بصيغة $_selectedFormat', style: GoogleFonts.cairo()),
                    backgroundColor: const Color(0xFF2E9B5F),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text('تحميل الملف', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
        Text(value, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 14,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إنشاء تقرير إداري',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      Text(
                        'حدد المعايير لتصدير مؤشرات المنصة الجامعية',
                        style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: _textSub),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Report Type
              Text(
                'نوع التقرير',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reportTypes.map((t) {
                  final sel = _selectedType == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedType = t),
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? _white : _textMain,
                    ),
                    selectedColor: _navy,
                    backgroundColor: _lightBg,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Period
              Text(
                'الفترة الزمنية',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _periods.map((p) {
                  final sel = _selectedPeriod == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedPeriod = p),
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? _white : _textMain,
                    ),
                    selectedColor: _blue,
                    backgroundColor: _lightBg,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Format
              Text(
                'صيغة التصدير',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['PDF', 'CSV'].map((f) {
                  final sel = _selectedFormat == f;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFormat = f),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? _navy.withValues(alpha: 0.08) : _lightBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? _navy : _border,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: sel ? _navy : _textSub,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Include charts toggle
              CheckboxListTile(
                value: _includeCharts,
                onChanged: (val) => setState(() => _includeCharts = val ?? true),
                title: Text('تضمين الرسوم البيانية الإحصائية',
                    style: GoogleFonts.cairo(fontSize: 12.5, color: _textMain)),
                activeColor: _navy,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: _white, strokeWidth: 2),
                        )
                      : Text(
                          'توليد وتصدير التقرير',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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
