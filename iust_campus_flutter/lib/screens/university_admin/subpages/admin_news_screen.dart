import 'package:flutter/material.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';
import 'admin_create_announcement_screen.dart';

class AdminNewsScreen extends StatefulWidget {
  final bool isRootTab;

  const AdminNewsScreen({super.key, this.isRootTab = false});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  int _selectedTab = 0; // 0: منشور, 1: مسودة, 2: مجدول

  List<AdminAnnouncementItem> get _filteredAnnouncements {
    final all = UniversityAdminRepository.announcements;
    if (_selectedTab == 0) {
      return all.where((a) => a.state == AnnouncementState.published).toList();
    } else if (_selectedTab == 1) {
      return all.where((a) => a.state == AnnouncementState.draft).toList();
    } else {
      return all.where((a) => a.state == AnnouncementState.scheduled).toList();
    }
  }

  Future<void> _togglePublishState(AdminAnnouncementItem item) async {
    final state = item.state == AnnouncementState.published
        ? AnnouncementState.draft
        : AnnouncementState.published;
    try {
      await UniversityAdminRepository.updateAnnouncementStatus(item.id, state);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر تحديث الإعلان: $error')));
      return;
    }
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.state == AnnouncementState.published
              ? 'تم نشر الإعلان للعامة'
              : 'تم إلغاء النشر وتحويل الإعلان إلى مسودة',
        ),
        backgroundColor: const Color(0xFF073B4C),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAnnouncementDetails(AdminAnnouncementItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Color(0xFF0F6CBD),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.publishDate,
                    style: const TextStyle(
                      color: Color(0xFF6F7F89),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B4C),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: Color(0xFF6F7F89),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'الفئة المستهدفة: ${item.targetAudience}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6F7F89),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                item.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0B2E3B),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF073B4C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAnnouncementDialog(AdminAnnouncementItem item) {
    final titleCtrl = TextEditingController(text: item.title);
    final contentCtrl = TextEditingController(text: item.content);

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تعديل الإعلان',
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
                  'العنوان:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: titleCtrl,
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
                  'المحتوى:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: contentCtrl,
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
                  await UniversityAdminRepository.updateAnnouncement(
                    id: item.id,
                    title: titleCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر تحديث الإعلان: $error')),
                  );
                  return;
                }
                if (!mounted || !dialogCtx.mounted) return;
                setState(() {});
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تعديل الإعلان بنجاح'),
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

    final items = _filteredAnnouncements;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: widget.isRootTab ? null : 'الأخبار والتعاميم',
                subtitle: widget.isRootTab
                    ? null
                    : 'إدارة ونشر الأخبار والتعاميم الرسمية للجامعة',
                showBack: !widget.isRootTab,
                onBackPressed: widget.isRootTab
                    ? null
                    : () => Navigator.maybePop(context),
              ),

              // Action Bar with New Announcement Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEF3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, 'منشور', navyCol),
                            _buildTabItem(1, 'مسودة', navyCol),
                            _buildTabItem(2, 'مجدول', navyCol),
                          ],
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
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                const AdminCreateAnnouncementScreen(),
                          ),
                        );
                        if (res == true) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'إعلان جديد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List of Announcements
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.newspaper_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد إعلانات في هذا القسم',
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
                          final item = items[idx];
                          return Container(
                            width: double.infinity,
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
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: blueCol,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.publishDate,
                                      style: const TextStyle(
                                        color: textSec,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: textSec,
                                    height: 1.4,
                                  ),
                                ),
                                const Divider(height: 20),
                                // Audience Row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_outline_rounded,
                                      size: 14,
                                      color: textSec,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'الفئة المستهدفة: ${item.targetAudience}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: textSec,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Responsive Action Buttons
                                Row(
                                  children: [
                                    // Action: Open
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: blueCol,
                                          side: const BorderSide(
                                            color: borderCol,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () =>
                                            _showAnnouncementDetails(item),
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'فتح',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Action: Edit
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: navyCol,
                                          side: const BorderSide(
                                            color: borderCol,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () =>
                                            _showEditAnnouncementDialog(item),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'تعديل',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Action: Publish / Unpublish
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              item.state ==
                                                  AnnouncementState.published
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF16A34A),
                                          side: BorderSide(
                                            color:
                                                item.state ==
                                                    AnnouncementState.published
                                                ? const Color(0xFFFCA5A5)
                                                : const Color(0xFF86EFAC),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () =>
                                            _togglePublishState(item),
                                        icon: Icon(
                                          item.state ==
                                                  AnnouncementState.published
                                              ? Icons.unpublished_outlined
                                              : Icons.publish_rounded,
                                          size: 15,
                                        ),
                                        label: Text(
                                          item.state ==
                                                  AnnouncementState.published
                                              ? 'إلغاء النشر'
                                              : 'نشر',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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

  Widget _buildTabItem(int index, String label, Color navyCol) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? navyCol : const Color(0xFF6F7F89),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
