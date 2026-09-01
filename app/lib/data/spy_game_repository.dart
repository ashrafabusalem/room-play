import '../core/api/api_client.dart';
import 'models.dart';

class SpyGameSession {
  const SpyGameSession({
    required this.id,
    required this.status,
    required this.isHost,
    required this.players,
    this.isSpy,
    this.word,
    this.spy,
  });
  final String id, status;
  final bool isHost;
  final bool? isSpy;
  final String? word;
  final AppUser? spy;
  final List<AppUser> players;

  factory SpyGameSession.fromJson(Map<String, dynamic> json) {
    final rawSpy = json['spy'];
    return SpyGameSession(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'lobby',
      isHost: json['is_host'] as bool? ?? false,
      isSpy: json['is_spy'] as bool?,
      word: json['word'] as String?,
      spy: rawSpy is Map<String, dynamic> ? AppUser.fromJson(rawSpy) : null,
      players: (json['players'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList(),
    );
  }
}

class SpyGameRepository {
  SpyGameRepository(this._api);
  final ApiClient _api;
  Future<SpyGameSession?> current(String roomId) async {
    final raw = (await _api.get('/rooms/$roomId/games/spy'))['session'];
    return raw is Map<String, dynamic> ? SpyGameSession.fromJson(raw) : null;
  }

  Future<SpyGameSession> create(String roomId) =>
      _session(_api.post('/rooms/$roomId/games/spy'));
  Future<SpyGameSession> start(String id) =>
      _session(_api.post('/spy-game-sessions/$id/start'));
  Future<SpyGameSession> reveal(String id) =>
      _session(_api.post('/spy-game-sessions/$id/reveal'));
  Future<SpyGameSession> _session(Future<Map<String, dynamic>> request) async =>
      SpyGameSession.fromJson(
        (await request)['session'] as Map<String, dynamic>,
      );
}
