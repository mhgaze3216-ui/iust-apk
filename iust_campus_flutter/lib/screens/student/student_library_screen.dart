import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../models/library_model.dart';
import '../../models/student_models.dart';
import '../../services/student_session.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

// ── Screen ─────────────────────────────────────────────────────────────────
class StudentLibraryScreen extends StatefulWidget {
  final String? studentId;
  const StudentLibraryScreen({super.key, this.studentId});

  @override
  State<StudentLibraryScreen> createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen> {
  String _search = '';
  String _category = 'الكل';

  String get _activeStudentId =>
      widget.studentId ?? StudentSession.currentStudentId;

  StudentProfile? get _profile => StudentRepository.getStudent(_activeStudentId);

  List<LibraryReference> get _books =>
      StudentRepository.getLibraryReferences(_activeStudentId);

  List<String> get _categories {
    final cats = _books.map((b) => b.category).toSet().toList();
    return ['الكل', ...cats];
  }

  List<LibraryReference> get _filtered {
    final effectiveCategory =
        _categories.contains(_category) ? _category : 'الكل';
    return _books.where((b) {
      final q = _search.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.authors.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q);
      final matchCat = effectiveCategory == 'الكل' || b.category == effectiveCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCategory =
        _categories.contains(_category) ? _category : 'الكل';

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _buildAppBar(context),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // ── search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 16, color: _textSub),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث بالعنوان أو المؤلف...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── category filter chips ──────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              reverse: true,
              children: [
                for (final cat in _categories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: effectiveCategory == cat ? _navy : _white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: effectiveCategory == cat ? _navy : _border,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: effectiveCategory == cat
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: effectiveCategory == cat ? _white : _textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── book list ─────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد نتائج مطابقة',
                      style: GoogleFonts.cairo(color: _textSub),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _BookCard(
                      book: _filtered[i],
                      onTap: () => _showDetail(context, _filtered[i]),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, LibraryReference book) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: book.iconBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(book.icon, color: book.iconColor, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              book.title,
              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: _textMain),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              book.authors,
              style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: book.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Text(
                book.category,
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: book.iconColor),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _blue.withValues(alpha: 0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: _blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'هذا المرجع متوفر في المكتبة الجامعية. تواصل مع موظفي المكتبة للاستفسار عن نسخ الاستعارة.',
                    style: GoogleFonts.cairo(fontSize: 12, color: _blue, height: 1.5),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final facultyName = _profile?.facultyNameAr;
    final title = (facultyName != null && facultyName.isNotEmpty)
        ? 'المكتبة — مراجع $facultyName'
        : 'المكتبة الجامعية';
    return AppBar(
      backgroundColor: _white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _border),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.onTap});
  final LibraryReference book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: book.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(book.icon, color: book.iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  book.title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  book.authors,
                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: book.iconBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    book.category,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: book.iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ),
            const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
          ]),
        ),
      );
}
