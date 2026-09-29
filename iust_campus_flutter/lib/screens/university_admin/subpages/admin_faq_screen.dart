import 'package:flutter/material.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminFaqScreen extends StatefulWidget {
  const AdminFaqScreen({super.key});

  @override
  State<AdminFaqScreen> createState() => _AdminFaqScreenState();
}

class _AdminFaqScreenState extends State<AdminFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'التسجيل والفصل',
    'استخراج الوثائق',
    'الاعتراض على العلامات',
    'المنح والرسوم',
    'المواعيد الإدارية',
    'النقل الجامعي',
    'البريد الجامعي',
    'الخدمات الطلابية',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminFaqModel> get _filteredFaqs {
    return UniversityAdminRepository.faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'الكل' || faq.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (_searchQuery.isEmpty) return true;
      return faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showAddFaqDialog() {
    final questionCtrl = TextEditingController();
    final answerCtrl = TextEditingController();
    String category = _selectedCategory == 'الكل'
        ? 'التسجيل والفصل'
        : _selectedCategory;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'إضافة سؤال شائع جديد',
              style: TextStyle(
                color: Color(0xFF073B4C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التصنيف:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: _categories.where((c) => c != 'الكل').map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'نص السؤال:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: questionCtrl,
                    decoration: InputDecoration(
                      hintText: 'اكتب السؤال هنا...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الإجابة المعتمدة:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: answerCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اكتب تفاصيل الإجابة هنا...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Color(0xFF6F7F89)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073B4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (questionCtrl.text.trim().isNotEmpty &&
                      answerCtrl.text.trim().isNotEmpty) {
                    try {
                      await UniversityAdminRepository.addFaq(
                        category: category,
                        question: questionCtrl.text.trim(),
                        answer: answerCtrl.text.trim(),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تعذر إضافة السؤال: $error')),
                      );
                      return;
                    }
                    if (!mounted || !dialogCtx.mounted) return;
                    setState(() {});
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تمت إضافة السؤال بنجاح'),
                        backgroundColor: Color(0xFF073B4C),
                      ),
                    );
                  }
                },
                child: const Text(
                  'إضافة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFaqDialog(AdminFaqModel faq) {
    final questionCtrl = TextEditingController(text: faq.question);
    final answerCtrl = TextEditingController(text: faq.answer);

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تعديل السؤال الشائع',
            style: TextStyle(
              color: Color(0xFF073B4C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'السؤال:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: questionCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'الإجابة:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: answerCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Color(0xFF6F7F89)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF073B4C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await UniversityAdminRepository.updateFaq(
                    id: faq.id,
                    question: questionCtrl.text.trim(),
                    answer: answerCtrl.text.trim(),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر تحديث السؤال: $error')),
                  );
                  return;
                }
                if (!mounted || !dialogCtx.mounted) return;
                setState(() {});
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث السؤال بنجاح'),
                    backgroundColor: Color(0xFF073B4C),
                  ),
                );
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFaq(AdminFaqModel faq) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا السؤال؟\n"${faq.question}"',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Color(0xFF6F7F89)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await UniversityAdminRepository.deleteFaq(faq.id);
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر حذف السؤال: $error')),
                  );
                  return;
                }
                if (!mounted || !dialogCtx.mounted) return;
                setState(() {});
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف السؤال بنجاح'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFaqVisibility(AdminFaqModel faq) async {
    try {
      await UniversityAdminRepository.updateFaq(
        id: faq.id,
        isVisible: !faq.isVisible,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث ظهور السؤال: $error')));
      return;
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          faq.isVisible
              ? 'تم إظهار السؤال للمستخدمين'
              : 'تم إخفاء السؤال عن المستخدمين',
        ),
        backgroundColor: const Color(0xFF073B4C),
        duration: const Duration(seconds: 1),
      ),
    );
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

    final items = _filteredFaqs;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'الأسئلة الشائعة',
                subtitle: 'إدارة الأسئلة المتكررة وإجاباتها الرسمية للمستخدمين',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),

              // Search bar and Add button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: cardCol,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'ابحث هنا...',
                            hintStyle: const TextStyle(
                              color: textSec,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: textSec,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: textSec,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navyCol,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      onPressed: _showAddFaqDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'إضافة سؤال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Chips List
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: lightBlue,
                      backgroundColor: cardCol,
                      labelStyle: TextStyle(
                        color: isSelected ? blueCol : textSec,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: isSelected ? blueCol : borderCol),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // FAQ List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد أسئلة مطابقة للبحث أو التصنيف',
                              style: TextStyle(color: textSec, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (ctx, idx) {
                          final faq = items[idx];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardCol,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderCol),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightBlue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        faq.category,
                                        style: const TextStyle(
                                          color: blueCol,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: faq.isVisible
                                            ? const Color(0xFFEDFAF1)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        faq.isVisible ? 'معروض' : 'مخفي',
                                        style: TextStyle(
                                          color: faq.isVisible
                                              ? const Color(0xFF16A34A)
                                              : Colors.grey.shade600,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  faq.question,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  faq.answer,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: textSec,
                                    height: 1.45,
                                  ),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Toggle visibility
                                    TextButton.icon(
                                      onPressed: () =>
                                          _toggleFaqVisibility(faq),
                                      icon: Icon(
                                        faq.isVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                      label: Text(
                                        faq.isVisible ? 'إخفاء' : 'إظهار',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    // Edit
                                    TextButton.icon(
                                      onPressed: () => _showEditFaqDialog(faq),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'تعديل',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    // Delete
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFDC2626,
                                        ),
                                      ),
                                      onPressed: () => _confirmDeleteFaq(faq),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'حذف',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
