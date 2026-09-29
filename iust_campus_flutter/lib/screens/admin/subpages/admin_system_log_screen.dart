import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminSystemLogScreen extends StatefulWidget {
  const AdminSystemLogScreen({super.key});

  @override
  State<AdminSystemLogScreen> createState() => _AdminSystemLogScreenState();
}

class _AdminSystemLogScreenState extends State<AdminSystemLogScreen> {
  final List<({String id, String time, String action, String user, String role, String status, IconData icon, Color color})> _logs = [
    (
      id: 'LOG-8812',
      time: 'اليوم، 10:14 ص',
      action: 'تسجيل دخول ناجح لحساب الإدارة',
      user: 'م. رنا الحسن (ADM-018)',
      role: 'الإدارة',
      status: 'ناجح',
      icon: Icons.login_rounded,
      color: Color(0xFF16A34A),
    ),
    (
      id: 'LOG-8811',
      time: 'اليوم، 09:30 ص',
      action: 'اعتماد ونشر نتائج مقرر هندسة البرمجيات',
      user: 'د. بشير غرة (FAC-204)',
      role: 'هيئة تدريسية',
      status: 'معتمد',
      icon: Icons.verified_outlined,
      color: Color(0xFF0F6CBD),
    ),
    (
      id: 'LOG-8810',
      time: 'اليوم، 08:20 ص',
      action: 'تعديل تسجيل شعبة الطالب أحمد السالم',
      user: 'م. رنا الحسن (ADM-018)',
      role: 'الإدارة',
      status: 'مكتمل',
      icon: Icons.edit_note_rounded,
      color: Color(0xFFD97706),
    ),
    (
      id: 'LOG-8809',
      time: 'اليوم، 06:10 ص',
      action: 'إجراء نسخة احتياطية آلية مجدولة لقواعد البيانات',
      user: 'النظام الآلي (iust-cron-01)',
      role: 'النظام',
      status: 'ناجح',
      icon: Icons.cloud_done_rounded,
      color: Color(0xFF16A34A),
    ),
    (
      id: 'LOG-8808',
      time: 'أمس، 05:40 م',
      action: 'إيقاف مؤقت لحساب الموظف محمود العلي',
      user: 'م. رنا الحسن (ADM-018)',
      role: 'الإدارة',
      status: 'موقوف',
      icon: Icons.block_rounded,
      color: Color(0xFFDC2626),
    ),
    (
      id: 'LOG-8807',
      time: 'أمس، 02:15 م',
      action: 'تحديث بيانات الخريطة الذكية للطابق الرابع',
      user: 'فريق الدعم الفني',
      role: 'الدعم الفني',
      status: 'مكتمل',
      icon: Icons.map_outlined,
      color: Color(0xFF7C3AED),
    ),
  ];

  String _filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'الكل'
        ? _logs
        : _logs.where((l) => l.role == _filter || l.status == _filter).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        appBar: AdminHeader(
          showBackButton: true,
          showNotificationBell: false,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل العمليات والتدقيق (Audit Log)',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'سجل الأنشطة الإدارية والأمنية الدورية المنفذة على النظام.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textSub,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['الكل', 'الإدارة', 'هيئة تدريسية', 'النظام'].map((f) {
                          final selected = _filter == f;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(
                                f,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? Colors.white : _textMain,
                                ),
                              ),
                              selected: selected,
                              selectedColor: _navy,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: selected ? _navy : _border),
                              onSelected: (_) => setState(() => _filter = f),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
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
                              color: log.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(log.icon, color: log.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log.action,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _textMain,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: log.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        log.status,
                                        style: GoogleFonts.cairo(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: log.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المشغل: ${log.user}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: _textSub,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      log.id,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _blue,
                                      ),
                                    ),
                                    Text(
                                      log.time,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: _textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
