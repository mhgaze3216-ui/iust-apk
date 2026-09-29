import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/chat_models.dart';
import '../../../services/mock_chat_service.dart';

const _navy = Color(0xFF073B4C);
const _gold = Color(0xFFF5B82E);
const _lightBg = Color(0xFFF6F9FC);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

/// Administrative Staff chat interface with 3 tabs:
/// 1. الطلاب (Students)
/// 2. الدكاترة (Doctors)
/// 3. القبول والتسجيل (Admissions & Registration)
class AdministrativeChatScreen extends StatefulWidget {
  const AdministrativeChatScreen({super.key});

  @override
  State<AdministrativeChatScreen> createState() => _AdministrativeChatScreenState();
}

class _AdministrativeChatScreenState extends State<AdministrativeChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    MockChatService.ensureAdministrativeStaffDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _navy, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'المحادثات الإدارية',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: _navy,
                indicatorWeight: 3,
                labelColor: _navy,
                unselectedLabelColor: _textSub,
                labelStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.cairo(fontSize: 13),
                tabs: const [
                  Tab(text: 'الطلاب'),
                  Tab(text: 'الدكاترة'),
                  Tab(text: 'القبول والتسجيل'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContactsList('students'),
            _buildContactsList('doctors'),
            _buildContactsList('staff'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(String category) {
    final contacts = MockChatService.getAdministrativeContacts(category);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final lastMsg = MockChatService.getLatestMessage(contact.conversationId);

        Color avatarColor = _gold;
        if (category == 'doctors') avatarColor = const Color(0xFF0F6CBD);
        if (category == 'staff') avatarColor = const Color(0xFF16A34A);

        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdministrativeChatThreadScreen(contact: contact),
              ),
            );
            setState(() {});
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    contact.avatarInitials,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Contact info + message preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: _navy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastMsg != null)
                            Text(
                              _formatTime(lastMsg.sentAt),
                              style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.subtitle,
                        style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMsg != null ? lastMsg.body : 'انقر لبدء المحادثة...',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: lastMsg != null ? _textMain : _textSub,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_left_rounded, color: _textSub, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} د';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} س';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }
}

/// Direct chat thread screen for Administrative Staff
class AdministrativeChatThreadScreen extends StatefulWidget {
  final AdministrativeChatContact contact;

  const AdministrativeChatThreadScreen({super.key, required this.contact});

  @override
  State<AdministrativeChatThreadScreen> createState() =>
      _AdministrativeChatThreadScreenState();
}

class _AdministrativeChatThreadScreenState
    extends State<AdministrativeChatThreadScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _messages = MockChatService.getMessages(widget.contact.conversationId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();
    MockChatService.sendMessage(
      conversationId: widget.contact.conversationId,
      receiverUserId: widget.contact.id,
      body: text,
      senderRole: SenderRole.staff,
    );

    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _navy, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _navy,
                child: Text(
                  widget.contact.avatarInitials,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.contact.subtitle,
                      style: GoogleFonts.cairo(fontSize: 10.5, color: _textSub),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _border),
          ),
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isStaff = msg.senderRole == SenderRole.staff;

                  return Align(
                    alignment: isStaff ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isStaff ? _navy : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isStaff ? Radius.zero : const Radius.circular(16),
                          bottomRight: isStaff ? const Radius.circular(16) : Radius.zero,
                        ),
                        border: isStaff ? null : Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg.body,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isStaff ? Colors.white : _textMain,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              color: isStaff ? Colors.white70 : _textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                top: false,
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
                          controller: _msgCtrl,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك هنا...',
                            hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: GoogleFonts.cairo(fontSize: 13),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: _navy,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
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
}
