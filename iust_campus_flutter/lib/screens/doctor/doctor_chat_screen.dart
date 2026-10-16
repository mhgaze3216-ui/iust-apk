import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/doctor_chat_repository.dart';
import '../../data/student_chat_repository.dart';
import '../../models/chat_models.dart';
import '../../services/doctor_session.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
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
  final _repository = DoctorChatRepository.instance;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _conversationTimer;
  List<ChatThread> _conversations = [];
  List<DoctorChatStudent> _students = [];
  bool _loadingConversations = true;
  bool _loadingStudents = false;
  String? _conversationError;
  String? _searchError;

  String get _doctorId =>
      widget.doctorId ?? DoctorSession.currentProfile.doctorId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _conversationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadConversations(silent: true),
    );
    _searchController.addListener(_scheduleSearch);
  }

  @override
  void dispose() {
    _conversationTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_scheduleSearch)
      ..dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _students = [];
        _searchError = query.isEmpty ? null : 'أدخل حرفين على الأقل.';
        _loadingStudents = false;
      });
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchStudents(query),
    );
  }

  Future<void> _searchStudents(String query) async {
    if (!mounted) return;
    setState(() {
      _loadingStudents = true;
      _searchError = null;
    });
    try {
      final students = await _repository.searchStudents(query);
      if (!mounted || query != _searchController.text.trim()) return;
      setState(() {
        _students = students;
        _loadingStudents = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to search doctor course students: $error\n$stackTrace',
      );
      if (!mounted) return;
      setState(() {
        _students = [];
        _loadingStudents = false;
        _searchError = 'تعذر البحث عن طلاب الشعب حالياً.';
      });
    }
  }

  Future<void> _loadConversations({bool silent = false}) async {
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
      debugPrint('Failed to load doctor conversations: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _loadingConversations = false;
        _conversationError = 'تعذر تحميل المحادثات حالياً.';
      });
    }
  }

  Future<void> _openStudent(DoctorChatStudent student) async {
    try {
      final conversation = await _repository.startConversation(student);
      if (!mounted) return;
      await _openConversation(conversation);
    } catch (error, stackTrace) {
      debugPrint('Failed to start doctor conversation: $error\n$stackTrace');
      if (!mounted) return;
      _showError('تعذر بدء المحادثة مع الطالب.');
    }
  }

  Future<void> _openConversation(ChatThread conversation) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _DoctorConversationScreen(
          conversation: conversation,
          doctorId: _doctorId,
        ),
      ),
    );
    if (mounted) _loadConversations(silent: true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const DoctorBackButton(),
        centerTitle: true,
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
              'طلاب مقرراتك المسجلة',
              style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
            ),
          ],
        ),
        bottom: const TabBar(
          labelColor: _navy,
          unselectedLabelColor: _textSub,
          indicatorColor: _navy,
          tabs: [
            Tab(text: 'المحادثات'),
            Tab(text: 'البحث عن طالب'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(children: [_conversationList(), _studentSearch()]),
      ),
    ),
  );

  Widget _conversationList() {
    if (_loadingConversations) {
      return Center(
        child: Text(
          'جار تحميل المحادثات...',
          style: GoogleFonts.cairo(color: _textSub),
        ),
      );
    }
    if (_conversationError != null) {
      return _EmptyState(
        message: _conversationError!,
        action: () => _loadConversations(),
      );
    }
    if (_conversations.isEmpty) {
      return const _EmptyState(message: 'لا توجد محادثات بعد.');
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _ConversationTile(
            name: conversation.peerName,
            subtitle: conversation.courseName ?? 'مقرر دراسي',
            preview: conversation.unreadCount > 0
                ? 'رسائل جديدة (${conversation.unreadCount})'
                : 'افتح المحادثة لعرض الرسائل',
            unreadCount: conversation.unreadCount,
            onTap: () => _openConversation(conversation),
          );
        },
      ),
    );
  }

  Widget _studentSearch() => Column(
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
              onPressed: () => _searchStudents(_searchController.text.trim()),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            filled: true,
            fillColor: _white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
          ),
          onSubmitted: _searchStudents,
        ),
      ),
      if (_searchError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _searchError!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      Expanded(
        child: _loadingStudents
            ? const Center(child: CircularProgressIndicator())
            : _students.isEmpty
            ? _EmptyState(
                message: _searchController.text.trim().length < 2
                    ? 'ابحث بحرفين على الأقل بين طلاب شعبك.'
                    : 'لا توجد نتائج مطابقة ضمن مقرراتك.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return _ConversationTile(
                    name: student.fullName,
                    subtitle: '${student.courseName} · @${student.username}',
                    preview: 'ابدأ محادثة مباشرة',
                    onTap: () => _openStudent(student),
                  );
                },
              ),
      ),
    ],
  );
}

class _DoctorConversationScreen extends StatefulWidget {
  const _DoctorConversationScreen({
    required this.conversation,
    required this.doctorId,
  });

  final ChatThread conversation;
  final String doctorId;

  @override
  State<_DoctorConversationScreen> createState() =>
      _DoctorConversationScreenState();
}

class _DoctorConversationScreenState extends State<_DoctorConversationScreen> {
  final _repository = DoctorChatRepository.instance;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _refreshTimer;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _requestInProgress = false;
  String? _error;

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
        currentUserId: widget.doctorId,
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
      debugPrint('Failed to load doctor chat messages: $error\n$stackTrace');
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
      debugPrint('Failed to send doctor chat message: $error\n$stackTrace');
      if (mounted) _showError('تعذر إرسال الرسالة. حاول مرة أخرى.');
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
      debugPrint('Failed to delete doctor chat message: $error\n$stackTrace');
      if (mounted) _showError('تعذر حذف الرسالة. حاول مرة أخرى.');
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            widget.conversation.peerName,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          Text(
            widget.conversation.courseName ?? 'محادثة طالب',
            style: GoogleFonts.cairo(fontSize: 11, color: _blue),
          ),
        ],
      ),
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
                ? const _EmptyState(
                    message: 'لا توجد رسائل بعد، ابدأ المحادثة.',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderUserId == widget.doctorId;
                      return GestureDetector(
                        onLongPress: isMe
                            ? () => _deleteMessage(message)
                            : null,
                        child: _MessageBubble(message: message, isMe: isMe),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Container(
              color: _white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.name,
    required this.subtitle,
    required this.preview,
    required this.onTap,
    this.unreadCount = 0,
  });

  final String name;
  final String subtitle;
  final String preview;
  final VoidCallback onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) => Card(
    color: _white,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _border),
    ),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: unreadCount > 0 ? _navy : _blue.withValues(alpha: .12),
        child: Text(
          name.isEmpty ? 'ط' : name.characters.first,
          style: TextStyle(
            color: unreadCount > 0 ? _white : _blue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: _textMain),
      ),
      subtitle: Text(
        '$subtitle\n$preview',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
      ),
      isThreeLine: true,
      trailing: unreadCount > 0
          ? CircleAvatar(
              radius: 12,
              backgroundColor: _blue,
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: _white, fontSize: 11),
              ),
            )
          : const Icon(Icons.chevron_left_rounded, color: _textSub),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) => Align(
    alignment: isMe
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .78,
      ),
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? _navy : _white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? null : Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.body,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              color: isMe ? _white : _textMain,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, this.action});

  final String message;
  final VoidCallback? action;

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
            style: GoogleFonts.cairo(color: _textSub),
          ),
          if (action != null)
            TextButton(onPressed: action, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}
