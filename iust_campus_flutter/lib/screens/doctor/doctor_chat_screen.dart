import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_models.dart';
import '../../services/mock_chat_service.dart';
import '../../services/doctor_session.dart';
import '../../data/doctor_demo_data.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _lightBlue = Color(0xFFEAF4FB);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorChatScreen extends StatefulWidget {
  final String? doctorId;
  const DoctorChatScreen({super.key, this.doctorId});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'الكل'; // 'الكل', 'معالج دقيق', 'الاحتمالات والإشارات العشوائية'
  String _searchQuery = '';

  final List<String> _filters = [
    'الكل',
    'معالج دقيق',
    'الاحتمالات والإشارات العشوائية',
  ];

  @override
  void initState() {
    super.initState();
    final did = widget.doctorId ?? DoctorSession.currentDoctorId;
    MockChatService.ensureDoctorDemoData(did.isNotEmpty ? did : 'doctor-001');
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (msgDate == today.subtract(const Duration(days: 1))) {
      return 'أمس';
    } else if (msgDate == today.subtract(const Duration(days: 2))) {
      return 'منذ يومين';
    } else {
      return '${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final did = widget.doctorId ?? DoctorSession.currentDoctorId;
    final doctorId = did.isNotEmpty ? did : 'doctor-001';

    // 40-student stable roster
    final roster = DoctorDemoData.roster;

    // Filter students by search and course
    final filteredStudents = roster.where((student) {
      final nameMatches = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery);

      if (!nameMatches) return false;

      // Both courses currently share the same 40-student roster,
      // but if a specific course is selected, we keep the student list
      // filtered for that course context without visual duplication.
      return true;
    }).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: const DoctorBackButton(),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'محادثات الطلاب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              Text(
                'طلاب مقرراتك الحالية',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color: _textSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Search Bar & Filter Chips ─────────────────────────────
              Container(
                color: _white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم الطالب...',
                        hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _navy),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => _searchCtrl.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          final selected = _selectedFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedFilter = f),
                              labelStyle: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                color: selected ? _white : _textMain,
                              ),
                              backgroundColor: const Color(0xFFF1F5F9),
                              selectedColor: _navy,
                              checkmarkColor: _white,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: selected ? _navy : _border,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: _border),

              // ── Contact List of 40 Students ───────────────────────────
              Expanded(
                child: filteredStudents.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد طلاب يطابقون البحث',
                          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];

                          // Resolve active course name for this student based on filter
                          final courseName = _selectedFilter != 'الكل'
                              ? _selectedFilter
                              : (index % 2 == 0 ? 'معالج دقيق' : 'الاحتمالات والإشارات العشوائية');
                          final courseId = courseName == 'معالج دقيق'
                              ? 'doctor-course-001'
                              : 'doctor-course-002';

                          final conv = MockChatService.getOrCreateConversation(
                            studentId: student.id,
                            doctorId: doctorId,
                            doctorName: DoctorDemoData.profile.fullName,
                            courseId: courseId,
                            courseName: courseName,
                          );

                          final messages = MockChatService.getMessages(conv.conversationId);
                          final hasMessages = messages.isNotEmpty;
                          final lastMsg = hasMessages ? messages.last : null;
                          final unread = hasMessages &&
                              lastMsg?.senderRole == SenderRole.student &&
                              lastMsg?.readAt == null;

                          return _StudentConversationCard(
                            studentName: student.name,
                            studentId: student.id,
                            courseName: conv.courseName ?? courseName,
                            lastMessage: lastMsg?.body ?? 'بدء محادثة أكاديمية جديدة...',
                            lastTime: lastMsg != null ? _formatTimestamp(lastMsg.sentAt) : '',
                            hasUnread: unread,
                            onTap: () async {
                              if (lastMsg != null) {
                                lastMsg.readAt = DateTime.now();
                              }
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => _DoctorConversationView(
                                    conversation: conv,
                                    studentName: student.name,
                                    doctorId: doctorId,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
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

class _StudentConversationCard extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String courseName;
  final String lastMessage;
  final String lastTime;
  final bool hasUnread;
  final VoidCallback onTap;

  const _StudentConversationCard({
    required this.studentName,
    required this.studentId,
    required this.courseName,
    required this.lastMessage,
    required this.lastTime,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasUnread ? _blue.withValues(alpha: 0.4) : _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar with initial
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasUnread ? _navy : _blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    studentName.isNotEmpty ? studentName[0] : 'ط',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: hasUnread ? _white : _blue,
                    ),
                  ),
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
                              studentName,
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                                color: _textMain,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastTime.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              lastTime,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                color: hasUnread ? _blue : _textSub,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _lightBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                courseName,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                color: hasUnread ? _textMain : _textSub,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: _textSub, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorConversationView extends StatefulWidget {
  final Conversation conversation;
  final String studentName;
  final String doctorId;

  const _DoctorConversationView({
    required this.conversation,
    required this.studentName,
    required this.doctorId,
  });

  @override
  State<_DoctorConversationView> createState() => _DoctorConversationViewState();
}

class _DoctorConversationViewState extends State<_DoctorConversationView> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _messages = List.from(
        MockChatService.getMessages(widget.conversation.conversationId),
      );
    });
  }

  void _send() {
    final body = _ctrl.text.trim();
    if (body.isEmpty) return;

    MockChatService.sendMessage(
      conversationId: widget.conversation.conversationId,
      receiverUserId: widget.conversation.studentId,
      body: body,
      senderUserId: widget.doctorId,
      senderRole: SenderRole.doctor,
    );
    _ctrl.clear();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMsgTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: const DoctorBackButton(),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.studentName,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              if (widget.conversation.courseName != null)
                Text(
                  widget.conversation.courseName!,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد رسائل سابقة. يمكنك إرسال رسالة توجيهية الآن.',
                          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isDoctor = msg.senderRole == SenderRole.doctor;
                          return Align(
                            alignment: isDoctor
                                ? AlignmentDirectional.centerEnd
                                : AlignmentDirectional.centerStart,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.78,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDoctor ? _navy : _white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDoctor ? _navy : _border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isDoctor
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.body,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.5,
                                      color: isDoctor ? Colors.white : _textMain,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatMsgTime(msg.sentAt),
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: isDoctor
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : _textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Input Row ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: _white,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: GoogleFonts.cairo(fontSize: 13),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: _navy,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          tooltip: 'إرسال',
                          onPressed: _send,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
