import 'package:flutter/material.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminCreateAnnouncementScreen extends StatefulWidget {
  const AdminCreateAnnouncementScreen({super.key});

  @override
  State<AdminCreateAnnouncementScreen> createState() =>
      _AdminCreateAnnouncementScreenState();
}

class _AdminCreateAnnouncementScreenState
    extends State<AdminCreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'التسجيل والقبول';
  String _selectedAudience = 'الكل';
  DateTime _selectedDate = DateTime.now();
  String? _attachedFileName;

  final List<String> _categories = [
    'التسجيل والقبول',
    'الامتحانات',
    'المنح',
    'النقل',
    'الخريجون',
    'إداري عام',
  ];

  final List<String> _audiences = ['الكل', 'الطلاب', 'الدكاترة', 'الموظفون'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      final dateStr =
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      try {
        await UniversityAdminRepository.addAnnouncement(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          content: _contentController.text.trim(),
          targetAudience: _selectedAudience,
          publishDate: dateStr,
          attachmentName: _attachedFileName,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر نشر الإعلان: $error')));
        return;
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نشر الإعلان بنجاح'),
          backgroundColor: Color(0xFF073B4C),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'إعلان جديد',
                subtitle: 'نشر تعميم أو خبر جديد على بوابات الجامعة',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Fields Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardCol,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Field
                              const Text(
                                'عنوان الإعلان *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'أدخل عنوان الإعلان بوضوح...',
                                  hintStyle: const TextStyle(
                                    color: textSec,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: borderCol,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: blueCol,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'الرجاء إدخال عنوان الإعلان';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Category Dropdown
                              const Text(
                                'التصنيف *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: borderCol,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                items: _categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Target Audience
                              const Text(
                                'الفئة المستهدفة *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _audiences.map((aud) {
                                  final isSelected = _selectedAudience == aud;
                                  return ChoiceChip(
                                    label: Text(aud),
                                    selected: isSelected,
                                    selectedColor: lightBlue,
                                    labelStyle: TextStyle(
                                      color: isSelected ? blueCol : textSec,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12.5,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? blueCol : borderCol,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedAudience = aud);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Content Field
                              const Text(
                                'نص الإعلان *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _contentController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: 'اكتب نص الإعلان والتعليمات والتفاصيل هنا...',
                                  hintStyle: const TextStyle(
                                    color: textSec,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: borderCol,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: blueCol,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'الرجاء كتابة نص الإعلان';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Date Selection
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'تاريخ النشر',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: textMain,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () async {
                                            final d = await showDatePicker(
                                              context: context,
                                              initialDate: _selectedDate,
                                              firstDate: DateTime.now()
                                                  .subtract(
                                                    const Duration(days: 30),
                                                  ),
                                              lastDate: DateTime.now().add(
                                                const Duration(days: 180),
                                              ),
                                            );
                                            if (d != null) {
                                              setState(() => _selectedDate = d);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: borderCol,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 16,
                                                  color: blueCol,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: textMain,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Attachment (Optional)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgCol,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderCol),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file_rounded,
                                      color: blueCol,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _attachedFileName ??
                                            'إرفاق ملف أو تعميم (اختياري)',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: _attachedFileName != null
                                              ? textMain
                                              : textSec,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _attachedFileName =
                                              _attachedFileName == null
                                              ? 'التعميم_الرسمي_المعتمد.pdf'
                                              : null;
                                        });
                                      },
                                      child: Text(
                                        _attachedFileName == null
                                            ? 'إرفاق'
                                            : 'إزالة',
                                        style: TextStyle(
                                          color: _attachedFileName == null
                                              ? blueCol
                                              : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Publish Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navyCol,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _submitAnnouncement,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              'نشر الإعلان',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
