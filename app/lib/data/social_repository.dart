import '../core/api/api_client.dart';
import 'models.dart';

class FriendRequestItem {
  const FriendRequestItem({required this.id, required this.user});
  final String id;
  final AppUser user;
  factory FriendRequestItem.fromJson(Map<String, dynamic> json) =>
      FriendRequestItem(
        id: json['id'] as String? ?? '',
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class RoomInvitationItem {
  const RoomInvitationItem({
    required this.id,
    required this.room,
    required this.inviter,
  });
  final String id;
  final Room room;
  final AppUser inviter;
  factory RoomInvitationItem.fromJson(Map<String, dynamic> json) =>
      RoomInvitationItem(
        id: json['id'] as String? ?? '',
        room: Room.fromJson(json['room'] as Map<String, dynamic>),
        inviter: AppUser.fromJson(json['inviter'] as Map<String, dynamic>),
      );
}

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
    this.friendshipStatus,
    this.friendRequestDirection,
    this.coinBalance = 0,
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
  final String? friendshipStatus;
  final String? friendRequestDirection;
  final int coinBalance;

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
    friendshipStatus: json['friendship_status'] as String?,
    friendRequestDirection: json['friend_request_direction'] as String?,
    coinBalance: (json['coin_balance'] as num?)?.toInt() ?? 0,
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

  Future<List<AppUser>> friends() => _users('/friends', 'friends');
  Future<List<AppUser>> followers() => _users('/social/followers', 'users');
  Future<List<AppUser>> following() => _users('/social/following', 'users');

  Future<List<FriendRequestItem>> friendRequests() async {
    final json = await _api.get('/friend-requests');
    return (json['requests'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FriendRequestItem.fromJson)
        .toList();
  }

  Future<void> sendFriendRequest(String userId) =>
      _api.post('/friend-requests/$userId').then((_) {});

  Future<void> respondFriendRequest(String id, bool accept) =>
      _api.patch('/friend-requests/$id', body: {'accept': accept}).then((_) {});

  Future<void> removeFriend(String userId) =>
      _api.delete('/friends/$userId').then((_) {});

  Future<List<RoomInvitationItem>> roomInvitations() async {
    final json = await _api.get('/room-invitations');
    return (json['invitations'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RoomInvitationItem.fromJson)
        .toList();
  }

  Future<Room?> respondRoomInvitation(String id, bool accept) async {
    final json = await _api.patch(
      '/room-invitations/$id',
      body: {'accept': accept},
    );
    final room = json['room'];
    return room is Map<String, dynamic> ? Room.fromJson(room) : null;
  }

  Future<void> inviteToRoom(String roomId, String userId) =>
      _api.post('/rooms/$roomId/invitations/$userId').then((_) {});

  Future<List<AppUser>> _users(String path, String key) async {
    final json = await _api.get(path);
    return (json[key] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }
}
