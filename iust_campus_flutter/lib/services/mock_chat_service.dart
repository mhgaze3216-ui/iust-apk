import '../models/chat_models.dart';
import '../data/student_repository.dart';
import '../data/doctor_demo_data.dart';
import 'student_session.dart';
import 'doctor_session.dart';
import 'administrative_staff_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock Chat Service
// Multi-student chat service resolving doctors and participants dynamically.
// Isolated demo conversation roster for Doctor area (doctor-001).
// Administrative Staff chat support for Students, Doctors, and Admissions/Registration.
// ─────────────────────────────────────────────────────────────────────────────

class AdministrativeChatContact {
  final String id;
  final String name;
  final String category; // 'students', 'doctors', 'staff'
  final String subtitle;
  final String conversationId;
  final String avatarInitials;

  const AdministrativeChatContact({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.conversationId,
    required this.avatarInitials,
  });
}

class MockChatService {
  // ── In-memory stores ───────────────────────────────────────────────────────
  static final _conversations = <Conversation>[];
  static final _messages      = <String, List<ChatMessage>>{}; // keyed by conversationId
  static final _inquiries     = <GuestInquiry>[];
  static bool _doctorDemoSeeded = false;

  // ── Doctor list for student ───────────────────────────────────────────────
  /// Returns the doctors associated with the student's courses.
  static List<({String doctorId, String doctorName, String? courseId, String? courseName})>
      getDoctorsForStudent([String? studentId]) {
    final sid = studentId ?? StudentSession.currentStudentId;
    return StudentRepository.getDoctors(sid);
  }

  static List<({String doctorId, String doctorName, String? courseId, String? courseName})>
      get availableDoctors => getDoctorsForStudent();

