import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class NewInquiryScreen extends StatefulWidget {
  final String? initialType;
  final String? initialSubject;

  const NewInquiryScreen({super.key, this.initialType, this.initialSubject});

  @override
  State<NewInquiryScreen> createState() => _NewInquiryScreenState();
}

class _NewInquiryScreenState extends State<NewInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late TextEditingController _subjectCtrl;
  final TextEditingController _contentCtrl = TextEditingController();
  String? _attachedFileName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType =
        (widget.initialType != null &&
            UniversityServicesRepository.inquiryTypes.contains(
              widget.initialType,
            ))
        ? widget.initialType!
        : UniversityServicesRepository.inquiryTypes.firstOrNull ?? '';

    _subjectCtrl = TextEditingController(text: widget.initialSubject ?? '');
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await UniversityServicesRepository.addInquiryRequest(
        type: _selectedType,
        subject: _subjectCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        attachmentName: _attachedFileName,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال استفسارك بنجاح برقم مرجعي جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إرسال الاستفسار: $error')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'استفسار جديد',
                subtitle: 'أرسل استفسارك وسنقوم بالرد عليك في أقرب وقت ممكن',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      // Instructions Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBCE0F7)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: _blue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'يرجى ملء الحقول التالية بدقة مع إمكانية إرفاق الوثائق الداعمة للطلب لتسهيل وسرعة المراجعة.',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: _navy,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Inquiry Type Dropdown
                      Text(
                        'نوع الطلب / الإدارة المختصة *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _navy,
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMain,
                            ),
                            items: UniversityServicesRepository.inquiryTypes
                                .map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                })
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedType = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subject Field
                      Text(
                        'موضوع الاستفسار *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _subjectCtrl,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى كتابة الموضوع'
                            : null,
                        decoration: InputDecoration(
                          hintText:
                              'مثال: استفسار حول معادلة مقرر أو قسط دراسي',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content Field
                      Text(
                        'نص الطلب / التفاصيل * (بحد أقصى 1000 حرف)',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contentCtrl,
                        maxLines: 5,
                        maxLength: 1000,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى كتابة تفاصيل الاستفسار'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'اكتب استفسارك بالتفصيل مع ذكر الأرقام الجامعية أو الملاحظات ذات الصلة...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Attachments Section
                      Text(
                        'المرفقات (PDF / JPG / PNG)',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () {
                          // Mock file selector options
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'اختيار مرفق تجريبي',
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _navy,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        'كشف_درجات.pdf',
                                        style: GoogleFonts.cairo(fontSize: 13),
                                      ),
                                      onTap: () {
                                        setState(
                                          () => _attachedFileName =
                                              'كشف_درجات.pdf',
                                        );
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.image_rounded,
                                        color: _blue,
                                      ),
                                      title: Text(
                                        'إشعار_سداد.jpg',
                                        style: GoogleFonts.cairo(fontSize: 13),
                                      ),
                                      onTap: () {
                                        setState(
                                          () => _attachedFileName =
                                              'إشعار_سداد.jpg',
                                        );
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.description_rounded,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        'طلب_إداري_موقع.png',
                                        style: GoogleFonts.cairo(fontSize: 13),
                                      ),
                                      onTap: () {
                                        setState(
                                          () => _attachedFileName =
                                              'طلب_إداري_موقع.png',
                                        );
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _attachedFileName != null
                                    ? Icons.check_circle_rounded
                                    : Icons.cloud_upload_outlined,
                                color: _attachedFileName != null
                                    ? const Color(0xFF16A34A)
                                    : _blue,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _attachedFileName ??
                                      'انقر لاختيار ملف مرفق (PDF / JPG / PNG)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: _attachedFileName != null
                                        ? _navy
                                        : _textSub,
                                    fontWeight: _attachedFileName != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_attachedFileName != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      setState(() => _attachedFileName = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitInquiry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'إرسال الاستفسار الآن',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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
