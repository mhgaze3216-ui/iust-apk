import '../models/feed_models.dart';
import '../services/api_client.dart';

class CampusFeedRepository {
  CampusFeedRepository._();

  static final instance = CampusFeedRepository._();

  List<Map<String, dynamic>> _list(Map<String, dynamic> response) {
    final value = response['data'];
    if (value is! List) {
      throw const FormatException('The API returned an invalid feed list.');
    }
    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'The API returned an invalid feed post.',
            );
          }
          return item;
        })
        .toList(growable: false);
  }

  Future<List<FeedPost>> getPosts({String? scope}) async {
    final response = await ApiClient.instance.get(
      '/feed',
      query: scope == null ? null : {'scope': scope},
    );
    return _list(response).map(FeedPost.fromJson).toList(growable: false);
  }

  Future<FeedPost> createPost({
    required String content,
    required PostType type,
    required String scope,
    String? courseId,
    String? title,
  }) async {
    final response = await ApiClient.instance.post(
      '/feed',
      body: {
        'scope': scope,
        if (scope == 'course' && courseId != null) 'courseId': courseId,
        'type': type.name,
        'title': title,
        'content': content,
      },
    );
    final post = response['data'] ?? response;
    if (post is! Map<String, dynamic>) {
      throw const FormatException('The API returned an invalid created post.');
    }
    return FeedPost.fromJson(post);
  }

  Future<void> toggleLike(FeedPost post) async {
    await ApiClient.instance.put(
      '/feed/${Uri.encodeComponent(post.id)}/reaction',
      body: {'liked': !post.isLiked, 'following': post.isFollowed},
    );
    if (post.isLiked) {
      if (post.likesCount > 0) post.likesCount--;
    } else {
      post.likesCount++;
    }
    post.isLiked = !post.isLiked;
  }

  Future<void> toggleFollow(FeedPost post) async {
    await ApiClient.instance.put(
      '/feed/${Uri.encodeComponent(post.id)}/reaction',
      body: {'liked': post.isLiked, 'following': !post.isFollowed},
    );
    post.isFollowed = !post.isFollowed;
  }
}
