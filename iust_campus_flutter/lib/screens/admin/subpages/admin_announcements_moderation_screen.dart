import 'package:flutter/material.dart';
import '../widgets/admin_header.dart';

class AdminAnnouncementsModerationScreen extends StatefulWidget {
  const AdminAnnouncementsModerationScreen({super.key});

  @override
  State<AdminAnnouncementsModerationScreen> createState() =>
      _AdminAnnouncementsModerationScreenState();
}

class _AdminAnnouncementsModerationScreenState
    extends State<AdminAnnouncementsModerationScreen> {
  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 'ANN-044',
      'title': 'تحديث مواعيد انطلاق حافلات النقل الجامعي للمسار الجنوبي',
      'author': 'إدارة النقل والخدمات الطلابية',
      'targetAudience': 'جميع الطلاب وأعضاء الهيئة التدريسية',
      'category': 'النقل والمواصلات',
      'submittedAt': 'اليوم، 08:30 ص',
      'body':
          'نحيطكم علماً بأنه تم تعديل موعد انطلاق حافلات مسار (درعا - دمشق - الصنمين) لتبدأ من الساعة 06:45 صباحاً بدلاً من 07:00 اعتباراً من يوم الأحد القادم لتفادي الازدحام المروري.',
      'status': 'بانتظار الاعتماد',
      'isUrgent': true,
    },
    {
      'id': 'ANN-043',
      'title': 'بدء استقبال طلبات الاعتراض على نتائج الامتحانات الفصلية',
      'author': 'دائرة الامتحانات وشؤون الطلاب',
      'targetAudience': 'طلاب كلية الهندسة المعمارية',
      'category': 'شؤون أكاديمية',
      'submittedAt': 'أمس، 02:15 م',
      'body':
          'تعلن دائرة الامتحانات عن فتح باب التقدم بطلبات إعادة تصحيح الأوراق الامتحانية لمدة أسبوع عبر بوابة الطالب الإلكترونية.',
      'status': 'منشور',
      'isUrgent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0F2537);
    const slateGray = Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              AdminHeader(
                title: 'إدارة الإعلانات',
                subtitle: 'مراجعة واعتماد وتعميم إعلانات الجامعة الرسمية',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final item = _announcements[index];
                    final isPending = item['status'] == 'بانتظار الاعتماد';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPending
                              ? const Color(0xFFFED7AA)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isPending
                                        ? const Color(0xFFFFF7ED)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.campaign_rounded,
                                    color: isPending
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF2563EB),
                                    size: 24,
                                  ),
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
                                              item['title'] as String,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: navyDark,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isPending
                                                  ? const Color(0xFFFFF7ED)
                                                  : const Color(0xFFF0FDF4),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['status'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isPending
                                                    ? const Color(0xFFEA580C)
                                                    : const Color(0xFF16A34A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'الجهة الناشرة: ${item['author']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEDF2F7)),
                              ),
                              child: Text(
                                item['body'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.people_outline, size: 15, color: slateGray),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'الجمهور: ${item['targetAudience']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: slateGray,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.schedule, size: 15, color: slateGray),
                                const SizedBox(width: 4),
                                Text(
                                  item['submittedAt'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: slateGray,
                                  ),
                                ),
                              ],
                            ),
                            if (isPending) ...[
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _announcements.removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم رفض الإعلان وإعادته للمحرر'),
                                            backgroundColor: Color(0xFFDC2626),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.close, size: 18, color: Color(0xFFDC2626)),
                                      label: const Text(
                                        'رفض الإعلان',
                                        style: TextStyle(
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          item['status'] = 'منشور';
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم اعتماد ونشر الإعلان بنجاح للجميع'),
                                            backgroundColor: Color(0xFF16A34A),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.publish_rounded, size: 18, color: Colors.white),
                                      label: const Text(
                                        'اعتماد ونشر',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F6CBD),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
