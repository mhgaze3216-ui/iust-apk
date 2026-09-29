import 'package:flutter/material.dart';
import '../../../data/transport_data.dart';
import '../widgets/university_admin_header.dart';

class AdminTransportManagementScreen extends StatefulWidget {
  const AdminTransportManagementScreen({super.key});

  @override
  State<AdminTransportManagementScreen> createState() => _AdminTransportManagementScreenState();
}

class _AdminTransportManagementScreenState extends State<AdminTransportManagementScreen> {
  int _selectedTab = 0; // 0: الرحلات الصباحية, 1: رحلات العودة, 2: المسارات, 3: التنبيهات

  // Local state for transport alerts
  final List<Map<String, String>> _transportAlerts = [
    {
      'id': 'alt-1',
      'title': 'تحديث مسار خط المزة',
      'body': 'تم تحويل نقطة التجمع المؤقتة من جانب مشفى المواساة إلى مدخل حديقة الوحدة لأعمال الصيانة.',
      'time': 'اليوم، 06:15 ص',
      'level': 'هام',
    },
    {
      'id': 'alt-2',
      'title': 'حافلة إضافية لرحلة العودة 02:00 م',
      'body': 'تم تعيين حافلتين إضافيتين باتجاه مشروع دمر وضاحية قدسيا نظراً لضغط الامتحانات.',
      'time': 'أمس، 01:30 م',
      'level': 'تنبيه',
    },
  ];

  // Local additional trips list
  final List<TransportStop> _customMorningStops = [];

