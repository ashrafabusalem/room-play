import '../core/api/api_client.dart';
import 'models.dart';

class NotificationFeed {
  const NotificationFeed({required this.unreadCount, required this.items});

  final int unreadCount;
  final List<InboxNotification> items;
}

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.actor,
    this.readAt,
  });

  final int id;
  final String type;
  final Map<String, dynamic> data;
  final AppUser? actor;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;

  factory InboxNotification.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    return InboxNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      actor: actor is Map<String, dynamic> ? AppUser.fromJson(actor) : null,
      readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class NotificationRepository {
  const NotificationRepository(this._api);

  final ApiClient _api;

  Future<NotificationFeed> load() async {
    final json = await _api.get('/notifications');
    final items = (json['notifications'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(InboxNotification.fromJson)
        .toList();
    return NotificationFeed(
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }

  Future<void> read(int id) => _api.patch('/notifications/$id');

  Future<void> readAll() => _api.patch('/notifications/read-all');
}
