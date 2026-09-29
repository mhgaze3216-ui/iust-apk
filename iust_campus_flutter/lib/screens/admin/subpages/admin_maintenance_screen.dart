import 'package:flutter/material.dart';
import '../widgets/admin_header.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  State<AdminMaintenanceScreen> createState() => _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState extends State<AdminMaintenanceScreen> {
  // Demo maintenance tickets
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'MNT-201',
      'title': 'عطل في جهاز العرض الضوئي (Projector)',
      'location': 'القاعة 4211 · كلية الهندسات - الطابق الرابع',
      'reportedBy': 'د. معن سليم',
      'time': 'منذ ساعة',
      'urgency': 'متوسطة',
      'status': 'قيد المتابعة',
      'assignedTo': 'فريق الصيانة الإلكترونية - م. حسام',
      'notes': 'تم فحص المصباح وهو بحاجة للاستبدال، بانتظار القطعة من المستودع.',
    },
    {
      'id': 'MNT-202',
      'title': 'تسريب مياه في دورات مياه الطابق الثاني',
      'location': 'مبنى الهندسات · الجناح الغربي',
      'reportedBy': 'أ. أنس مرعي (مشرف الطابق)',
      'time': 'منذ ساعتين',
      'urgency': 'عاجلة',
      'status': 'جديد',
      'assignedTo': 'غير محدد بعد',
      'notes': 'يرجى إرسال فني سباكة قبل بدء المحاضرات المسائية.',
    },
    {
      'id': 'MNT-203',
      'title': 'عطل في وحدة التكييف المركزية',
      'location': 'مخبر الشبكات 3105 · مبنى الهندسات',
      'reportedBy': 'م. رشا العلي',
      'time': 'منذ 3 ساعات',
      'urgency': 'متوسطة',
      'status': 'تم التعيين',
      'assignedTo': 'شركة التكييف والتبريد المتعاقدة',
      'notes': 'ارتفاع حرارة السيرفرات داخل المخبر.',
    },
  ];

  String _filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0F2537);
    const slateGray = Color(0xFF64748B);

    final filtered = _filter == 'الكل'
        ? _tickets
        : _tickets.where((t) => t['status'] == _filter).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              AdminHeader(
                title: 'بلاغات الصيانة',
                subtitle: 'إدارة وتتبع أعطال المرافق والتجهيزات',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // Filter pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('الكل'),
                      const SizedBox(width: 8),
                      _buildFilterChip('جديد'),
                      const SizedBox(width: 8),
                      _buildFilterChip('تم التعيين'),
                      const SizedBox(width: 8),
                      _buildFilterChip('قيد المتابعة'),
                      const SizedBox(width: 8),
                      _buildFilterChip('مكتمل'),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build_outlined, size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد بلاغات تطابق التصفية',
                              style: TextStyle(fontSize: 15, color: slateGray),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isUrgent = item['urgency'] == 'عاجلة';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUrgent
                                    ? const Color(0xFFFCA5A5)
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
                                          color: isUrgent
                                              ? const Color(0xFFFEF2F2)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.build_circle_rounded,
                                          color: isUrgent
                                              ? const Color(0xFFDC2626)
                                              : navyDark,
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusBg(item['status'] as String),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    item['status'] as String,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: _getStatusColor(item['status'] as String),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['location'] as String,
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
                                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 15, color: slateGray),
                                      const SizedBox(width: 4),
                                      Text(
                                        'المبلّغ: ${item['reportedBy']}',
                                        style: TextStyle(fontSize: 12, color: slateGray),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.access_time, size: 15, color: slateGray),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['time'] as String,
                                        style: TextStyle(fontSize: 12, color: slateGray),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.engineering_outlined, size: 15, color: navyDark),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'الفني المكلف: ${item['assignedTo']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: navyDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showUpdateStatusSheet(item),
                                          icon: const Icon(Icons.edit_note, size: 18),
                                          label: const Text('تحديث الحالة'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: navyDark,
                                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              item['status'] = 'مكتمل';
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('تم إغلاق البلاغ ${item['id']} بنجاح'),
                                                backgroundColor: const Color(0xFF16A34A),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                                          label: const Text('إغلاق البلاغ', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF16A34A),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return InkWell(
      onTap: () => setState(() => _filter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2537) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F2537) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'جديد':
        return const Color(0xFFFEF2F2);
      case 'تم التعيين':
        return const Color(0xFFEFF6FF);
      case 'قيد المتابعة':
        return const Color(0xFFFFFBEB);
      case 'مكتمل':
        return const Color(0xFFF0FDF4);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return const Color(0xFFDC2626);
      case 'تم التعيين':
        return const Color(0xFF2563EB);
      case 'قيد المتابعة':
        return const Color(0xFFD97706);
      case 'مكتمل':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showUpdateStatusSheet(Map<String, dynamic> item) {
    final noteCtrl = TextEditingController(text: item['notes'] as String? ?? '');
    String selectedStatus = item['status'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تحديث بلاغ ${item['id']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2537),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'الحالة الحالية:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['جديد', 'تم التعيين', 'قيد المتابعة', 'مكتمل'].map((st) {
                  final active = selectedStatus == st;
                  return ChoiceChip(
                    label: Text(st, style: TextStyle( color: active ? Colors.white : Colors.black87)),
                    selected: active,
                    selectedColor: const Color(0xFF0F2537),
                    onSelected: (_) {
                      setState(() {
                        selectedStatus = st;
                      });
                      (ctx as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'ملاحظات الفني / الإدارة:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'أدخل الملاحظات والتحديثات...',
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item['status'] = selectedStatus;
                      item['notes'] = noteCtrl.text;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث البلاغ بنجاح'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2537),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
