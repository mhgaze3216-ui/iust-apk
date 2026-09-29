import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_archive_repository.dart';
import '../../models/doctor_models.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';
import 'doctor_midterm_template_screen.dart';
import 'doctor_final_exam_template_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

/// Dedicated screen for on-demand inspection of ONE document or archive record.
/// Loads only the targeted document when opened, with zero preloading of other items.
class DoctorDocumentPreviewScreen extends StatefulWidget {
  final DoctorArchiveItem documentItem;

  const DoctorDocumentPreviewScreen({
    super.key,
    required this.documentItem,
  });

  @override
  State<DoctorDocumentPreviewScreen> createState() =>
      _DoctorDocumentPreviewScreenState();
}

class _DoctorDocumentPreviewScreenState
    extends State<DoctorDocumentPreviewScreen> {
  bool _isLoading = true;
  DoctorArchiveItem? _loadedItem;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSingleDocument();
  }

  Future<void> _loadSingleDocument() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Lazy on-demand loading of ONLY the selected document
      final item = await DoctorArchiveRepository.loadDocumentById(widget.documentItem.id);
      if (mounted) {
        setState(() {
          _loadedItem = item ?? widget.documentItem;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _loadedItem ?? widget.documentItem;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: DoctorPageHeader(
          title: 'معاينة المستند',
          subtitle: item.title,
          showBackButton: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: _navy),
                      SizedBox(height: 14),
                      Text(
                        'جاري فتح بيانات المستند...',
                        style: TextStyle(
                          
                          fontSize: 13,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                )
              : _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: Color(0xFFE74C3C)),
                          const SizedBox(height: 12),
                          Text(
                            'تعذر تحميل بيانات المستند',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _loadSingleDocument,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text('إعادة المحاولة',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: _white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      children: [
                        // ── Overview Card ──
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _navy.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: _navy,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.cairo(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: _textMain,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'المقرر: ${item.courseName}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.5,
                                            color: _blue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.statusColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: item.statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: _border),
                              const SizedBox(height: 14),
                              _buildMetaRow(
                                  Icons.calendar_month_outlined,
                                  'الفصل الدراسي',
                                  item.semester),
                              const SizedBox(height: 8),
                              _buildMetaRow(
                                  Icons.access_time_rounded,
                                  'تاريخ الأرشفة',
                                  item.date),
                              const SizedBox(height: 8),
                              _buildMetaRow(
                                  Icons.category_outlined,
                                  'نوع الوثيقة',
                                  item.documentType),
                              if (item.fileSize != null) ...[
                                const SizedBox(height: 8),
                                _buildMetaRow(
                                    Icons.data_usage_rounded,
                                    'حجم الملف التقديري',
                                    item.fileSize!),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── File Content / Attachment Status ──
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حالة الملف المرفق',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _textMain,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (item.filePath == null)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        color: _textSub,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'لا يوجد ملف مرفق حالياً',
                                              style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: _textMain,
                                              ),
                                            ),
                                            Text(
                                              'تم حفظ بيانات الوثيقة والاعتماد الأكاديمي كبيانات وصفية فقط دون ملف محلي.',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: _textSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf_rounded,
                                        color: Color(0xFFE74C3C), size: 24),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.filePath!,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: _navy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // ── Notes / Academic Details ──
                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                                  'الملاحظات والاعتمادات',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: _textMain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.notes!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    color: _textSub,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── Template Preview Shortcut if Applicable ──
                        if (item.documentType.contains('امتحان')) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => item.documentType.contains('نصفي')
                                        ? const DoctorMidtermTemplateScreen()
                                        : const DoctorFinalExamTemplateScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.menu_book_rounded, size: 18),
                              label: Text(
                                'معاينة ورقة أسئلة الامتحان الكاملة',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: _white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textSub),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: _textSub,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: _textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
