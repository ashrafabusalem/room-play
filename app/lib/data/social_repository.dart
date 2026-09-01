import '../core/api/api_client.dart';

class SocialProfile {
  const SocialProfile({
    required this.id,
    required this.name,
    required this.level,
    required this.followers,
    required this.following,
    this.bio,
    this.avatarUrl,
    this.isMe = false,
    this.isFollowing = false,
    this.isBlocked = false,
    this.blockedBy = false,
    this.dmPrivacy = 'everyone',
  });

  final String id;
  final String name;
  final int level;
  final String? bio;
  final String? avatarUrl;
  final int followers;
  final int following;
  final bool isMe;
  final bool isFollowing;
  final bool isBlocked;
  final bool blockedBy;
  final String dmPrivacy;

  factory SocialProfile.fromJson(Map<String, dynamic> json) => SocialProfile(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    level: (json['level'] as num?)?.toInt() ?? 1,
    bio: json['bio'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    followers: (json['followers_count'] as num?)?.toInt() ?? 0,
    following: (json['following_count'] as num?)?.toInt() ?? 0,
    isMe: json['is_me'] as bool? ?? false,
    isFollowing: json['is_following'] as bool? ?? false,
    isBlocked: json['is_blocked'] as bool? ?? false,
    blockedBy: json['blocked_by'] as bool? ?? false,
    dmPrivacy: json['dm_privacy'] as String? ?? 'everyone',
  );
}

class SocialRepository {
  SocialRepository(this._api);
  final ApiClient _api;

  Future<SocialProfile> profile(String id) async {
    final json = await _api.get('/profiles/$id');
    return SocialProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String bio,
    required String dmPrivacy,
  }) async {
    final json = await _api.patch(
      '/profile',
      body: {'name': name, 'bio': bio, 'dm_privacy': dmPrivacy},
    );
    return json['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAvatar(
    List<int> bytes,
    String filename,
  ) async {
    final json = await _api.postMultipart(
      '/profile/avatar',
      bytes: bytes,
      filename: filename,
    );
    return json['user'] as Map<String, dynamic>;
  }

  Future<SocialProfile> follow(String id, bool follow) async {
    final json = follow
        ? await _api.post('/profiles/$id/follow')
        : await _api.delete('/profiles/$id/follow');
    return SocialProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  Future<void> block(String id, bool block) => block
      ? _api.post('/profiles/$id/block').then((_) {})
      : _api.delete('/profiles/$id/block').then((_) {});

  Future<void> report(String id, String reason, String details) => _api
      .post(
        '/profiles/$id/reports',
        body: {'reason': reason, 'details': details},
      )
      .then((_) {});
}
