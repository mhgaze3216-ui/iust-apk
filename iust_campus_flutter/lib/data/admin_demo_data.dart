import 'package:flutter/material.dart';
import '../models/admin_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DEMO ADMIN DATA SOURCE
//
// All data below represents sample administrative datasets for the university
// central management console. Replace with real API repository when connected.
// ─────────────────────────────────────────────────────────────────────────────

class AdminDemoData {
  // ── 1. Admin Profile ───────────────────────────────────────────────────────
  static const AdminProfile profile = AdminProfile(
    adminId: 'admin-001',
    fullName: 'م. رنا الحسن',
    jobTitle: 'مهندسة النظم والخدمات',
    initials: 'رح',
    email: 'rana.hassan@iust.edu.sy',
    department: 'مديرية النظم والمعلومات - الإدارة',
    pendingRequestsCount: 23,
    systemReadinessPercent: 96,
  );

  // ── 2. Dashboard 2x2 University Statistics (DEMO) ──────────────────────────
  static const List<AdminStatItem> dashboardStats = [
    AdminStatItem(
      title: 'الطلاب الفعالون',
      value: '2,486',
      subtitle: '+42 هذا الفصل',
      icon: Icons.people_alt_rounded,
      iconColor: Color(0xFF0F6CBD),
      iconBg: Color(0xFFEAF4FB),
    ),
    AdminStatItem(
      title: 'أعضاء هيئة التدريس',
      value: '164',
      subtitle: '6 كليات',
      icon: Icons.school_rounded,
      iconColor: Color(0xFF7C3AED),
      iconBg: Color(0xFFF5F0FF),
    ),
    AdminStatItem(
      title: 'الطلبات المفتوحة',
      value: '23',
      subtitle: '8 بحاجة لمراجعة',
      icon: Icons.assignment_late_rounded,
      iconColor: Color(0xFFE67E22),
      iconBg: Color(0xFFFDF2E9),
    ),
    AdminStatItem(
      title: 'إشغال القاعات',
      value: '91%',
      subtitle: 'ضمن المعدل الطبيعي',
      icon: Icons.meeting_room_rounded,
      iconColor: Color(0xFF2E9B5F),
      iconBg: Color(0xFFEDFAF1),
    ),
  ];

  // ── 3. Services Health Status (DEMO) ──────────────────────────────────────
  static const List<AdminServiceHealth> servicesHealth = [
    AdminServiceHealth(
      name: 'بوابة الطالب',
      uptime: '99.9%',
      statusText: 'تعمل بصورة طبيعية',
      status: ServiceHealthStatus.healthy,
    ),
    AdminServiceHealth(
      name: 'التسجيل الإلكتروني',
      uptime: '98.7%',
      statusText: 'استجابة مستقرة',
      status: ServiceHealthStatus.healthy,
    ),
    AdminServiceHealth(
      name: 'خرائط الطوابق',
      uptime: 'مراجعة',
      statusText: 'تحديث بيانات الطابق الثاني',
      status: ServiceHealthStatus.warning,
    ),
    AdminServiceHealth(
      name: 'خدمة النقل',
      uptime: '100%',
      statusText: 'الجداول منشورة',
      status: ServiceHealthStatus.healthy,
    ),
  ];

  // ── 4. Today Priorities (DEMO) ─────────────────────────────────────────────
  static const List<AdminPriorityItem> todayPriorities = [
    AdminPriorityItem(
      id: 'p-1',
      title: 'طلبات تحتاج قراراً',
      count: '8',
      subtitle: 'أقدم طلب منذ 3 ساعات',
      type: AdminPriorityType.requests,
      color: Color(0xFFE67E22),
      icon: Icons.assignment_late_outlined,
    ),
    AdminPriorityItem(
      id: 'p-2',
      title: 'بلاغات صيانة',
      count: '3',
      subtitle: 'جميعها ضمن كلية الهندسات',
      type: AdminPriorityType.maintenance,
      color: Color(0xFFE53E3E),
      icon: Icons.build_circle_outlined,
    ),
    AdminPriorityItem(
      id: 'p-3',
      title: 'إعلان بانتظار النشر',
      count: '1',
      subtitle: 'تحديث دوام النقل',
      type: AdminPriorityType.announcement,
      color: Color(0xFF0F6CBD),
      icon: Icons.campaign_outlined,
    ),
  ];