  // ── Seed Doctor Demo Data ─────────────────────────────────────────────────
  static void ensureDoctorDemoData([String doctorId = 'doctor-001']) {
    if (_doctorDemoSeeded) return;
    _doctorDemoSeeded = true;

    final now = DateTime.now();

    final demoSeeds = [
      (
        studentId: 'doctor001-student-001',
        studentName: 'حمزة السعدي',
        courseId: 'doctor-course-001',
        courseName: 'معالج دقيق',
        message: 'دكتور، هل موضوع المؤشرات داخل في الفاينل؟',
        time: DateTime(now.year, now.month, now.day, 9, 20),
        isRead: false,
      ),
      (
        studentId: 'doctor001-student-002',
        studentName: 'نائلة الحمد',
        courseId: 'doctor-course-001',
        courseName: 'معالج دقيق',
        message: 'هل يمكن توضيح موعد تسليم التكليف؟',
        time: DateTime(now.year, now.month, now.day, 10, 15),
        isRead: false,
      ),
      (
        studentId: 'doctor001-student-003',
        studentName: 'محمد غازي الجاسم',
        courseId: 'doctor-course-001',
        courseName: 'معالج دقيق',
        message: 'عندي سؤال عن مثال المقاطعات في المحاضرة.',
        time: DateTime(now.year, now.month, now.day, 11, 40),
        isRead: false,
      ),
      (
        studentId: 'doctor001-student-004',
        studentName: 'أنس الحموي',
        courseId: 'doctor-course-002',
        courseName: 'الاحتمالات والإشارات العشوائية',
        message: 'هل ستكون هناك جلسة مراجعة قبل الامتحان؟',
        time: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      (
        studentId: 'doctor001-student-015',
        studentName: 'سارة الجزار',
        courseId: 'doctor-course-002',
        courseName: 'الاحتمالات والإشارات العشوائية',
        message: 'دكتور، ممكن توضيح توزيع علامات الميد؟',
        time: DateTime(now.year, now.month, now.day, 8, 50),
        isRead: false,
      ),
      (
        studentId: 'doctor001-student-022',
        studentName: 'مايا الخطيب',
        courseId: 'doctor-course-001',
        courseName: 'معالج دقيق',
        message: 'هل السؤال الأخير من المحاضرة مطلوب؟',
        time: DateTime(now.year, now.month, now.day, 12, 10),
        isRead: true,
      ),
      (
        studentId: 'doctor001-student-025',
        studentName: 'كريم الحكيم',
        courseId: 'doctor-course-002',
        courseName: 'الاحتمالات والإشارات العشوائية',
        message: 'أرسلت التكليف، هل ظهر عندك؟',
        time: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      (
        studentId: 'doctor001-student-038',
        studentName: 'فرح النحاس',
        courseId: 'doctor-course-001',
        courseName: 'معالج دقيق',
        message: 'متى الساعات المكتبية هذا الأسبوع؟',
        time: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    for (final seed in demoSeeds) {
      final conv = Conversation(
        conversationId: 'conv-${seed.studentId}-$doctorId',
        studentId: seed.studentId,
        doctorId: doctorId,
        doctorName: DoctorDemoData.profile.fullName,
        courseId: seed.courseId,
        courseName: seed.courseName,
        createdAt: seed.time,
      );
      _conversations.add(conv);

      final msg = ChatMessage(
        messageId: 'seed-msg-${seed.studentId}',
        conversationId: conv.conversationId,
        senderUserId: seed.studentId,
        senderRole: SenderRole.student,
        receiverUserId: doctorId,
        body: seed.message,
        sentAt: seed.time,
        readAt: seed.isRead ? seed.time : null,
      );
      _messages[conv.conversationId] = [msg];
    }
  }

  // ── Conversations ───────────────────────────────────────────────────────────

  /// Get or create a conversation between a student and a doctor.
  static Conversation getOrCreateConversation({
    required String doctorId,
    required String doctorName,
    String? courseId,
    String? courseName,
    String? studentId,
  }) {
    ensureDoctorDemoData(doctorId);
    final sid = studentId ?? StudentSession.currentStudentId;
    final existing = _conversations.where(
      (c) => c.doctorId == doctorId && c.studentId == sid,
    );
    if (existing.isNotEmpty) return existing.first;

    final conv = Conversation(
      conversationId: 'conv-$sid-$doctorId',
      studentId: sid,
      doctorId: doctorId,
      doctorName: doctorName,
      courseId: courseId,
      courseName: courseName,
      createdAt: DateTime.now(),
    );
    _conversations.add(conv);
    _messages[conv.conversationId] = [];
    return conv;
  }

  /// Get all conversations for a doctor.
  static List<Conversation> getConversationsForDoctor([String? doctorId]) {
    final did = doctorId ?? DoctorSession.currentDoctorId;
    if (did.isEmpty) return [];
    ensureDoctorDemoData(did);
    return List.unmodifiable(_conversations.where((c) => c.doctorId == did).toList());
  }

  /// Get conversation by ID.
  static Conversation? getConversation(String conversationId) {
    for (final c in _conversations) {
      if (c.conversationId == conversationId) return c;
    }
    return null;
  }

  /// Get messages for a conversation.
  static List<ChatMessage> getMessages(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  /// Send a message.
  static ChatMessage sendMessage({
    required String conversationId,
    required String receiverUserId,
    required String body,
    String? senderUserId,
    SenderRole senderRole = SenderRole.student,
  }) {
    final userId = senderUserId ??
        (senderRole == SenderRole.doctor
            ? (DoctorSession.currentDoctorId.isNotEmpty
                ? DoctorSession.currentDoctorId
                : 'doctor-001')
            : (senderRole == SenderRole.staff
                ? (AdministrativeStaffSession.hasActiveSession
                    ? AdministrativeStaffSession.currentUserNumber
                    : 'EMP-071')
                : StudentSession.currentProfile.userId));
    final msg = ChatMessage(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderUserId: userId,
      senderRole: senderRole,
      receiverUserId: receiverUserId,
      body: body,
      sentAt: DateTime.now(),
    );
    _messages.putIfAbsent(conversationId, () => []).add(msg);
    return msg;
  }

  // ── Administrative Staff Chat Roster & Messages ──────────────────────────

  static bool _administrativeStaffDemoSeeded = false;

  static final List<AdministrativeChatContact> _administrativeContacts = [
    // 1. الطلاب
    const AdministrativeChatContact(
      id: 'student-dentistry-001',
      name: 'حمزة السعدي',
      category: 'students',
      subtitle: 'طب الأسنان • السنة الثالثة (202410142)',
      conversationId: 'admin-staff-chat-hamza',
      avatarInitials: 'ح',
    ),
    const AdministrativeChatContact(
      id: 'student-informatics-002',
      name: 'مصطفى الأحمد',
      category: 'students',
      subtitle: 'هندسة المعلوماتية • السنة الثانية (202410285)',
      conversationId: 'admin-staff-chat-mustafa',
      avatarInitials: 'م',
    ),
    const AdministrativeChatContact(
      id: 'student-pharmacy-003',
      name: 'لين العلي',
      category: 'students',
      subtitle: 'كلية الصيدلة • السنة الرابعة (202310051)',
      conversationId: 'admin-staff-chat-leen',
      avatarInitials: 'ل',
    ),

    // 2. الدكاترة
    const AdministrativeChatContact(
      id: 'doctor-bashir',
      name: 'د. بشير عرنوس',
      category: 'doctors',
      subtitle: 'عميد كلية هندسة المعلوماتية',
      conversationId: 'admin-staff-chat-dr-bashir',
      avatarInitials: 'ب',
    ),
    const AdministrativeChatContact(
      id: 'doctor-miqdad',
      name: 'د. محمد مقداد',
      category: 'doctors',
      subtitle: 'أستاذ مقرر • كلية طب الأسنان',
      conversationId: 'admin-staff-chat-dr-miqdad',
      avatarInitials: 'م',
    ),
    const AdministrativeChatContact(
      id: 'doctor-bassam',
      name: 'د. بسام ديب',
      category: 'doctors',
      subtitle: 'رئيس قسم • كلية الهندسة',
      conversationId: 'admin-staff-chat-dr-bassam',
      avatarInitials: 'د',
    ),

    // 3. القبول والتسجيل
    const AdministrativeChatContact(
      id: 'staff-ali',
      name: 'أ. محمود العلي',
      category: 'staff',
      subtitle: 'رئيس دائرة القبول والتسجيل (EMP-071)',
      conversationId: 'admin-staff-chat-staff-ali',
      avatarInitials: 'ع',
    ),
    const AdministrativeChatContact(
      id: 'staff-khaled',
      name: 'أ. ريم الخالد',
      category: 'staff',
      subtitle: 'مسؤولة الوثائق والسجلات الأكاديمية (EMP-084)',
      conversationId: 'admin-staff-chat-staff-khaled',
      avatarInitials: 'ر',
    ),
    const AdministrativeChatContact(
      id: 'staff-radwan',
      name: 'م. أنس رضوان',
      category: 'staff',
      subtitle: 'مسؤول الجداول والشعب الدراسية (EMP-092)',
      conversationId: 'admin-staff-chat-staff-radwan',
      avatarInitials: 'أ',
    ),
  ];

  /// Initialize demo messages for administrative staff conversations
  static void ensureAdministrativeStaffDemoData() {
    if (_administrativeStaffDemoSeeded) return;
    _administrativeStaffDemoSeeded = true;

    final now = DateTime.now();

    final initialMessages = <String, List<({String senderId, SenderRole role, String text, int minutesAgo})>>{
      'admin-staff-chat-hamza': [
        (
          senderId: 'student-dentistry-001',
          role: SenderRole.student,
          text: 'مرحباً، أود الاستفسار عن موعد تثبيت التسجيل وسداد الرسوم للفصل القادم.',
          minutesAgo: 45,
        ),
      ],
      'admin-staff-chat-mustafa': [
        (
          senderId: 'student-informatics-002',
          role: SenderRole.student,
          text: 'السلام عليكم، هل يمكن تعديل شعبة مقرر البرمجة بسبب تعارض مع الجدول؟',
          minutesAgo: 120,
        ),
      ],
      'admin-staff-chat-leen': [
        (
          senderId: 'student-pharmacy-003',
          role: SenderRole.student,
          text: 'أرجو تزويدي بمصدقة دوام رسمية مصدقة من عمادة القبول والتسجيل.',
          minutesAgo: 240,
        ),
      ],
      'admin-staff-chat-dr-bashir': [
        (
          senderId: 'doctor-bashir',
          role: SenderRole.doctor,
          text: 'يرجى تزويدنا بقوائم الطلاب المسجلين المحدثة لمقرر المعالج الدقيق.',
          minutesAgo: 30,
        ),
      ],
      'admin-staff-chat-dr-miqdad': [
        (
          senderId: 'doctor-miqdad',
          role: SenderRole.doctor,
          text: 'تم تسليم جداول درجات الأعمال الفصلية لقسم الامتحانات والقبول.',
          minutesAgo: 90,
        ),
      ],
      'admin-staff-chat-dr-bassam': [
        (
          senderId: 'doctor-bassam',
          role: SenderRole.doctor,
          text: 'هل تم حجز القاعة الكبرى للاختبارات النصفية الأسبوع القادم؟',
          minutesAgo: 180,
        ),
      ],
      'admin-staff-chat-staff-ali': [
        (
          senderId: 'staff-ali',
          role: SenderRole.staff,
          text: 'تم تدقيق الدفعة الأولى من طلبات إيقاف التسجيل واعتمادها بنجاح.',
          minutesAgo: 15,
        ),
      ],
      'admin-staff-chat-staff-khaled': [
        (
          senderId: 'staff-khaled',
          role: SenderRole.staff,
          text: 'وصلتنا 15 معاملة كشف علامات جديدة بانتظار تصديق الإدارة.',
          minutesAgo: 60,
        ),
      ],
      'admin-staff-chat-staff-radwan': [
        (
          senderId: 'staff-radwan',
          role: SenderRole.staff,
          text: 'تم تحديث جداول القاعات والمختبرات في المبنى B وإرسالها للأقسام.',
          minutesAgo: 140,
        ),
      ],
    };

    for (final entry in initialMessages.entries) {
      final list = <ChatMessage>[];
      for (final m in entry.value) {
        list.add(
          ChatMessage(
            messageId: 'admin-msg-${DateTime.now().millisecondsSinceEpoch}-${list.length}',
            conversationId: entry.key,
            senderUserId: m.senderId,
            senderRole: m.role,
            receiverUserId: 'EMP-071',
            body: m.text,
            sentAt: now.subtract(Duration(minutes: m.minutesAgo)),
          ),
        );
      }
      _messages[entry.key] = list;
    }
  }

  /// Get administrative contacts by category ('students', 'doctors', 'staff')
  static List<AdministrativeChatContact> getAdministrativeContacts(String category) {
    ensureAdministrativeStaffDemoData();
    return _administrativeContacts.where((c) => c.category == category).toList();
  }

  /// Get the latest message for a conversation if any
  static ChatMessage? getLatestMessage(String conversationId) {
    final msgs = _messages[conversationId];
    if (msgs == null || msgs.isEmpty) return null;
    return msgs.last;
  }

  // ── Guest inquiries ─────────────────────────────────────────────────────────

  /// Submit a guest inquiry.
  static GuestInquiry submitInquiry({
    String? guestName,
    String? contactInfo,
    String? email,
    String? phone,
    String? category,
    String? subject,
    String? attachmentName,
    required String message,
  }) {
    final refNum = (_inquiries.length + 1).toString().padLeft(3, '0');
    final inquiry = GuestInquiry(
      inquiryId: 'INQ-GUEST-$refNum',
      guestName: (guestName == null || guestName.trim().isEmpty) ? 'زائر' : guestName.trim(),
      contactInfo: contactInfo ?? email ?? phone,
      email: email,
      phone: phone,
      category: category ?? 'استفسار عام',
      subject: subject,
      attachmentName: attachmentName,
      message: message,
      createdAt: DateTime.now(),
    );
    _inquiries.add(inquiry);
    return inquiry;
  }

  static List<GuestInquiry> get allInquiries => List.unmodifiable(_inquiries);
}
