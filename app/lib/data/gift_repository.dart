import 'dart:math';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';

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

class LiveGift {
  const LiveGift({
    required this.emoji,
    required this.nameEn,
    required this.nameAr,
    required this.senderName,
    required this.recipientName,
  });
  final String emoji;
  final String nameEn;
  final String nameAr;
  final String senderName;
  final String recipientName;
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  factory LiveGift.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    final recipient = json['recipient'] as Map<String, dynamic>? ?? {};
    return LiveGift(
      emoji: json['emoji'] as String? ?? '🎁',
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      senderName: sender['name'] as String? ?? '',
      recipientName: recipient['name'] as String? ?? '',
    );
  }
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
    final requestId =
        '${DateTime.now().microsecondsSinceEpoch}-'
        '${Random.secure().nextInt(1 << 32)}';
    final body = {'recipient_id': recipientId, 'request_id': requestId};
    Map<String, dynamic> j;
    try {
      j = await _api.post('/rooms/$roomId/gifts/$giftId', body: body);
    } on ApiException catch (error) {
      if (error.kind != ApiErrorKind.timeout &&
          error.kind != ApiErrorKind.network) {
        rethrow;
      }
      j = await _api.post('/rooms/$roomId/gifts/$giftId', body: body);
    }
    return (j['balance'] as num).toInt();
  }
}
