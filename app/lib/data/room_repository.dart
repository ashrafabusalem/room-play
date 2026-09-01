import '../core/api/api_client.dart';
import 'models.dart';

class RoomRepository {
  RoomRepository(this._api, {required this.currentUserId});

  final ApiClient _api;
  final String? currentUserId;

  Future<List<Room>> rooms() async {
    final response = await _api.get('/rooms');
    final raw = response['data'];
    if (raw is! List) throw const FormatException('Missing room list');
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => Room.fromJson(json, currentUserId: currentUserId))
        .toList(growable: false);
  }

  Future<Room> create({
    required String name,
    required String language,
    required String tag,
  }) => _room(
    _api.post('/rooms', body: {'name': name, 'language': language, 'tag': tag}),
  );

  Future<Room> join(String id) => _room(_api.post('/rooms/$id/join'));
  Future<Room> leave(String id) => _room(_api.delete('/rooms/$id/leave'));
  Future<Room> takeSeat(String id, int position) =>
      _room(_api.put('/rooms/$id/seats/$position'));
  Future<Room> leaveSeat(String id) => _room(_api.delete('/rooms/$id/seat'));
  Future<Room> microphone(String id, {required bool muted}) =>
      _room(_api.patch('/rooms/$id/microphone', body: {'muted': muted}));

  Future<List<ChatMessage>> messages(String id) async {
    final response = await _api.get('/rooms/$id/messages');
    final raw = response['messages'];
    if (raw is! List) throw const FormatException('Missing messages');
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => ChatMessage.fromJson(json, currentUserId: currentUserId))
        .toList(growable: false);
  }

  Future<ChatMessage> sendMessage(String id, String text) async {
    final response = await _api.post(
      '/rooms/$id/messages',
      body: {'text': text},
    );
    final raw = response['message'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing message');
    }
    return ChatMessage.fromJson(raw, currentUserId: currentUserId);
  }

  Future<RoomRewardStatus> rewardStatus(String id) async =>
      RoomRewardStatus.fromJson(await _api.get('/rooms/$id/reward'));

  Future<RoomRewardStatus> claimReward(String id) async =>
      RoomRewardStatus.fromJson(await _api.post('/rooms/$id/reward'));

  Future<Room> _room(Future<Map<String, dynamic>> request) async {
    final response = await request;
    final raw = response['room'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing room');
    }
    return Room.fromJson(raw, currentUserId: currentUserId);
  }
}

class RoomRewardStatus {
  const RoomRewardStatus({
    required this.reward,
    required this.available,
    this.readyAt,
  });
  final int reward;
  final bool available;
  final DateTime? readyAt;
  factory RoomRewardStatus.fromJson(Map<String, dynamic> json) {
    final server = DateTime.tryParse(json['server_time'] as String? ?? '');
    final next = DateTime.tryParse(json['next_claim_at'] as String? ?? '');
    final readyAt = server == null || next == null
        ? null
        : DateTime.now().add(next.difference(server));
    return RoomRewardStatus(
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? false,
      readyAt: readyAt,
    );
  }
}
