import '../core/api/api_client.dart';

class GiftItem {
  const GiftItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
  });
  final int id;
  final String name;
  final String emoji;
  final int price;
  factory GiftItem.fromJson(Map<String, dynamic> j) => GiftItem(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    emoji: j['emoji'] as String? ?? '🎁',
    price: (j['price'] as num).toInt(),
  );
}

class GiftRepository {
  const GiftRepository(this._api);
  final ApiClient _api;
  Future<List<GiftItem>> gifts() async {
    final j = await _api.get('/gifts');
    return (j['gifts'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(GiftItem.fromJson)
        .toList();
  }

  Future<int> send(String roomId, int giftId, String recipientId) async {
    final j = await _api.post(
      '/rooms/$roomId/gifts/$giftId',
      body: {'recipient_id': recipientId},
    );
    return (j['balance'] as num).toInt();
  }
}
