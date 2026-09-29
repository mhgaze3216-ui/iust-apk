import 'package:flutter/material.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminInquiriesScreen extends StatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  State<AdminInquiriesScreen> createState() => _AdminInquiriesScreenState();
}

class _AdminInquiriesScreenState extends State<AdminInquiriesScreen> {
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'جديد', 'تم الرد', 'مغلق'];

  List<AdminInquiryItem> get _filteredInquiries {
    final all = UniversityAdminRepository.inquiries;
    if (_selectedFilter == 'الكل') return all;
    return all.where((i) => i.status == _selectedFilter).toList();
  }

  void _openInquiryThread(AdminInquiryItem inquiry) {
    final replyController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (bottomSheetCtx, setThreadState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetCtx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFEAF4FB),
                          child: Text(
                            inquiry.userName.isNotEmpty
                                ? inquiry.userName[0]
                                : 'U',
                            style: const TextStyle(
                              color: Color(0xFF0F6CBD),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inquiry.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF073B4C),
                                ),
                              ),
                              Text(
                                '${inquiry.department} • ${inquiry.time}',
                                style: const TextStyle(
                                  color: Color(0xFF6F7F89),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(inquiry.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            inquiry.status,
                            style: TextStyle(
                              color: _getStatusColor(inquiry.status),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),

                  // Messages thread
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: inquiry.messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final msg = inquiry.messages[index];
                        return Align(
                          alignment: msg.isAdmin
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.78,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isAdmin
                                  ? const Color(0xFF073B4C)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(
                                  msg.isAdmin ? 2 : 14,
                                ),
                                bottomRight: Radius.circular(
                                  msg.isAdmin ? 14 : 2,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: msg.isAdmin
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.sender,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: msg.isAdmin
                                        ? const Color(0xFFF5B82E)
                                        : const Color(0xFF0F6CBD),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: msg.isAdmin
                                        ? Colors.white
                                        : const Color(0xFF0B2E3B),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: msg.isAdmin
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : const Color(0xFF6F7F89),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Actions & Input Area
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (inquiry.status != 'مغلق')
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    inquiry.status = 'مغلق';
                                  });
                                  setThreadState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إغلاق الاستفسار'),
                                      backgroundColor: Color(0xFF073B4C),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'إغلاق الاستفسار',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFDCE8EE),
                                  ),
                                ),
                                child: TextField(
                                  controller: replyController,
                                  decoration: const InputDecoration(
                                    hintText: 'اكتب الرد الإداري الرسمي هنا...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF6F7F89),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                final text = replyController.text.trim();
                                if (text.isNotEmpty) {
                                  try {
                                    await UniversityAdminRepository.replyToInquiry(
                                      inquiry.id,
                                      text,
                                    );
                                  } catch (error) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تعذر إرسال الرد: $error',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (!mounted) return;
                                  setState(() {});
                                  setThreadState(() {});
                                  replyController.clear();
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF073B4C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return const Color(0xFF0F6CBD);
      case 'تم الرد':
        return const Color(0xFF16A34A);
      case 'مغلق':
      default:
        return const Color(0xFF6F7F89);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'جديد':
        return const Color(0xFFEAF4FB);
      case 'تم الرد':
        return const Color(0xFFEDFAF1);
      case 'مغلق':
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const blueCol = Color(0xFF0F6CBD);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final items = _filteredInquiries;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'الاستفسارات',
                subtitle: 'متابعة استفسارات الطلاب وأعضاء الهيئة التدريسية والرد عليها',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: const Color(0xFFEAF4FB),
                        backgroundColor: cardCol,
                        labelStyle: TextStyle(
                          color: isSelected ? blueCol : textSec,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected ? blueCol : borderCol,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFilter = filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Inquiries List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mark_chat_read_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد استفسارات في هذه الفئة',
                              style: TextStyle(color: textSec, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (ctx, idx) {
                          final item = items[idx];
                          return InkWell(
                            onTap: () => _openInquiryThread(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
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
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(
                                          0xFFEAF4FB,
                                        ),
                                        child: Text(
                                          item.userName.isNotEmpty
                                              ? item.userName[0]
                                              : 'U',
                                          style: const TextStyle(
                                            color: blueCol,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5,
                                                color: textMain,
                                              ),
                                            ),
                                            Text(
                                              '${item.department} • ${item.time}',
                                              style: const TextStyle(
                                                color: textSec,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(item.status),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: TextStyle(
                                            color: _getStatusColor(item.status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.question,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: textMain,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 14,
                                        color: textSec,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.messages.length} رسائل',
                                        style: const TextStyle(
                                          color: textSec,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'عرض المحادثة والرد',
                                        style: TextStyle(
                                          color: blueCol,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 12,
                                        color: blueCol,
                                      ),
                                    ],
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
