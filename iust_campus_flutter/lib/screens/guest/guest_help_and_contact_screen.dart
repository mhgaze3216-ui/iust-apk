import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../guest_inquiry_screen.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class GuestHelpAndContactScreen extends StatefulWidget {
  const GuestHelpAndContactScreen({super.key});

  @override
  State<GuestHelpAndContactScreen> createState() => _GuestHelpAndContactScreenState();
}

class _GuestHelpAndContactScreenState extends State<GuestHelpAndContactScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  static const _categories = [
    'الكل',
    'القبول والتسجيل',
    'الكليات والتخصصات',
    'الوثائق المطلوبة',
    'الرسوم والمنح',
    'النقل الجامعي',
    'أوقات الدوام',
    'موقع الجامعة',
    'الحساب والتطبيق',
  ];

  static const List<_FaqItem> _allFaqs = [
    _FaqItem(
      category: 'القبول والتسجيل',
      question: 'ما هي شروط القبول والتسجيل في الجامعة الدولية (IUST)؟',
      answer: 'يعتمد القبول على الشهادة الثانوية العامة السورية أو ما يعادلها المعتمدة من وزارة التعليم العالي، وبحسب مفاضلة الكليات والحدود الدنيا المعلنة للدرجات لكل فصل دراسي.',
    ),
    _FaqItem(
      category: 'القبول والتسجيل',
      question: 'هل يمكن التحويل من جامعة أخرى إلى الجامعة الدولية؟',
      answer: 'نعم، يُقبل التحويل المماثل من الجامعات المعترف بها وفق الشروط المعتمدة ومعادلة المقررات التي تم اجتيازها بنجاح بما يتوافق مع الخطة الدراسية.',
    ),
    _FaqItem(
      category: 'الكليات والتخصصات',
      question: 'ما هي الكليات المتاحة داخل الحرم الجامعي؟',
      answer: 'تضم الجامعة 6 كليات رئيسية: كلية طب الأسنان، كلية الصيدلة، كلية الهندسة وتكنولوجيا المعلومات، كلية إدارة الأعمال، كلية الهندسة المعمارية والتصميم، وكلية الآداب والعلوم.',
    ),
    _FaqItem(
      category: 'الكليات والتخصصات',
      question: 'ما هي لغات التدريس المعتمدة في المقررات؟',
      answer: 'تُعتمد اللغتان الإنجليزية والعربية في التدريس والمراجع الأكاديمية بحسب متطلبات البرامج الأكاديمية والخطط المعتمدة من مجلس التعليم العالي.',
    ),
    _FaqItem(
      category: 'الوثائق المطلوبة',
      question: 'ما هي المستندات المطلوبة للطلاب المستجدين؟',
      answer: 'الشهادة الثانوية الأصلية مصدقة مع 3 صور مصدقة، صورة عن الهوية الشخصية أو جواز السفر، 6 صور شخصية ملونة، وثيقة التجنيد للذكور السوريين، واستمارة طلب التسجيل.',
    ),
    _FaqItem(
      category: 'الوثائق المطلوبة',
      question: 'ما هي وثائق الطلاب المحولين من جامعات أخرى؟',
      answer: 'كشف علامات أصلي ومصدق من الجامعة السابقة، والتوصيف الدراسي المفصل للمقررات المراد معادلتها، بالإضافة إلى وثائق الثانوية العامة الرسمية.',
    ),
    _FaqItem(
      category: 'الرسوم والمنح',
      question: 'هل تقدم الجامعة منحاً دراسية وتخفيضات؟',
      answer: 'نعم، تقدم الجامعة منح التفوق الدراسي الفصلي، وتخفيضات للأخوة المسجلين معاً، ومنح أبناء الشهداء، ومنح حفظة القرآن الكريم وفق معايير مجلس الأمناء.',
    ),
    _FaqItem(
      category: 'الرسوم والمنح',
      question: 'كيف يتم سداد الرسوم الجامعية؟',
      answer: 'يتم تسديد الرسوم الجامعية لكل فصل دراسي عبر الحسابات المصرفية المعتمدة للجامعة أو وسائل الدفع الإلكتروني وفق المواعيد المحددة في التقويم المالي.',
    ),
    _FaqItem(
      category: 'النقل الجامعي',
      question: 'هل يتوفر نقل جامعي للطلاب والزوار؟',
      answer: 'نعم، توفر الجامعة أسطول حافلات حديث يغطي دمشق وريفها ومناطق درعا والسويداء والقنيطرة برحلات صباحية ومسائية مجدولة بدقة.',
    ),
    _FaqItem(
      category: 'النقل الجامعي',
      question: 'كيف يمكن الاشتراك في خدمة حافلات الجامعة؟',
      answer: 'يتم الاشتراك عبر مكتب النقل في مبنى الإدارة العامة في بداية كل فصل دراسي مع تحديد نقطة الانطلاق والعودة المناسبة.',
    ),
    _FaqItem(
      category: 'أوقات الدوام',
      question: 'ما هي أيام وأوقات الدوام الرسمي في الجامعة؟',
      answer: 'يبدأ الدوام الإداري والأكاديمي من يوم السبت حتى الأربعاء من الساعة 8:30 صباحاً وحتى الساعة 4:00 مساءً، وتكون العطلة الأسبوعية يومي الخميس والجمعة.',
    ),
    _FaqItem(
      category: 'موقع الجامعة',
      question: 'أين يقع الحرم الجامعي للجامعة الدولية؟',
      answer: 'يقع الحرم الجامعي الرئيسي على أوتوستراد دمشق - درعا الدولي (منطقة غباغب)، ويبعد حوالي 30 دقيقة عن دمشق، ويتوفر في التطبيق خريطة تفاعلية كاملة للحرم.',
    ),
    _FaqItem(
      category: 'الحساب والتطبيق',
      question: 'هل يمكن استخدام التطبيق كزائر بدون حساب مسجل؟',
      answer: 'نعم، يتيح وضع الزائر تصفح الكليات، الخريطة التفاعلية، المستندات، المنح، والرسوم، وتقديم استفسارات مباشرة للإدارة دون الحاجة لتسجيل دخول.',
    ),
    _FaqItem(
      category: 'الحساب والتطبيق',
      question: 'كيف يحصل الطالب أو الأستاذ على حسابه الرسمي؟',
      answer: 'يتم تزويد الطالب المسجل وأعضاء الهيئة التدريسية ببيانات الدخول الرسمية فور إتمام التسجيل الأكاديمي من قِبل دائرة تكنولوجيا المعلومات.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    return _allFaqs.where((faq) {
      final matchesCategory = _selectedCategory == 'الكل' || faq.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q) ||
          faq.category.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;

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
                'الأسئلة والتواصل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              Text(
                'ابحث عن إجابة أو تواصل مع إدارة الجامعة',
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _border),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── Section 1: تواصل مع الإدارة ───────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_navy, _blue],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mark_chat_unread_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تواصل مع الإدارة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'أرسل استفسارك إلى الجهة الإدارية المختصة',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuestInquiryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        'إرسال استفسار جديد',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 2: الأسئلة الشائعة ─────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: _blue, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'الأسئلة الشائعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search Bar
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                decoration: InputDecoration(
                  hintText: 'ابحث في الأسئلة والإجابات...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _textSub),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: _textSub),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categories Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? _navy : _white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _navy : _border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : _textMain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // FAQs List
            if (faqs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: _textSub),
                    const SizedBox(height: 10),
                    Text(
                      'لم يتم العثور على نتائج مطابقة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جرب كلمات بحث أخرى أو تواصل مباشرة مع الإدارة.',
                      style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...faqs.map((f) => _buildFaqCard(f)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(_FaqItem f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: _navy,
          collapsedIconColor: _textSub,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  f.category,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  f.question,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEF3F6)),
              ),
              child: Text(
                f.answer,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: _textSub,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
