import '../core/api/api_client.dart';
import 'models.dart';

class TruthOrDareSession {
  const TruthOrDareSession({
    required this.id,
    required this.roomId,
    required this.status,
    required this.turnNumber,
    required this.isHost,
    required this.isMyTurn,
    required this.players,
    this.currentPlayerId,
    this.promptType,
    this.promptText,
  });
  final String id;
  final String roomId;
  final String status;
  final int turnNumber;
  final bool isHost;
  final bool isMyTurn;
  final String? currentPlayerId;
  final String? promptType;
  final String? promptText;
  final List<AppUser> players;
  factory TruthOrDareSession.fromJson(Map<String, dynamic> json) {
    final prompt = json['current_prompt'];
    return TruthOrDareSession(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      status: json['status'] as String? ?? 'lobby',
      turnNumber: (json['turn_number'] as num?)?.toInt() ?? 0,
      isHost: json['is_host'] as bool? ?? false,
      isMyTurn: json['is_my_turn'] as bool? ?? false,
      currentPlayerId: json['current_player_id'] as String?,
      promptType: prompt is Map<String, dynamic>
          ? prompt['type'] as String?
          : null,
      promptText: prompt is Map<String, dynamic>
          ? prompt['text'] as String?
          : null,
      players: (json['players'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList(),
    );
  }
  AppUser? get currentPlayer {
    for (final player in players) {
      if (player.id == currentPlayerId) return player;
    }
    return null;
  }
}

class TruthOrDareRepository {
  TruthOrDareRepository(this._api);
  final ApiClient _api;
  Future<TruthOrDareSession?> current(String roomId) async {
    final json = await _api.get('/rooms/$roomId/games/truth-or-dare');
    final raw = json['session'];
    return raw is Map<String, dynamic>
        ? TruthOrDareSession.fromJson(raw)
        : null;
  }

  Future<TruthOrDareSession> create(String roomId) async =>
      _session(await _api.post('/rooms/$roomId/games/truth-or-dare'));
  Future<TruthOrDareSession> start(String id) async =>
      _session(await _api.post('/game-sessions/$id/start'));
  Future<TruthOrDareSession> choose(String id, String type) async => _session(
    await _api.post('/game-sessions/$id/choose', body: {'type': type}),
  );
  Future<TruthOrDareSession> next(String id) async =>
      _session(await _api.post('/game-sessions/$id/next'));
  Future<TruthOrDareSession> finish(String id) async =>
      _session(await _api.post('/game-sessions/$id/finish'));
  TruthOrDareSession _session(Map<String, dynamic> json) =>
      TruthOrDareSession.fromJson(json['session'] as Map<String, dynamic>);
}
