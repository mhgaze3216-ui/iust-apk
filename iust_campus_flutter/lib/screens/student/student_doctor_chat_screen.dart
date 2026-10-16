import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/student_chat_repository.dart';
import '../../data/student_repository.dart';
import '../../models/chat_models.dart';
import '../../services/student_session.dart';

const _navy = Color(0xFF073B4C);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class StudentDoctorChatScreen extends StatefulWidget {
  final String? studentId;
  const StudentDoctorChatScreen({super.key, this.studentId});

  @override
  State<StudentDoctorChatScreen> createState() =>
      _StudentDoctorChatScreenState();
}

class _StudentDoctorChatScreenState extends State<StudentDoctorChatScreen> {
  final _repository = StudentChatRepository.instance;
  final _searchController = TextEditingController();
  Timer? _conversationTimer;
  List<ChatThread> _conversations = [];
  List<ChatPeer> _students = [];
  bool _loadingConversations = true;
  bool _loadingStudents = false;
  bool _conversationRequestInProgress = false;
  String? _conversationError;
  String? _studentSearchError;

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _conversationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadConversations(silent: true),
    );
  }

  @override
  void dispose() {
    _conversationTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (_conversationRequestInProgress) return;
    _conversationRequestInProgress = true;
    if (!silent && mounted) {
      setState(() {
        _loadingConversations = true;
        _conversationError = null;
      });
    }
    try {
      final conversations = await _repository.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _loadingConversations = false;
        _conversationError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load student conversations: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _conversationError = 'تعذر تحميل المحادثات حالياً.';
        _loadingConversations = false;
      });
    } finally {
      _conversationRequestInProgress = false;
    }
  }

  Future<void> _searchStudents(String value) async {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _students = [];
        _studentSearchError = query.isEmpty ? null : 'أدخل حرفين على الأقل.';
      });
      return;
    }
    setState(() {
      _loadingStudents = true;
      _studentSearchError = null;
    });
    try {
      final students = await _repository.searchStudents(query);
      if (!mounted) return;
      setState(() {
        _students = students;
        _loadingStudents = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to search student peers: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _students = [];
        _loadingStudents = false;
        _studentSearchError = 'تعذر البحث عن الطلاب حالياً.';
      });
    }
  }

  Future<void> _openStudent(ChatPeer peer) async {
    try {
      final thread = await _repository.startDirectConversation(peer);
      if (!mounted) return;
      await _openThread(thread);
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to open direct student conversation: $error\n$stackTrace',
      );
      if (!mounted) return;
      _showError('تعذر بدء المحادثة مع هذا الطالب.');
    }
  }

  Future<void> _openDoctor(
    ({String doctorId, String doctorName, String? courseId, String? courseName})
    doctor,
  ) async {
    if (doctor.courseId == null || doctor.courseName == null) {
      _showError('لا يوجد مقرر مشترك متاح لبدء المحادثة.');
      return;
    }
    try {
      final thread = await _repository.startDoctorConversation(
        doctorId: doctor.doctorId,
        doctorName: doctor.doctorName,
        courseId: doctor.courseId!,
        courseName: doctor.courseName!,
      );
      if (!mounted) return;
      await _openThread(thread);
    } catch (error, stackTrace) {
      debugPrint('Failed to open doctor conversation: $error\n$stackTrace');
      if (!mounted) return;
      _showError('تعذر بدء المحادثة مع الأستاذ.');
    }
  }

  Future<void> _openThread(ChatThread thread) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            _ConversationScreen(conversation: thread, studentId: _studentId),
      ),
    );
    if (mounted) _loadConversations();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = StudentRepository.getDoctors(_studentId);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'المحادثات',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: _navy,
            unselectedLabelColor: _textSub,
            indicatorColor: _navy,
            tabs: [
              Tab(text: 'محادثاتي'),
              Tab(text: 'الأساتذة'),
              Tab(text: 'الطلاب'),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: TabBarView(
            children: [
              _buildConversationList(),
              _buildDoctorList(doctors),
              _buildStudentDirectory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    if (_loadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_conversationError != null) {
      return _MessageState(
        message: _conversationError!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadConversations,
      );
    }
    if (_conversations.isEmpty) {
      return const _MessageState(message: 'لا توجد محادثات بعد.');
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _ContactCard(
            name: conversation.peerName,
            subtitle:
                conversation.courseName ??
                (conversation.peerUsername == null
                    ? _roleLabel(conversation.peerRole)
                    : '@${conversation.peerUsername} · '
                          '${_roleLabel(conversation.peerRole)}'),
            initial: conversation.peerName.isEmpty
                ? '?'
                : conversation.peerName.characters.first,
            unreadCount: conversation.unreadCount,
            onTap: () => _openThread(conversation),
          );
        },
      ),
    );
  }

  Widget _buildDoctorList(
    List<
      ({
        String doctorId,
        String doctorName,
        String? courseId,
        String? courseName,
      })
    >
    doctors,
  ) {
    if (doctors.isEmpty) {
      return const _MessageState(
        message: 'لا يوجد أساتذة مرتبطون بمقرراتك المسجلة حالياً.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('تواصل مع أستاذ من مقرراتك المسجلة.'),
        ),
        ...doctors.map(
          (doctor) => _ContactCard(
            name: doctor.doctorName,
            subtitle: doctor.courseName ?? 'أستاذ',
            initial: doctor.doctorName.isEmpty
                ? 'د'
                : doctor.doctorName.characters.first,
            onTap: () => _openDoctor(doctor),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDirectory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث باسم الطالب أو اسم المستخدم',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'بحث',
                onPressed: () => _searchStudents(_searchController.text),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: _white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
            ),
            onSubmitted: _searchStudents,
          ),
        ),
        if (_studentSearchError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _studentSearchError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        Expanded(
          child: _loadingStudents
              ? const Center(child: CircularProgressIndicator())
              : _students.isEmpty
              ? _MessageState(
                  message: _searchController.text.trim().length < 2
                      ? 'ابحث بحرفين على الأقل للعثور على طالب.'
                      : 'لا توجد نتائج مطابقة.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return _ContactCard(
                      name: student.fullName,
                      subtitle: '@${student.username}',
                      initial: student.fullName.isEmpty
                          ? 'ط'
                          : student.fullName.characters.first,
                      onTap: () => _openStudent(student),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ConversationScreen extends StatefulWidget {
  final ChatThread conversation;
  final String? studentId;
  const _ConversationScreen({required this.conversation, this.studentId});

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final _repository = StudentChatRepository.instance;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  Timer? _refreshTimer;
  bool _loading = true;
  bool _sending = false;
  bool _requestInProgress = false;
  String? _error;

  String get _currentUserId =>
      StudentRepository.getStudent(
        widget.studentId ?? StudentSession.currentStudentId,
      )?.userId ??
      StudentSession.currentProfile.userId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadMessages(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool forceLoading = false}) async {
    if (_requestInProgress) return;
    _requestInProgress = true;
    if (forceLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final messages = await _repository.getMessages(
        conversationId: widget.conversation.id,
        currentUserId: _currentUserId,
        peerId: widget.conversation.peerId,
      );
      await _repository.markRead(widget.conversation.id);
      if (!mounted) return;
      final changed = messages.length != _messages.length;
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      if (changed) _scrollToLatest();
    } catch (error, stackTrace) {
      debugPrint('Failed to load direct chat messages: $error\n$stackTrace');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذر تحميل الرسائل. تحقق من الاتصال وأعد المحاولة.';
        });
      }
    } finally {
      _requestInProgress = false;
    }
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(
        conversationId: widget.conversation.id,
        body: body,
      );
      _controller.clear();
      await _loadMessages();
      _scrollToLatest();
    } catch (error, stackTrace) {
      debugPrint('Failed to send direct chat message: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر إرسال الرسالة. حاول مرة أخرى.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل تريد حذف رسالتك؟ لا يمكن التراجع عن ذلك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.deleteMessage(
        conversationId: widget.conversation.id,
        messageId: message.messageId,
      );
      if (mounted) {
        setState(() {
          _messages.removeWhere((item) => item.messageId == message.messageId);
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to delete student chat message: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حذف الرسالة. حاول مرة أخرى.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.conversation.peerName,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            Text(
              widget.conversation.courseName ??
                  _roleLabel(widget.conversation.peerRole),
              style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث الرسائل',
            onPressed: () => _loadMessages(forceLoading: _messages.isEmpty),
            icon: const Icon(Icons.refresh_rounded, color: _navy),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            if (_error != null)
              MaterialBanner(
                content: Text(_error!),
                actions: [
                  TextButton(
                    onPressed: () => _loadMessages(forceLoading: true),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? const _MessageState(
                      message: 'لا توجد رسائل بعد، ابدأ المحادثة.',
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(14),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderUserId == _currentUserId;
                        return GestureDetector(
                          onLongPress: isMe
                              ? () => _deleteMessage(message)
                              : null,
                          child: _Bubble(message: message, isMe: isMe),
                        );
                      },
                    ),
            ),
            _ChatInput(
              controller: _controller,
              sending: _sending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.name,
    required this.subtitle,
    required this.initial,
    required this.onTap,
    this.unreadCount = 0,
  });

  final String name;
  final String subtitle;
  final String initial;
  final VoidCallback onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _navy,
          child: Text(
            initial,
            style: GoogleFonts.cairo(
              color: _white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.cairo(
            color: _textMain,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(color: _textSub, fontSize: 12),
        ),
        trailing: unreadCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: _navy,
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: _white, fontSize: 11),
                ),
              )
            : const Icon(Icons.chevron_left_rounded, color: _textSub),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: _textSub, fontSize: 14),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) => Align(
    alignment: isMe
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.body,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isMe ? _white : _textMain,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${message.sentAt.hour.toString().padLeft(2, '0')}:'
            '${message.sentAt.minute.toString().padLeft(2, '0')}'
            '${isMe ? ' · اضغط مطولاً للحذف' : ''}',
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: isMe ? Colors.white70 : _textSub,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      color: _white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
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
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: sending ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: _white,
            ),
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    ),
  );
}

String _roleLabel(SenderRole role) => switch (role) {
  SenderRole.student => 'طالب',
  SenderRole.doctor => 'أستاذ',
  SenderRole.staff => 'موظف',
  SenderRole.admin => 'إدارة',
  SenderRole.guest => 'زائر',
};
