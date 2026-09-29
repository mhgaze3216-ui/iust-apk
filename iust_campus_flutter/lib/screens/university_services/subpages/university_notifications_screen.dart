import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityNotificationsScreen extends StatefulWidget {
  const UniversityNotificationsScreen({super.key});

  @override
  State<UniversityNotificationsScreen> createState() => _UniversityNotificationsScreenState();
}

class _UniversityNotificationsScreenState extends State<UniversityNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = UniversityServicesRepository.notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'إشعارات الإدارة الجامعية',
                subtitle: 'تحديثات الطلبات والمواعيد والإعلانات الرسمية',
                showBackButton: true,
                showNotificationBell: false,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = list[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: notif.isUnread ? _blue.withValues(alpha: 0.4) : _border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notif.isUnread ? const Color(0xFFEAF4FB) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: notif.isUnread ? _blue : _textSub,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.message,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: notif.isUnread ? FontWeight.bold : FontWeight.normal,
                                    color: _textMain,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.time,
                                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                                ),
                              ],
                            ),
                          ),
                          if (notif.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(
                                color: _blue,
                                shape: BoxShape.circle,
                              ),
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