  // ── 5. System Backup Information (DEMO) ────────────────────────────────────
  static const String lastBackupText =
      'اكتملت آخر نسخة احتياطية التجريبية اليوم الساعة 06:10.';
  static const String backupDatabaseSize = '1.42 GB';
  static const String backupServerName = 'iust-primary-db-01';

  // ── 6. Administration Summary 2x2 Cards ───────────────────────────────────
  static const List<AdminStatItem> managementStats = [
    AdminStatItem(
      title: 'حساب طالب',
      value: '2,486',
      subtitle: 'مسجلون رسمياً',
      icon: Icons.person_rounded,
      iconColor: Color(0xFF0F6CBD),
      iconBg: Color(0xFFEAF4FB),
    ),
    AdminStatItem(
      title: 'حساب هيئة تدريسية',
      value: '164',
      subtitle: 'في كافة الفصول',
      icon: Icons.badge_rounded,
      iconColor: Color(0xFF2E9B5F),
      iconBg: Color(0xFFEDFAF1),
    ),
    AdminStatItem(
      title: 'قاعة ومرفق',
      value: '96',
      subtitle: 'موزعة على المباني',
      icon: Icons.domain_rounded,
      iconColor: Color(0xFF7C3AED),
      iconBg: Color(0xFFF5F0FF),
    ),
    AdminStatItem(
      title: 'خدمة داخل التطبيق',
      value: '29',
      subtitle: 'نشطة ومفعلة',
      icon: Icons.widgets_rounded,
      iconColor: Color(0xFFE67E22),
      iconBg: Color(0xFFFDF2E9),
    ),
  ];

  // ── 7. Recent Accounts (DEMO & Known Records) ──────────────────────────────
  static final List<AdminAccountItem> recentAccounts = [
    AdminAccountItem(
      id: 'acc-001',
      name: 'أحمد السالم',
      userNumber: '20251042',
      roleLabel: 'طالب',
      role: UserAccountRole.student,
      isActive: true,
      lastLogin: 'اليوم، 10:14 ص',
      email: 'ahmad.salem@student.iust.edu.sy',
      facultyOrDept: 'كلية الهندسة المعلوماتية والاتصالات',
      permissions: ['الوصول إلى البوابة', 'تسجيل المقررات', 'متابعة العلامات'],
    ),
    AdminAccountItem(
      id: 'acc-002',
      name: 'د. بشير غرة',
      userNumber: 'FAC-204',
      roleLabel: 'هيئة تدريسية',
      role: UserAccountRole.doctor,
      isActive: true,
      lastLogin: 'اليوم، 09:30 ص',
      email: 'b.ghourra@iust.edu.sy',
      facultyOrDept: 'قسم هندسة الحواسيب والشبكات',
      permissions: ['رصد العلامات', 'تسجيل الحضور', 'نشر الإعلانات', 'رفع النماذج'],
    ),
    AdminAccountItem(
      id: 'acc-003',
      name: 'محمود العلي',
      userNumber: 'EMP-071',
      roleLabel: 'موظف',
      role: UserAccountRole.employee,
      isActive: false,
      lastLogin: 'منذ 4 أيام',
      email: 'm.ali@iust.edu.sy',
      facultyOrDept: 'دائرة القبول والتسجيل',
      permissions: ['استلام المعاملات', 'طباعة الكشوف'],
    ),
    AdminAccountItem(
      id: 'acc-004',
      name: 'حمزة النجار',
      userNumber: '20251001',
      roleLabel: 'طالب',
      role: UserAccountRole.student,
      isActive: true,
      lastLogin: 'أمس، 08:20 م',
      email: 'hamza@student.iust.edu.sy',
      facultyOrDept: 'كلية طب الأسنان',
      permissions: ['الوصول إلى البوابة', 'الخطة الدراسية', 'التكليفات'],
    ),
    AdminAccountItem(
      id: 'acc-005',
      name: 'د. محمد مازن محايري',
      userNumber: 'doctor-001',
      roleLabel: 'هيئة تدريسية',
      role: UserAccountRole.doctor,
      isActive: true,
      lastLogin: 'اليوم، 08:15 ص',
      email: 'm.mohayeri@iust.edu.sy',
      facultyOrDept: 'كلية الهندسة المعلوماتية والاتصالات',
      permissions: ['إدارة المقررات', 'رفع النتائج للإدارة', 'قوائم الحرمان'],
    ),
  ];

