import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'widgets/doctor_back_button.dart';
import 'widgets/doctor_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

enum CommunityPostType {
  announcement,
  question,
  resource,
}

class CommunityPostItem {
  final String id;
  final CommunityPostType type;
  final String title;
  final String content;
  final String author;
  final String role;
  final String time;
  final String courseName;
  final int repliesCount;
  final bool isAnswered;
  final String? doctorReply;

  const CommunityPostItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.author,
    required this.role,
    required this.time,
    required this.courseName,
    required this.repliesCount,
    this.isAnswered = false,
    this.doctorReply,
  });

  CommunityPostItem copyWith({
    String? doctorReply,
    bool? isAnswered,
    int? repliesCount,
  }) {
    return CommunityPostItem(
      id: id,
      type: type,
      title: title,
      content: content,
      author: author,
      role: role,
      time: time,
      courseName: courseName,
      repliesCount: repliesCount ?? this.repliesCount,
      isAnswered: isAnswered ?? this.isAnswered,
      doctorReply: doctorReply ?? this.doctorReply,
    );
  }
}

class DoctorCommunityScreen extends StatefulWidget {
  final bool showBack;
  const DoctorCommunityScreen({super.key, this.showBack = false});

  @override
  State<DoctorCommunityScreen> createState() => _DoctorCommunityScreenState();
}

