import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityFaqScreen extends StatefulWidget {
  const UniversityFaqScreen({super.key});

  @override
  State<UniversityFaqScreen> createState() => _UniversityFaqScreenState();
}

class _UniversityFaqScreenState extends State<UniversityFaqScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'الكل';

  static const List<String> _categories = [
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
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    final query = _searchCtrl.text.trim().toLowerCase();
    return UniversityServicesRepository.faqs.where((faq) {
      final matchesCat = _selectedCategory == 'الكل' || faq.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredFaqs;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'الأسئلة الشائعة',
                subtitle: 'إجابات سريعة لأكثر الاستفسارات شيوعاً',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              // Search Input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                    decoration: InputDecoration(
                      hintText: 'ابحث هنا...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      prefixIcon: const Icon(Icons.search_rounded, color: _blue, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: _textSub),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Categories Chips
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;

                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? _navy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? _navy : _border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : _textMain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Questions List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.help_outline_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'لم يتم العثور على إجابات تطابق بحثك',
                              style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = list[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF4FB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.help_center_outlined, color: _blue, size: 18),
                                ),
                                title: Text(
                                  item.question,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    item.category,
                                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F9FC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.answer,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        color: _textMain,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