  // ── 8. Administrative Requests / Tickets (DEMO) ───────────────────────────
  static final List<AdminRequestItem> requests = [
    AdminRequestItem(
      id: 'req-001',
      title: 'طلب تعديل شعبة مسجلة',
      requester: 'أحمد السالم',
      requesterId: '20251042',
      reference: 'REQ-1048',
      time: 'منذ 18 دقيقة',
      status: AdminRequestStatus.newRequest,
      priority: AdminRequestPriority.high,
      description:
          'يرغب الطالب في نقل تسجيل مقرر المعالج الدقيق من الشعبة 1 إلى الشعبة 2 نظراً لتعارض وقت المحاضرة مع مقرر متطلب آخر.',
      contextInfo: 'معالج دقيق · الشعبة 1 ➔ الشعبة 2',
      category: 'التسجيل والشعب',
    ),
    AdminRequestItem(
      id: 'req-002',
      title: 'بلاغ عطل في جهاز العرض',
      requester: 'د. معن سليم',
      requesterId: 'FAC-188',
      reference: 'REQ-1045',
      time: 'منذ ساعة',
      status: AdminRequestStatus.inReview,
      priority: AdminRequestPriority.medium,
      description:
          'جهاز الإسقاط الضوئي في القاعة 4211 يتوقف عن العمل تلقائياً بعد مرور 10 دقائق من التشغيل مع وميض أحمر في مؤشر الحرارة.',
      contextInfo: 'قاعة 4211 · مبنى الهندسة - الطابق الرابع',
      category: 'صيانة وتجهيزات',
    ),
    AdminRequestItem(
      id: 'req-003',
      title: 'استفسار عن خصم الأقساط',
      requester: 'نور علي',
      requesterId: '20251067',
      reference: 'REQ-1039',
      time: 'أمس',
      status: AdminRequestStatus.completed,
      priority: AdminRequestPriority.low,
      description:
          'طلب الاستفسار عن استحقاق منحة التفوق الفصلي والخصم المالي المطبق على الدفعة الصيفية المسددة.',
      adminNotes: 'تم التحقق من استيفاء شروط المعدل وتطبيق الخصم بنسبة 15% في الدائرة المالية.',
      contextInfo: 'الدائرة المالية · حسابات الطلبة',
      category: 'شؤون مالية',
    ),
    AdminRequestItem(
      id: 'req-004',
      title: 'طلب تأجيل امتحان نصفي بعذر طبي',
      requester: 'سارة الخطيب',
      requesterId: '20251088',
      reference: 'REQ-1032',
      time: 'منذ يومين',
      status: AdminRequestStatus.inReview,
      priority: AdminRequestPriority.high,
      description:
          'إرفاق التقرير الطبي المعتمد من المشفى الجامعي لطلب إعادة الامتحان النصفي لمقرر نظم التشغيل.',
      contextInfo: 'نظم التشغيل · تقرير طبي رقم Med-881',
      category: 'شؤون أكاديمية',
    ),
    AdminRequestItem(
      id: 'req-005',
      title: 'طلب صيانة مكيف الهواء',
      requester: 'د. لينا المصري',
      requesterId: 'FAC-142',
      reference: 'REQ-1025',
      time: 'منذ 3 أيام',
      status: AdminRequestStatus.completed,
      priority: AdminRequestPriority.low,
      description:
          'صيانة دورية لجهاز التكييف في مدرج الفارابي - كلية طب الأسنان.',
      adminNotes: 'تمت الصيانة وتبديل الفلتر بواسطة فريق الصيانة المركزية.',
      contextInfo: 'مدرج الفارابي · طب الأسنان',
      category: 'صيانة وتجهيزات',
    ),
  ];