class _DoctorCommunityScreenState extends State<DoctorCommunityScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = [
    'الكل (5)',
    'إعلانات المقررات (2)',
    'الاستفسارات والنقاشات (2)',
    'المصادر والتوجيهات (1)',
  ];

  late List<CommunityPostItem> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      const CommunityPostItem(
        id: 'post-001',
        type: CommunityPostType.announcement,
        title: 'تذكير بموعد تسليم الوظيفة الأولى — معالج دقيق',
        content:
            'نذكر طلاب الشعبة 1 بأن الموعد النهائي لتسليم حل تمارين مسجلات المعالج 8086 هو يوم السبت القادم قبل الساعة 23:59 عبر بوابة التسليم.',
        author: 'د. محمد مازن محايري',
        role: 'أستاذ المقرر',
        time: 'منذ ساعتين',
        courseName: 'معالج دقيق · الشعبة 1',
        repliesCount: 4,
      ),
      const CommunityPostItem(
        id: 'post-002',
        type: CommunityPostType.question,
        title: 'استفسار حول آلية عمل المسجل AX وطرق العنونة غير المباشرة',
        content:
            'دكتور، هل يمكن استخدام المسجل BP كمسجل قاعدة مع إزاحة سالبة في تعليمات نقل البيانات؟',
        author: 'حمزة السعدي',
        role: 'طالب · الشعبة 1',
        time: 'منذ 4 ساعات',
        courseName: 'معالج دقيق',
        repliesCount: 1,
        isAnswered: true,
        doctorReply:
            'نعم يا حمزة، المسجل BP مخصص للتعامل مع المقطع SS ويدعم الإزاحات الموجبة والسالبة بالنسبة لمؤشر القاعدة.',
      ),
      const CommunityPostItem(
        id: 'post-003',
        type: CommunityPostType.announcement,
        title: 'جلسة مراجعة إضافية لمقرر الاحتمالات والإشارات العشوائية',
        content:
            'ستعقد جلسة إضافية لشرح مسائل المتغيرات العشوائية المستمرة وتوزيع غاوس في القاعة 204 يوم السبت القادم من 13:00 حتى 14:00.',
        author: 'د. محمد مازن محايري',
        role: 'أستاذ المقرر',
        time: 'منذ يوم',
        courseName: 'الاحتمالات والإشارات · الشعبة 2',
        repliesCount: 6,
      ),
      const CommunityPostItem(
        id: 'post-004',
        type: CommunityPostType.question,
        title: 'سؤال عن حساب التباين لمتغيرين عشوائيين مستقلين',
        content:
            'هل شرط الاستقلال كافٍ ليصبح التغاير Cov(X,Y) = 0، وهل العكس صحيح دائماً؟',
        author: 'نائلة الحمد',
        role: 'طالبة · الشعبة 2',
        time: 'منذ يومين',
        courseName: 'الاحتمالات والإشارات',
        repliesCount: 0,
        isAnswered: false,
      ),
      const CommunityPostItem(
        id: 'post-005',
        type: CommunityPostType.resource,
        title: 'السلايدات المعتمدة: بنية المقاطعات ومنظومة المعالج 8086',
        content:
            'تم رفع ملف العرض التقديمي للمحاضرة الثالثة بصيغة PDF يتضمن أمثلة عملية حول مقاطعات BIOS و DOS.',
        author: 'د. محمد مازن محايري',
        role: 'أستاذ المقرر',
        time: 'منذ 3 أيام',
        courseName: 'معالج دقيق · ملف تعليمي مرفق',
        repliesCount: 2,
      ),
    ];
  }

  void _showNewPostSheet({required bool isAnnouncement}) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCourse = 'معالج دقيق · الشعبة 1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                isAnnouncement
                                    ? Icons.campaign_rounded
                                    : Icons.forum_rounded,
                                color: isAnnouncement ? _navy : _blue,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isAnnouncement ? 'نشر إعلان أكاديمي جديد' : 'طرح موضوع نقاش جديد',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _textMain,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: _textSub),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  const Divider(color: _border),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourse,
                    decoration: InputDecoration(
                      labelText: 'المقرر والشعبة',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'معالج دقيق · الشعبة 1',
                        child: Text('معالج دقيق · الشعبة 1'),
                      ),
                      DropdownMenuItem(
                        value: 'الاحتمالات والإشارات · الشعبة 2',
                        child: Text('الاحتمالات والإشارات · الشعبة 2'),
                      ),
                      DropdownMenuItem(
                        value: 'كافة الشعب والمقررات',
                        child: Text('كافة الشعب والمقررات'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedCourse = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.cairo(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'عنوان الموضوع أو الإعلان',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    style: GoogleFonts.cairo(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: isAnnouncement
                          ? 'نص الإعلان والتعليمات للطلاب...'
                          : 'محتوى المناقشة والشرح الأكاديمي...',
                      labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) return;

                      setState(() {
                        _posts.insert(
                          0,
                          CommunityPostItem(
                            id: 'post-${DateTime.now().millisecondsSinceEpoch}',
                            type: isAnnouncement
                                ? CommunityPostType.announcement
                                : CommunityPostType.question,
                            title: title,
                            content: content,
                            author: 'د. محمد مازن محايري',
                            role: 'أستاذ المقرر',
                            time: 'الآن',
                            courseName: selectedCourse,
                            repliesCount: 0,
                          ),
                        );
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAnnouncement
                                ? 'تم نشر الإعلان الأكاديمي بنجاح لجميع طلاب الشعبة'
                                : 'تم طرح موضوع النقاش الجديد',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: const Color(0xFF2E9B5F),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isAnnouncement ? 'نشر الإعلان للطلاب' : 'بدء المناقشة الأكاديمية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  },
).then((_) {
  titleController.dispose();
  contentController.dispose();
});
  }

  void _openDoctorReplyDialog(CommunityPostItem post) {
    final replyController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.reply_rounded, color: _blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'الرد على استفسار الطالب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الطالب: ${post.author} (${post.courseName})',
                style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyController,
                maxLines: 4,
                style: GoogleFonts.cairo(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'اكتب إجابتك وتوضيحك الأكاديمي للطالب هنا...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                final reply = replyController.text.trim();
                if (reply.isEmpty) return;

                setState(() {
                  final idx = _posts.indexWhere((p) => p.id == post.id);
                  if (idx != -1) {
                    _posts[idx] = _posts[idx].copyWith(
                      doctorReply: reply,
                      isAnswered: true,
                      repliesCount: _posts[idx].repliesCount + 1,
                    );
                  }
                });

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال ردك للطالب بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: const Color(0xFF2E9B5F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('إرسال الرد', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    ).then((_) => replyController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    // Filter posts
    final filteredPosts = _posts.where((p) {
      if (_selectedTab == 1) return p.type == CommunityPostType.announcement;
      if (_selectedTab == 2) return p.type == CommunityPostType.question;
      if (_selectedTab == 3) return p.type == CommunityPostType.resource;
      return true;
    }).toList();

    final content = Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            DoctorHeader(showBackButton: widget.showBack),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 105),
                  children: [
                    _buildTopCard(context),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 16),
                    ...filteredPosts.map((p) => _buildPostCard(p)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.showBack) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          safeDoctorPop(context);
        },
        child: content,
      );
    }
    return content;
  }

  Widget _buildTopCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'مجتمع المقررات الأكاديمي',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFAF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'بيانات تجريبية',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E9B5F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التواصل المباشر مع الشعب والرد على أسئلة الطلاب ونشر المواد',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showNewPostSheet(isAnnouncement: true),
                  icon: const Icon(Icons.campaign_outlined, size: 18, color: Colors.white),
                  label: Text(
                    'إعلان جديد',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNewPostSheet(isAnnouncement: false),
                  icon: const Icon(Icons.add_comment_outlined, size: 18, color: _blue),
                  label: Text(
                    'مناقشة جديدة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _blue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _blue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: Text(
                _tabs[index],
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: _navy,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? _navy : Colors.grey.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTab = index;
                  });
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostCard(CommunityPostItem post) {
    Color typeBg;
    Color typeColor;
    String typeLabel;
    IconData typeIcon;

    switch (post.type) {
      case CommunityPostType.announcement:
        typeBg = const Color(0xFFEFF6FF);
        typeColor = _blue;
        typeLabel = 'إعلان رسمي';
        typeIcon = Icons.campaign_rounded;
        break;
      case CommunityPostType.question:
        typeBg = const Color(0xFFFFFBEB);
        typeColor = const Color(0xFFD97706);
        typeLabel = post.isAnswered ? 'استفسار (تمت الإجابة)' : 'استفسار معلق';
        typeIcon = Icons.help_outline_rounded;
        break;
      case CommunityPostType.resource:
        typeBg = const Color(0xFFEDFAF1);
        typeColor = const Color(0xFF2E9B5F);
        typeLabel = 'ملف ومصدر تعليمي';
        typeIcon = Icons.attach_file_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(typeIcon, size: 14, color: typeColor),
                    const SizedBox(width: 4),
                    Text(
                      typeLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                post.time,
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post.content,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF334155),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          // Author & course info
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _navy.withValues(alpha: 0.1),
                child: Text(
                  post.author.isNotEmpty ? post.author[0] : 'U',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: post.author,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                    children: [
                      TextSpan(
                        text: ' · ${post.courseName}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          // Doctor reply if available
          if (post.doctorReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Text(
                        'إجابة د. محمد مازن محايري:',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.doctorReply!,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: const Color(0xFF14532D),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Action row
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, size: 16, color: _textSub),
                  const SizedBox(width: 6),
                  Text(
                    '${post.repliesCount} ردود',
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  ),
                ],
              ),
              if (post.type == CommunityPostType.question && !post.isAnswered) ...[
                TextButton.icon(
                  onPressed: () => _openDoctorReplyDialog(post),
                  icon: const Icon(Icons.reply_rounded, size: 16, color: _blue),
                  label: Text(
                    'كتابة الرد الأكاديمي',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    ),
                  ),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ رابط المنشور الأكاديمي',
                          style: GoogleFonts.cairo(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 15, color: _textSub),
                  label: Text(
                    'مشاركة',
                    style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
