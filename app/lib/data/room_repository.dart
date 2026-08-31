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

  Future<Room> join(String id) => _room(_api.post('/rooms/$id/join'));
  Future<Room> leave(String id) => _room(_api.delete('/rooms/$id/leave'));
  Future<Room> takeSeat(String id, int position) =>
      _room(_api.put('/rooms/$id/seats/$position'));
  Future<Room> leaveSeat(String id) => _room(_api.delete('/rooms/$id/seat'));
  Future<Room> microphone(String id, {required bool muted}) =>
      _room(_api.patch('/rooms/$id/microphone', body: {'muted': muted}));

  Future<Room> _room(Future<Map<String, dynamic>> request) async {
    final response = await request;
    final raw = response['room'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing room');
    }
    return Room.fromJson(raw, currentUserId: currentUserId);
  }
}
