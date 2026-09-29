// ── Feed data models ──────────────────────────────────────────────────────
// Replace mock data with real API responses when backend is ready.
// Each factory constructor is designed to accept a JSON map from NestJS.

enum PostType { question, discussion, resource }

class FeedPost {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
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
    required this.courseId,
    required this.courseName,
    this.title,
    required this.content,
    required this.postType,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isFollowed = false,
    this.isLiked = false,
  });

  // TODO: replace body with real JSON parsing when backend is connected
  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        studentName: json['studentName'] as String,
        courseId: json['courseId'] as String,
        courseName: json['courseName'] as String,
        title: json['title'] as String?,
        content: json['content'] as String,
        postType: PostType.values.firstWhere(
            (e) => e.name == (json['postType'] as String),
            orElse: () => PostType.discussion),
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
  const PostLike(
      {required this.id, required this.postId, required this.studentId});
}

class PostFollow {
  final String id;
  final String postId;
  final String studentId;
  const PostFollow(
      {required this.id, required this.postId, required this.studentId});
}
