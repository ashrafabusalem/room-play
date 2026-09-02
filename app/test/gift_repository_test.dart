import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:room_play/core/api/api_client.dart';
import 'package:room_play/data/gift_repository.dart';

void main() {
  test('gift send keeps both authoritative balances', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({'balance': 0, 'recipient_balance': 20}),
        201,
        headers: {'content-type': 'application/json'},
      ),
    );
    final repository = GiftRepository(
      ApiClient(httpClient: client, baseUrl: 'https://api.roomsplay.com'),
    );

    final result = await repository.send('123456', 1, 'recipient');

    expect(result.senderBalance, 0);
    expect(result.recipientBalance, 20);
  });
}
