// ── Feed data models ──────────────────────────────────────────────────────
// Feed API response models.

enum PostType { question, discussion, resource }

class FeedPost {
  final String id;
  final String studentId;
  final String studentName;
  final String authorRole;
  final String courseId;
  final String courseName;
  final String scope;
  final String? title;
  final String content;
  final PostType postType;
  final DateTime createdAt;
  int likesCount;
  int commentsCount;
  bool isFollowed;
  bool isLiked;

  FeedPost({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.authorRole = 'student',
    required this.courseId,
    required this.courseName,
    this.scope = 'course',
    this.title,
    required this.content,
    required this.postType,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isFollowed = false,
    this.isLiked = false,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
    id: json['id'] as String,
    studentId: (json['authorUserId'] ?? json['studentId']) as String,
    studentName: (json['authorName'] ?? json['studentName']) as String,
    authorRole: json['authorRole'] as String? ?? 'student',
    courseId: json['courseId']?.toString() ?? '',
    courseName: json['courseName'] as String? ?? 'ساحة الحرم الجامعي',
    scope: json['scope'] as String? ?? 'course',
    title: json['title'] as String?,
    content: json['content'] as String,
    postType: PostType.values.firstWhere(
      (e) => e.name == (json['postType'] as String),
      orElse: () => PostType.discussion,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    likesCount: (json['likesCount'] as int?) ?? 0,
    commentsCount: (json['commentsCount'] as int?) ?? 0,
    isFollowed: (json['isFollowed'] as bool?) ?? false,
    isLiked: (json['isLiked'] as bool?) ?? false,
  );
}

class FeedComment {
  final String id;
  final String postId;
  final String studentId;
  final String studentName;
  final String content;
  final DateTime createdAt;

  const FeedComment({
    required this.id,
    required this.postId,
    required this.studentId,
    required this.studentName,
    required this.content,
    required this.createdAt,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
    id: json['id'] as String,
    postId: json['postId'] as String,
    studentId: json['studentId'] as String,
    studentName: json['studentName'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class PostLike {
  final String id;
  final String postId;
  final String studentId;
  const PostLike({
    required this.id,
    required this.postId,
    required this.studentId,
  });
}

class PostFollow {
  final String id;
  final String postId;
  final String studentId;
  const PostFollow({
    required this.id,
    required this.postId,
    required this.studentId,
  });
}