  void _showAddTripDialog() {
    final areaCtrl = TextEditingController();
    final depCtrl = TextEditingController(text: '07:15');
    final endCtrl = TextEditingController(text: '07:30');

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'إضافة رحلة / محطة جديدة',
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
                const Text('المنطقة أو مسار المحطة:', style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89))),
                const SizedBox(height: 6),
                TextField(
                  controller: areaCtrl,
                  decoration: InputDecoration(
                    hintText: 'مثال: جرمانا / ساحة السيوف',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('وقت الانطلاق:', style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: depCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('نهاية التجمع:', style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: endCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء', style: TextStyle(color: Color(0xFF6F7F89))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF073B4C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (areaCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _customMorningStops.add(
                      TransportStop(
                        transportScheduleId: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                        direction: TransportDirection.toUniversity,
                        wave: 'morning1',
                        area: areaCtrl.text.trim(),
                        departureTime: depCtrl.text.trim(),
                        endTime: endCtrl.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إضافة الرحلة بنجاح إلى الجدول'),
                      backgroundColor: Color(0xFF073B4C),
                    ),
                  );
                }
              },
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewAlertDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'نشر تنبيه عاجل لخطوط النقل',
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
                const Text('عنوان التنبيه:', style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89))),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'مثال: تأخر حافلة خط المزة',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('تفاصيل التنبيه والتعليمات:', style: TextStyle(fontSize: 12, color: Color(0xFF6F7F89))),
                const SizedBox(height: 6),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'اكتب نص التنبيه الموجه للطلاب والكوادر هنا...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء', style: TextStyle(color: Color(0xFF6F7F89))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF073B4C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty && bodyCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _transportAlerts.insert(0, {
                      'id': 'alt-${DateTime.now().millisecondsSinceEpoch}',
                      'title': titleCtrl.text.trim(),
                      'body': bodyCtrl.text.trim(),
                      'time': 'الآن',
                      'level': 'هام',
                    });
                  });
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نشر التنبيه بنجاح لكافة مستخدمي النقل'),
                      backgroundColor: Color(0xFF073B4C),
                    ),
                  );
                }
              },
              child: const Text('نشر التنبيه', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopDetails(TransportStop stop) {
    showModalBottomSheet(
      context: context,
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: Color(0xFF0F6CBD)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.area,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF073B4C),
                          ),
                        ),
                        Text(
                          'رمز الخط: ${stop.transportScheduleId}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6F7F89)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow('وقت الانطلاق:', stop.departureTime),
              const SizedBox(height: 8),
              _buildInfoRow('نهاية نافذة التجمع:', stop.endTime ?? 'انطلاق فوري'),
              const SizedBox(height: 8),
              _buildInfoRow('الاتجاه:', 'نحو الحرم الجامعي (غباغب)'),
              const SizedBox(height: 8),
              _buildInfoRow('حالة الخط:', 'نشط ومنتظم'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF073B4C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6F7F89), fontSize: 13)),
        const SizedBox(width: 8),
        Text(
          val,
          style: const TextStyle(
            color: Color(0xFF0B2E3B),
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'النقل الجامعي',
                subtitle: 'إدارة جداول ومسارات وتنبيهات حافلات الجامعة',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),

              // Navigation and Action Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            _buildTabItem(0, 'الصباحية', navyCol),
                            _buildTabItem(1, 'العودة', navyCol),
                            _buildTabItem(2, 'المسارات', navyCol),
                            _buildTabItem(3, 'التنبيهات', navyCol),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sub-action buttons (Add Trip or Publish Alert)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navyCol,
                          side: const BorderSide(color: borderCol),
                          backgroundColor: cardCol,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: _showAddTripDialog,
                        icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                        label: const Text('إضافة رحلة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE67E22),
                          side: const BorderSide(color: Color(0xFFFDE8D0)),
                          backgroundColor: cardCol,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: _showNewAlertDialog,
                        icon: const Icon(Icons.add_alert_rounded, size: 16),
                        label: const Text('نشر تنبيه', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Main Section View
              Expanded(
                child: _buildSectionContent(
                  cardCol: cardCol,
                  borderCol: borderCol,
                  navyCol: navyCol,
                  blueCol: blueCol,
                  lightBlue: lightBlue,
                  textMain: textMain,
                  textSec: textSec,
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
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent({
    required Color cardCol,
    required Color borderCol,
    required Color navyCol,
    required Color blueCol,
    required Color lightBlue,
    required Color textMain,
    required Color textSec,
  }) {
    if (_selectedTab == 0) {
      // الصباحية
      final allMorning = [..._customMorningStops, ...kMorning1, ...kMorning2, ...kMorning3];
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allMorning.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (ctx, idx) {
          final stop = allMorning[idx];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardCol,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.directions_bus_outlined, color: blueCol, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.area,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الانطلاق: ${stop.departureTime} ${stop.endTime != null ? '- ${stop.endTime}' : ''}',
                        style: TextStyle(fontSize: 12, color: textSec),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showStopDetails(stop),
                  child: const Text('عرض', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedTab == 1) {
      // رحلات العودة
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kReturnTrips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final trip = kReturnTrips[idx];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardCol,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الانطلاق: ${trip.departureTime}',
                        style: TextStyle(
                          color: blueCol,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'من الحرم الجامعي',
                      style: TextStyle(fontSize: 11.5, color: textSec),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (trip.note != null)
                  Text(
                    trip.note!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: trip.areas.map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(a, style: TextStyle(fontSize: 11, color: textMain)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      );
    } else if (_selectedTab == 2) {
      // المسارات الكبرى
      final majorRoutes = [
        {'name': 'مسار المزة والأوتوستراد', 'stops': '12 محطة', 'status': 'منتظم'},
        {'name': 'مسار برزة والميسات والعدوي', 'stops': '9 محطات', 'status': 'منتظم'},
        {'name': 'مسار مشروع دمر وضاحية قدسيا', 'stops': '7 محطات', 'status': 'منتظم'},
        {'name': 'مسار كفرسوسة والزاهرة وباب مصلى', 'stops': '8 محطات', 'status': 'منتظم'},
        {'name': 'مسار صحنايا وقرى الشام', 'stops': '5 محطات', 'status': 'نشط'},
      ];

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: majorRoutes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final r = majorRoutes[idx];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardCol,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.alt_route_rounded, color: blueCol, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name']!,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'إجمالي التغطية: ${r['stops']} • ${r['status']}',
                        style: TextStyle(fontSize: 12, color: textSec),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF6F7F89)),
              ],
            ),
          );
        },
      );
    } else {
      // التنبيهات
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transportAlerts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, idx) {
          final alt = _transportAlerts[idx];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardCol,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE8D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4D6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alt['level']!,
                        style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alt['time']!,
                      style: TextStyle(fontSize: 11, color: textSec),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alt['title']!,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alt['body']!,
                  style: TextStyle(fontSize: 13, color: textSec, height: 1.4),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
