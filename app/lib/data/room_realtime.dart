import 'package:laravel_reverb/laravel_reverb.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import 'models.dart';

class RoomRealtime {
  RoomRealtime({required this.token, required this.currentUserId});

  final String token;
  final String? currentUserId;
  Reverb? _client;
  Subscription? _subscription;

  Future<void> listen(String roomId, void Function(Room room) onRoom) async {
    final api = ApiClient();
    final response = await api.get('/content');
    api.close();
    final config = response['realtime'];
    if (config is! Map<String, dynamic>) return;
    final key = config['key'] as String?;
    final host = config['host'] as String?;
    if (key == null || key.isEmpty || host == null || host.isEmpty) return;

    final client = Reverb(
      host: host,
      port: (config['port'] as num?)?.toInt() ?? 443,
      appKey: key,
      useTls: config['scheme'] == 'https',
      authEndpoint: ApiConfig.broadcastingAuthUrl,
      authHeaders: () async => {'Authorization': 'Bearer $token'},
    );
    _client = client;
    _subscription = client.presence('room.$roomId').listen('.room.updated', (
      data,
    ) {
      final raw = data['room'];
      if (raw is Map<String, dynamic>) {
        onRoom(Room.fromJson(raw, currentUserId: currentUserId));
      }
    });
    await client.connect();
  }

  Future<void> dispose() async {
    _subscription?.cancel();
    _client?.dispose();
  }
}
