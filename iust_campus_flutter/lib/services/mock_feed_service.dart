import '../models/feed_models.dart';
import '../data/real_student_mock_data.dart';
import '../data/student_repository.dart';
import 'student_session.dart';

// ── Mock Feed Service ─────────────────────────────────────────────────────
// Multi-student feed service resolving courses and authorship dynamically.
// TODO: Replace with real HTTP calls to NestJS /feed endpoints.

class MockFeedService {
  /// Enrolled courses for student.
  static List<(String, String)> getEnrolledCourses([String? studentId]) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final tuples = StudentRepository.getAvailableCourseTuples(sid);
    return tuples.map((c) => (c.id, c.name)).toList();
  }

  static List<(String, String)> get enrolledCourses => getEnrolledCourses();

  static final _posts = <FeedPost>[...kDemoFeedPosts];

  // ── Public API (mirrors what real service would expose) ─────────────────

  /// Returns all posts from enrolled courses, sorted newest first.
  static Future<List<FeedPost>> getPostsForStudent([String? studentId]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sid = studentId ?? StudentSession.currentStudentId;
    final enrolledTuples = StudentRepository.getAvailableCourseTuples(sid);
    final enrolledCourseIds = enrolledTuples.map((c) => c.id).toSet();
    return _posts.where((p) => enrolledCourseIds.contains(p.courseId)).toList();
  }

  /// Returns recent posts — used on Home preview.
  static Future<List<FeedPost>> getRecentPosts({int limit = 2, String? studentId}) async {
    final all = await getPostsForStudent(studentId);
    return all.take(limit).toList();
  }

  /// Toggle like on a post.
  static Future<void> toggleLike(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    if (post.isLiked) {
      post.isLiked = false;
      post.likesCount--;
    } else {
      post.isLiked = true;
      post.likesCount++;
    }
  }

  /// Toggle follow on a post.
  static Future<void> toggleFollow(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.isFollowed = !post.isFollowed;
  }

  /// Add a new post to the local mock list.
  static Future<FeedPost> createPost({
    required String courseId,
    required String courseName,
    required String content,
    required PostType postType,
    String? title,
    String? studentId,
  }) async {
    final sid = studentId ?? StudentSession.currentStudentId;
    final profile = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;
    final newPost = FeedPost(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      studentId: profile.studentId,
      studentName: profile.firstName,
      courseId: courseId,
      courseName: courseName,
      title: title,
      content: content,
      postType: postType,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    return newPost;
  }
}
