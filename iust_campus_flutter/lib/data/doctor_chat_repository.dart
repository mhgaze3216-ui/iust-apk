import '../models/chat_models.dart';
import 'student_chat_repository.dart';
import '../services/api_client.dart';

class DoctorChatStudent {
  const DoctorChatStudent({
    required this.id,
    required this.username,
    required this.fullName,
    required this.courseId,
    required this.courseName,
  });

  final String id;
  final String username;
  final String fullName;
  final String courseId;
  final String courseName;
}

class DoctorChatRepository {
  DoctorChatRepository._();

  static final instance = DoctorChatRepository._();

  List<Map<String, dynamic>> _list(Map<String, dynamic> response, String name) {
    final value = response['data'];
    if (value is! List) {
      throw FormatException('The API returned an invalid $name list.');
    }
    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException('The API returned an invalid $name item.');
          }
          return item;
        })
        .toList(growable: false);
  }

  String _requiredText(Object? value, String field) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      throw FormatException('The API omitted the required $field field.');
    }
    return text;
  }

  DoctorChatStudent _student(Map<String, dynamic> row) => DoctorChatStudent(
    id: _requiredText(row['studentId'], 'student ID'),
    username: _requiredText(row['studentUsername'], 'student username'),
    fullName: _requiredText(row['studentName'], 'student name'),
    courseId: _requiredText(row['courseId'], 'course ID'),
    courseName: _requiredText(row['courseName'], 'course name'),
  );

  ChatThread _thread(Map<String, dynamic> row) => ChatThread(
    id: _requiredText(row['id'], 'conversation ID'),
    peerId: _requiredText(row['studentId'], 'student ID'),
    peerName: _requiredText(row['studentName'], 'student name'),
    peerRole: SenderRole.student,
    peerUsername: row['studentUsername']?.toString(),
    courseId: row['courseId']?.toString(),
    courseName: row['courseName']?.toString(),
    unreadCount: (row['unreadCount'] as num?)?.toInt() ?? 0,
  );

  Future<List<DoctorChatStudent>> searchStudents(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return const [];
    final response = await ApiClient.instance.get(
      '/doctors/me/students',
      query: {'q': normalized},
    );
    return _list(response, 'student').map(_student).toList(growable: false);
  }

  Future<List<ChatThread>> getConversations() async {
    final response = await ApiClient.instance.get('/doctors/me/conversations');
    return _list(response, 'conversation').map(_thread).toList(growable: false);
  }

  Future<ChatThread> startConversation(DoctorChatStudent student) async {
    final response = await ApiClient.instance.post(
      '/doctors/me/conversations',
      body: {'studentId': student.id, 'courseId': student.courseId},
    );
    return _thread(response);
  }

  Future<List<ChatMessage>> getMessages({
    required String conversationId,
    required String currentUserId,
    required String peerId,
  }) async {
    final response = await ApiClient.instance.get(
      '/doctors/me/conversations/${Uri.encodeComponent(conversationId)}/messages',
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
            senderRole: senderId == currentUserId
                ? SenderRole.doctor
                : SenderRole.student,
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
      '/doctors/me/conversations/${Uri.encodeComponent(conversationId)}/messages',
      body: {'body': body},
    );
  }

  Future<void> markRead(String conversationId) async {
    await ApiClient.instance.patch(
      '/doctors/me/conversations/${Uri.encodeComponent(conversationId)}/read',
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
