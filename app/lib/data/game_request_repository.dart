import '../core/api/api_client.dart';

class RoomGameRequest {
  const RoomGameRequest({
    required this.id,
    required this.game,
    required this.status,
    required this.requesterName,
  });

  final int id;
  final String game;
  final String status;
  final String requesterName;

  factory RoomGameRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>? ?? const {};
    return RoomGameRequest(
      id: (json['id'] as num).toInt(),
      game: json['game'] as String,
      status: json['status'] as String,
      requesterName: requester['name'] as String? ?? '',
    );
  }
}

class GameRequestRepository {
  const GameRequestRepository(this._api);
  final ApiClient _api;

  Future<RoomGameRequest> request(String roomId, String game) async {
    final json = await _api.post(
      '/rooms/$roomId/game-requests',
      body: {'game': game},
    );
    return RoomGameRequest.fromJson(json['request'] as Map<String, dynamic>);
  }

  Future<RoomGameRequest?> pending(String roomId) async {
    final json = await _api.get('/rooms/$roomId/game-requests/pending');
    final raw = json['request'];
    return raw is Map<String, dynamic> ? RoomGameRequest.fromJson(raw) : null;
  }

  Future<RoomGameRequest> respond(int id, bool accept) async {
    final json = await _api.patch(
      '/game-requests/$id',
      body: {'action': accept ? 'accept' : 'decline'},
    );
    return RoomGameRequest.fromJson(json['request'] as Map<String, dynamic>);
  }
}
