import '../core/api/api_client.dart';
import 'models.dart';

class DirectMessageRepository {
  DirectMessageRepository(this._api, {required this.currentUserId});
  final ApiClient _api;
  final String? currentUserId;

  Future<List<Conversation>> conversations() async {
    final json = await _api.get('/conversations');
    final raw = json['conversations'];
    if (raw is! List) throw const FormatException('Missing conversations');
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
  }

  Future<List<AppUser>> search(String query) async {
    final json = await _api.get(
      '/users/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return (json['users'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<Conversation> start(String userId) async {
    final json = await _api.post('/conversations', body: {'user_id': userId});
    return Conversation.fromJson(json['conversation'] as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> messages(String id) async {
    final json = await _api.get('/conversations/$id');
    return (json['messages'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((m) => ChatMessage.fromJson(m, currentUserId: currentUserId))
        .toList();
  }

  Future<ChatMessage> send(String id, String text) async {
    final json = await _api.post(
      '/conversations/$id/messages',
      body: {'text': text},
    );
    return ChatMessage.fromJson(
      json['message'] as Map<String, dynamic>,
      currentUserId: currentUserId,
    );
  }
}
