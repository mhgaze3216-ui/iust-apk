import '../models/chat_models.dart';
import '../services/api_client.dart';

class ChatPeer {
  const ChatPeer({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String username;
  final String fullName;
  final SenderRole role;
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerRole,
    this.peerUsername,
    this.courseId,
    this.courseName,
    this.unreadCount = 0,
  });

  final String id;
  final String peerId;
  final String peerName;
  final SenderRole peerRole;
  final String? peerUsername;
  final String? courseId;
  final String? courseName;
  final int unreadCount;
}

class StudentChatRepository {
  StudentChatRepository._();

  static final _instance = StudentChatRepository._();
  static StudentChatRepository get instance => _instance;

  Map<String, dynamic> _map(Object? value, String label) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('The API returned an invalid $label object.');
  }

  List<Map<String, dynamic>> _list(
    Map<String, dynamic> response,
    String label,
  ) {
    final rows = response['data'];
    if (rows is! List) {
      throw FormatException('The API returned an invalid $label list.');
    }
    return rows.map((row) => _map(row, label)).toList(growable: false);
  }

  String _requiredText(Object? value, String field) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      throw FormatException('The API omitted the required $field field.');
    }
    return text;
  }

  SenderRole _role(Object? value) {
    final name = value?.toString();
    for (final role in SenderRole.values) {
      if (role.name == name) return role;
    }
    throw FormatException('The API returned an unsupported chat role: $name.');
  }

  ChatPeer _peer(Map<String, dynamic> row) => ChatPeer(
    id: _requiredText(row['id'], 'student ID'),
    username: _requiredText(row['username'], 'student username'),
    fullName: _requiredText(row['fullName'], 'student name'),
    role: SenderRole.student,
  );

  ChatThread _thread(Map<String, dynamic> row) => ChatThread(
    id: _requiredText(row['id'], 'conversation ID'),
    peerId: _requiredText(row['peerId'] ?? row['doctorId'], 'peer ID'),
    peerName: _requiredText(row['peerName'] ?? row['doctorName'], 'peer name'),
    peerRole: _role(row['peerRole'] ?? 'doctor'),
    peerUsername: row['peerUsername']?.toString(),
    courseId: row['courseId']?.toString(),
    courseName: row['courseName']?.toString(),
    unreadCount: (row['unreadCount'] as num?)?.toInt() ?? 0,
  );

  Future<List<ChatPeer>> searchStudents(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return const [];
    final response = await ApiClient.instance.get(
      '/students/me/peers',
      query: {'q': normalized},
    );
    return _list(response, 'student').map(_peer).toList(growable: false);
  }

  Future<List<ChatThread>> getConversations() async {
    final response = await ApiClient.instance.get('/students/me/conversations');
    return _list(response, 'conversation').map(_thread).toList(growable: false);
  }

  Future<ChatThread> startDirectConversation(ChatPeer peer) async {
    final response = await ApiClient.instance.post(
      '/students/me/direct-conversations',
      body: {'studentId': peer.id},
    );
    return _thread(response);
  }

  Future<ChatThread> startDoctorConversation({
    required String doctorId,
    required String doctorName,
    required String courseId,
    required String courseName,
  }) async {
    final response = await ApiClient.instance.post(
      '/students/me/conversations',
      body: {'doctorId': doctorId, 'courseId': courseId},
    );
    return _thread({
      ...response,
      'peerId': response['peerId'] ?? doctorId,
      'peerName': response['peerName'] ?? doctorName,
      'peerRole': response['peerRole'] ?? 'doctor',
      'courseName': response['courseName'] ?? courseName,
    });
  }

  Future<List<ChatMessage>> getMessages({
    required String conversationId,
    required String currentUserId,
    required String peerId,
  }) async {
    final response = await ApiClient.instance.get(
      '/students/me/conversations/${Uri.encodeComponent(conversationId)}/messages',
    );
    return _list(response, 'message')
        .map((row) {
          final senderId = _requiredText(row['senderUserId'], 'message sender');
          return ChatMessage(
            messageId: _requiredText(row['id'], 'message ID'),
            conversationId: _requiredText(
              row['conversationId'],
              'message conversation ID',
            ),
            senderUserId: senderId,
            senderRole: _role(row['senderRole']),
            receiverUserId: senderId == currentUserId ? peerId : currentUserId,
            body: _requiredText(row['body'], 'message body'),
            sentAt: DateTime.parse(
              _requiredText(row['sentAt'], 'message time'),
            ),
          );
        })
        .toList(growable: false);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    await ApiClient.instance.post(
      '/students/me/conversations/${Uri.encodeComponent(conversationId)}/messages',
      body: {'body': body},
    );
  }

  Future<void> markRead(String conversationId) async {
    await ApiClient.instance.patch(
      '/students/me/conversations/${Uri.encodeComponent(conversationId)}/read',
    );
  }

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await ApiClient.instance.delete(
      '/conversations/${Uri.encodeComponent(conversationId)}/messages/'
      '${Uri.encodeComponent(messageId)}',
    );
  }
}
