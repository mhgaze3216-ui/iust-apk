import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/feed_models.dart';
import '../../services/mock_feed_service.dart';
import '../../services/student_session.dart';

// ── palette ────────────────────────────────────────────────────────────────
const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

// ── post-type helpers ──────────────────────────────────────────────────────
extension _PostTypeX on PostType {
  String get label {
    switch (this) {
      case PostType.question:    return 'سؤال';
      case PostType.discussion:  return 'نقاش';
      case PostType.resource:    return 'مورد';
    }
  }

  Color get color {
    switch (this) {
      case PostType.question:    return const Color(0xFF7C3AED);
      case PostType.discussion:  return _blue;
      case PostType.resource:    return const Color(0xFF2E9B5F);
    }
  }

  Color get bg {
    switch (this) {
      case PostType.question:    return const Color(0xFFF5F0FF);
      case PostType.discussion:  return _lightBlue;
      case PostType.resource:    return const Color(0xFFEDFAF1);
    }
  }
}

// ── screen ─────────────────────────────────────────────────────────────────
class StudentClassFeedScreen extends StatefulWidget {
  final String? studentId;
  const StudentClassFeedScreen({super.key, this.studentId});
  @override
  State<StudentClassFeedScreen> createState() =>
      _StudentClassFeedScreenState();
}

class _StudentClassFeedScreenState extends State<StudentClassFeedScreen> {
  List<FeedPost> _posts = [];
  String _filterCourse = 'all';
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  Future<void> _load() async {
    final posts = await MockFeedService.getPostsForStudent(_studentId);
    if (mounted) setState(() { _posts = posts; _loading = false; });
  }

  List<FeedPost> get _filtered {
    var list = _filterCourse == 'all'
        ? _posts
        : _posts.where((p) => p.courseId == _filterCourse).toList();
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.content.toLowerCase().contains(q) ||
              (p.title?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  Future<void> _toggleLike(FeedPost post) async {
    await MockFeedService.toggleLike(post.id);
    setState(() {});
  }

  Future<void> _toggleFollow(FeedPost post) async {
    await MockFeedService.toggleFollow(post.id);
    setState(() {});
  }

  void _showNewPostDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewPostSheet(
        studentId: _studentId,
        onSubmit: (courseId, courseName, content, type, title) async {
          await MockFeedService.createPost(
            studentId: _studentId,
            courseId: courseId,
            courseName: courseName,
            content: content,
            postType: type,
            title: title,
          );
          await _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── header ──────────────────────────────────────────────
              _Header(onNewPost: _showNewPostDialog),

              // ── search ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: _SearchBar(controller: _searchCtrl,
                    onChanged: (_) => setState(() {})),
              ),

              // ── course filters ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _CourseFilters(
                  studentId: _studentId,
                  selected: _filterCourse,
                  onSelect: (id) => setState(() => _filterCourse = id),
                ),
              ),
              const SizedBox(height: 8),

