import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_chat_service.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class GuestInquiryScreen extends StatefulWidget {
  final String? initialCategory;

  const GuestInquiryScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<GuestInquiryScreen> createState() => _GuestInquiryScreenState();
}

class _GuestInquiryScreenState extends State<GuestInquiryScreen> {
  static const _categories = [
    'القبول والتسجيل',
    'شؤون الطلاب',
    'الرسوم والمنح',
    'الوثائق',
    'النقل الجامعي',
    'الدعم التقني',
    'استفسار عام',
  ];

  late String _selectedCategory;
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl     = TextEditingController();

  String? _attachedFileName;
  bool _sending = false;
  String? _submittedRefId;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null &&
        _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    } else {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _pickMockAttachment() {
    setState(() {
      if (_attachedFileName == null) {
        _attachedFileName = 'document_inquiry_attachment.pdf';
      } else {
        _attachedFileName = null;
      }
    });
  }

  Future<void> _submit() async {
    final subject = _subjectCtrl.text.trim();
    final message = _msgCtrl.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال الموضوع ونص الاستفسار للمتابعة.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 550));

    final inq = MockChatService.submitInquiry(
      category: _selectedCategory,
      guestName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      subject: subject,
      message: message,
      attachmentName: _attachedFileName,
    );

    if (mounted) {
      setState(() {
        _sending = false;
        _submittedRefId = inq.inquiryId;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _subjectCtrl.clear();
      _msgCtrl.clear();
      _attachedFileName = null;
      _submittedRefId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تواصل مع الإدارة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              Text(
                'أرسل استفسارك إلى الجهة الإدارية المختصة',
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _border),
          ),
        ),
        body: _submittedRefId != null
            ? _SuccessView(
                refId: _submittedRefId!,
                onNewInquiry: _resetForm,
                onBack: () => Navigator.maybePop(context),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_navy, _blue],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نموذج الاستفسار الإداري',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'لا يشترط تسجيل الدخول. سيتم الرد على استفسارك ومتابعته محلياً.',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // نوع الاستفسار Dropdown
                    _fieldLabel('نوع الاستفسار *'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _navy),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textMain,
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الاسم (optional)
                    _fieldLabel('الاسم الكامل (اختياري)'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _nameCtrl,
                      hint: 'مثال: أحمد العلي',
                    ),
                    const SizedBox(height: 14),

                    // البريد الإلكتروني (optional)
                    _fieldLabel('البريد الإلكتروني (اختياري)'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _emailCtrl,
                      hint: 'example@domain.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // رقم الهاتف (optional)
                    _fieldLabel('رقم الهاتف (اختياري)'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _phoneCtrl,
                      hint: '09xxxxxxxx',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    // الموضوع (required)
                    _fieldLabel('الموضوع *'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _subjectCtrl,
                      hint: 'عنوان موجز للاستفسار',
                    ),
                    const SizedBox(height: 14),

                    // نص الاستفسار (required)
                    _fieldLabel('نص الاستفسار *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _msgCtrl,
                      textDirection: TextDirection.rtl,
                      maxLines: 5,
                      style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                      decoration: InputDecoration(
                        hintText: 'اكتب تفاصيل استفسارك أو طلبك هنا...',
                        hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _blue, width: 1.5),
                        ),
                        filled: true,
                        fillColor: _white,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // مرفق (optional)
                    _fieldLabel('مرفق توضيحي (اختياري)'),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickMockAttachment,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _attachedFileName != null ? _lightBlue : _white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _attachedFileName != null ? _blue : _border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _attachedFileName != null
                                  ? Icons.check_circle_rounded
                                  : Icons.attach_file_rounded,
                              color: _attachedFileName != null ? _blue : _textSub,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _attachedFileName ?? 'إرفاق ملف أو صورة من الجهاز (PDF/JPG)',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  color: _attachedFileName != null ? _navy : _textSub,
                                  fontWeight: _attachedFileName != null
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_attachedFileName != null)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: _textSub),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() => _attachedFileName = null);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // زر الإرسال
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'إرسال الاستفسار',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
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

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String refId;
  final VoidCallback onNewInquiry;
  final VoidCallback onBack;

  const _SuccessView({
    required this.refId,
    required this.onNewInquiry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFAF1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E9B5F),
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'تم إرسال استفسارك بنجاح',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'تم تسجيل طلبك وسيقوم الكادر المختص بمراجعته والتواصل معك.',
                style: GoogleFonts.cairo(fontSize: 13, color: _textSub, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _blue.withValues(alpha: 0.3)),
                ),
                child: Text.rich(
                  TextSpan(
                    text: 'الرقم المرجعي: ',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: _textSub,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: refId,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNewInquiry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _navy,
                        side: const BorderSide(color: _navy),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'استفسار آخر',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'العودة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
