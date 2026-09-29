import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/admin_demo_data.dart';
import '../../../models/admin_models.dart';
import '../widgets/admin_header.dart';

const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  void _markAllAsRead() {
    setState(() {
      for (final n in AdminDemoData.notifications) {
        n.isRead = true;
      }
    });
  }

  IconData _iconForType(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.request:
        return Icons.assignment_outlined;
      case AdminNotificationType.maintenance:
        return Icons.build_circle_outlined;
      case AdminNotificationType.transport:
        return Icons.directions_bus_outlined;
      case AdminNotificationType.system:
        return Icons.dns_outlined;
      case AdminNotificationType.account:
        return Icons.no_accounts_outlined;
    }
  }

  Color _colorForType(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.request:
        return const Color(0xFF0F6CBD);
      case AdminNotificationType.maintenance:
        return const Color(0xFFE53E3E);
      case AdminNotificationType.transport:
        return const Color(0xFFE67E22);
      case AdminNotificationType.system:
        return const Color(0xFF2E9B5F);
      case AdminNotificationType.account:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = AdminDemoData.notifications;

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: const AdminHeader(showBackButton: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إشعارات الإدارة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      Text(
                        'التنبيهات المباشرة ومستجدات المنصة',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: Text(
                    'تحديد الكل كمقروء',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...notifs.map((n) {
              final color = _colorForType(n.type);
              final icon = _iconForType(n.type);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.isRead ? _white : const Color(0xFFF0F7FD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: n.isRead ? _border : const Color(0xFFB9DDF8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() => n.isRead = true);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: n.isRead
                                          ? FontWeight.w700
                                          : FontWeight.w800,
                                      color: _textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  n.time,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: _textSub,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: const Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