              // ── posts ────────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 120),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _PostCard(
                              post: _filtered[i],
                              onLike: () => _toggleLike(_filtered[i]),
                              onFollow: () => _toggleFollow(_filtered[i]),
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

// ── header ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.onNewPost});
  final VoidCallback onNewPost;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مجتمع الطلاب',
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: _textMain)),
            Text('Class Feed',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
          ]),
        ),
        GestureDetector(
          onTap: onNewPost,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: _white, size: 16),
              const SizedBox(width: 4),
              Text('منشور جديد',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _white)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── search bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        const Icon(Icons.search_rounded, color: _textSub, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'ابحث في الأسئلة والنقاشات...',
              hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── course filters ──────────────────────────────────────────────────────────
class _CourseFilters extends StatelessWidget {
  const _CourseFilters({required this.selected, required this.onSelect, this.studentId});
  final String selected;
  final ValueChanged<String> onSelect;
  final String? studentId;

  // Build filter list dynamically from real enrolled courses
  List<(String, String)> get _filters => [
        ('all', 'الكل'),
        ...MockFeedService.getEnrolledCourses(studentId).map((c) {
          // Use short name for display (up to 10 chars)
          final short = c.$2.length > 14 ? '${c.$2.substring(0, 14)}…' : c.$2;
          return (c.$1, short);
        }),
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        reverse: true,
        children: _filters.map((f) {
          final (id, label) = f;
          final active = selected == id;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => onSelect(id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? _navy : _white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? _navy : _border),
                ),
                child: Text(label,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? _white : _textSub)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── post card ──────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onLike, required this.onFollow});
  final FeedPost post;
  final VoidCallback onLike, onFollow;

  String _timeAgo() {
    final diff = DateTime.now().difference(post.createdAt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // top row: avatar + info + type tag
        Row(children: [
          _Avatar(name: post.studentName),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.studentName,
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
              Text(_timeAgo(),
                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
            ]),
          ),
          // type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: post.postType.bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(post.postType.label,
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: post.postType.color)),
          ),
        ]),

        const SizedBox(height: 10),

        // title
        if (post.title != null) ...[
          Text(post.title!,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          const SizedBox(height: 4),
        ],

        // content
        Text(post.content,
            style: GoogleFonts.cairo(fontSize: 13, color: _textMain, height: 1.6)),

        const SizedBox(height: 10),

        // course tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(post.courseName,
              style: GoogleFonts.cairo(fontSize: 11, color: _blue, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 12),

        // actions row
        Row(children: [
          _ActionBtn(
            icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: '${post.likesCount}',
            color: post.isLiked ? const Color(0xFFE53E3E) : _textSub,
            onTap: onLike,
          ),
          const SizedBox(width: 16),
          _ActionBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${post.commentsCount}',
            color: _textSub,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('التعليقات ستتوفر قريباً',
                    style: GoogleFonts.cairo()),
                backgroundColor: _navy,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: post.isFollowed ? _lightBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: post.isFollowed ? _blue : _border),
              ),
              child: Text(post.isFollowed ? 'متابَع' : 'متابعة',
                  style: GoogleFonts.cairo(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: post.isFollowed ? _blue : _textSub)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '؟';
    return Container(
      width: 38, height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _navy, shape: BoxShape.circle),
      child: Text(initial,
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: _white)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 12, color: color)),
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.forum_rounded, size: 48, color: _border),
          const SizedBox(height: 12),
          Text('لا توجد منشورات', style: GoogleFonts.cairo(color: _textSub, fontSize: 14)),
        ]),
      );
}

// ── new post bottom sheet ──────────────────────────────────────────────────
class _NewPostSheet extends StatefulWidget {
  const _NewPostSheet({required this.onSubmit, this.studentId});
  final Future<void> Function(String courseId, String courseName, String content, PostType type, String? title) onSubmit;
  final String? studentId;
  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _contentCtrl = TextEditingController();
  final _titleCtrl   = TextEditingController();
  late String _courseId;
  late String _courseName;
  PostType _type     = PostType.question;
  bool _submitting   = false;

  @override
  void initState() {
    super.initState();
    final first = MockFeedService.getEnrolledCourses(widget.studentId).firstOrNull;
    _courseId = first?.$1 ?? '';
    _courseName = first?.$2 ?? '';
  }

  @override
  void dispose() { _contentCtrl.dispose(); _titleCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await widget.onSubmit(_courseId, _courseName, _contentCtrl.text.trim(), _type,
        _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // padding applied inside scroll so keyboard pushes content up correctly
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: 20, left: 16, right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('منشور جديد', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
          const SizedBox(height: 14),

          // post type
          Row(children: PostType.values.map((t) {
            final sel = _type == t;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? t.bg : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? t.color : _border),
                  ),
                  child: Text(t.label, style: GoogleFonts.cairo(fontSize: 12, color: sel ? t.color : _textSub, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 12),

          // course selector
          DropdownButtonFormField<String>(
            initialValue: _courseId.isNotEmpty ? _courseId : null,
            decoration: InputDecoration(
              labelText: 'المادة',
              labelStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: MockFeedService.getEnrolledCourses(widget.studentId).map((c) {
              final (id, name) = c;
              return DropdownMenuItem(value: id, child: Text(name, style: GoogleFonts.cairo(fontSize: 13)));
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              final found = MockFeedService.getEnrolledCourses(widget.studentId).firstWhere((c) => c.$1 == v);
              setState(() { _courseId = found.$1; _courseName = found.$2; });
            },
          ),
          const SizedBox(height: 10),

          // title
          TextField(
            controller: _titleCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'عنوان (اختياري)',
              hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),

          // content
          TextField(
            controller: _contentCtrl,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب سؤالك أو موضوع النقاش...',
              hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: _white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _white))
                  : Text('نشر', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),        // Column children
        ),         // SingleChildScrollView
      ),           // Container
    );             // Directionality
  }
}
