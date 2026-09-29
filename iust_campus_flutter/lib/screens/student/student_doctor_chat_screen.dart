import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_models.dart';
import '../../services/mock_chat_service.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';

const _navy      = Color(0xFF073B4C);
const _lightBg   = Color(0xFFF6F9FC);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

// ── Doctor list screen ─────────────────────────────────────────────────────
class StudentDoctorChatScreen extends StatelessWidget {
  final String? studentId;
  const StudentDoctorChatScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final doctors = MockChatService.getDoctorsForStudent(sid);
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'التواصل مع الأساتذة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('اختر الأستاذ الذي تريد مراسلته:',
                style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
            const SizedBox(height: 12),
            ...doctors.map((d) => _DoctorCard(
              studentId: sid,
              doctorId: d.doctorId,
              doctorName: d.doctorName,
              courseId: d.courseId,
              courseName: d.courseName,
            )),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.studentId,
    required this.doctorId, required this.doctorName,
    this.courseId, this.courseName,
  });
  final String studentId;
  final String doctorId, doctorName;
  final String? courseId, courseName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final conv = MockChatService.getOrCreateConversation(
          studentId: studentId,
          doctorId: doctorId, doctorName: doctorName,
          courseId: courseId, courseName: courseName,
        );
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => _ConversationScreen(
            conversation: conv,
            studentId: studentId,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46, alignment: Alignment.center,
            decoration: const BoxDecoration(color: _navy, shape: BoxShape.circle),
            child: Text(doctorName.isNotEmpty ? doctorName[0] : 'د',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: _white)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctorName, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
            if (courseName != null)
              Text(courseName!, style: GoogleFonts.cairo(fontSize: 12, color: _textSub), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.chevron_left_rounded, color: _textSub, size: 20),
        ]),
      ),
    );
  }
}

// ── Conversation screen ────────────────────────────────────────────────────
class _ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  final String? studentId;
  const _ConversationScreen({required this.conversation, this.studentId});
  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _messages = [];

  String get _currentUserId {
    final sid = widget.studentId ?? StudentSession.currentStudentId;
    return StudentRepository.getStudent(sid)?.userId ?? StudentSession.currentProfile.userId;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _load() => setState(() =>
      _messages = List.from(MockChatService.getMessages(widget.conversation.conversationId)));

  void _send() {
    final body = _ctrl.text.trim();
    if (body.isEmpty) return;
    MockChatService.sendMessage(
      conversationId: widget.conversation.conversationId,
      receiverUserId: widget.conversation.doctorId,
      body: body,
      senderUserId: _currentUserId,
    );
    _ctrl.clear();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, widget.conversation.doctorName,
          subtitle: widget.conversation.courseName),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // messages
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('لا توجد رسائل بعد، ابدأ المحادثة.',
                    style: GoogleFonts.cairo(fontSize: 13, color: _textSub)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _Bubble(
                      message: _messages[i],
                      isMe: _messages[i].senderUserId == _currentUserId,
                    ),
                  ),
          ),
          // input
          _ChatInput(controller: _ctrl, onSend: _send),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _navy : _white,
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(16),
            bottomRight: Radius.circular(isMe ? 4 : 16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
          ),
          border: isMe ? null : Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(message.body,
              style: GoogleFonts.cairo(fontSize: 13, color: isMe ? _white : _textMain, height: 1.5)),
          const SizedBox(height: 3),
          Text(_fmtTime(message.sentAt),
              style: GoogleFonts.cairo(fontSize: 10, color: isMe ? Colors.white54 : _textSub)),
        ]),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Container(
          color: _white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _lightBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 42, height: 42, alignment: Alignment.center,
              decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.send_rounded, color: _white, size: 18),
            ),
          ),
        ]),
      ),
    );
}

PreferredSizeWidget _appBar(BuildContext ctx, String title, {String? subtitle}) => AppBar(
      backgroundColor: _white, elevation: 0, surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
      centerTitle: true,
      title: subtitle != null
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: _textMain)),
              Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: _textSub), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])
          : Text(title, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: _border)),
    );