  // ── 9. Reports KPI Metrics (DEMO) ──────────────────────────────────────────
  static const Map<String, dynamic> reportKpis = {
    'appUsage': {'value': '78%', 'trend': '+6.4%', 'isPositive': true},
    'avgProcessTime': {'value': '4.2 س', 'trend': '-18%', 'isPositive': true},
    'userSatisfaction': {'value': '4.6/5', 'trend': '+0.3', 'isPositive': true},
  };

  // ── 10. Weekly Activity Data (DEMO) ────────────────────────────────────────
  static const List<({String day, double percentage})> weeklyActivity = [
    (day: 'السبت', percentage: 62.0),
    (day: 'الأحد', percentage: 84.0),
    (day: 'الاثنين', percentage: 74.0),
    (day: 'الثلاثاء', percentage: 91.0),
    (day: 'الأربعاء', percentage: 78.0),
    (day: 'الخميس', percentage: 58.0),
  ];

  // ── 11. Most Used Services (DEMO) ──────────────────────────────────────────
  static const List<AdminServiceUsage> mostUsedServices = [
    AdminServiceUsage(name: 'الجدول الدراسي', visits: '1,824 زيارة', percentage: 34),
    AdminServiceUsage(name: 'الخريطة الذكية', visits: '1,306 زيارة', percentage: 25),
    AdminServiceUsage(name: 'التسجيل', visits: '987 زيارة', percentage: 19),
    AdminServiceUsage(name: 'المساعد الذكي', visits: '742 زيارة', percentage: 14),
  ];

  // ── 12. Admin Notifications (DEMO) ─────────────────────────────────────────
  static final List<AdminNotificationItem> notifications = [
    AdminNotificationItem(
      id: 'notif-001',
      title: 'طلبات جديدة',
      message: 'لديك 8 طلبات جديدة بحاجة للمراجعة من الطلاب وأعضاء الهيئة.',
      time: 'منذ 10 دقائق',
      type: AdminNotificationType.request,
    ),
    AdminNotificationItem(
      id: 'notif-002',
      title: 'بلاغ صيانة',
      message: 'تم تسجيل بلاغ جديد لعطل في جهاز العرض بالقاعة 4211.',
      time: 'منذ ساعة',
      type: AdminNotificationType.maintenance,
    ),
    AdminNotificationItem(
      id: 'notif-003',
      title: 'خدمة النقل',
      message: 'يوجد تحديث بانتظار النشر على جدول النقل الجامعي للمسار الجنوبي.',
      time: 'منذ ساعتين',
      type: AdminNotificationType.transport,
    ),
    AdminNotificationItem(
      id: 'notif-004',
      title: 'تنبيه نظام',
      message: 'تمت النسخة الاحتياطية الدورية لقواعد البيانات بنجاح في الساعة 06:10.',
      time: 'اليوم، 06:15 ص',
      type: AdminNotificationType.system,
      isRead: true,
    ),
    AdminNotificationItem(
      id: 'notif-005',
      title: 'حساب موقوف',
      message: 'تم إيقاف حساب الموظف EMP-071 لحين مراجعة الصلاحيات الإدارية.',
      time: 'منذ يومين',
      type: AdminNotificationType.account,
      isRead: true,
    ),
  ];

  static int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;
}
