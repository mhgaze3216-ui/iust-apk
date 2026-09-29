import 'package:flutter/material.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminNotificationsScreenV2 extends StatefulWidget {
  const AdminNotificationsScreenV2({super.key});

  @override
  State<AdminNotificationsScreenV2> createState() =>
      _AdminNotificationsScreenV2State();
}

class _AdminNotificationsScreenV2State
    extends State<AdminNotificationsScreenV2> {
  Future<void> _markAllAsRead() async {
    try {
      await UniversityAdminRepository.markAllNotificationsRead();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث الإشعارات: $error')));
      return;
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد كافة الإشعارات كمقروءة'),
        backgroundColor: Color(0xFF073B4C),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleRead(AdminNotificationModel item) async {
    if (!item.isUnread) return;
    try {
      await UniversityAdminRepository.markNotificationRead(item.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر تحديث الإشعار: $error')));
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final notifs = UniversityAdminRepository.notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'الإشعارات الإدارية',
                subtitle: 'تنبيهات وتحديثات المعاملات والطلبات والمواعيد',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),

              // Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'التنبيهات الحديثة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (UniversityAdminRepository.unreadNotificationsCount >
                            0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5B82E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${UniversityAdminRepository.unreadNotificationsCount} غير مقروء',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF073B4C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text(
                        'تحديد الكل كمقروء',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: notifs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد إشعارات حالياً',
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
                        itemCount: notifs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final notif = notifs[idx];
                          return InkWell(
                            onTap: () => _toggleRead(notif),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: notif.isUnread
                                    ? const Color(0xFFF3F8FC)
                                    : cardCol,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: notif.isUnread
                                      ? const Color(0xFFBCE0FD)
                                      : borderCol,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: notif.isUnread
                                          ? lightBlue
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      notif.isUnread
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      color: notif.isUnread ? blueCol : textSec,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.text,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: notif.isUnread
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: textMain,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color: textSec,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              notif.time,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (notif.isUnread)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0F6CBD),
                                        shape: BoxShape.circle,
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
