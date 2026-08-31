import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:room_play/core/api/api_client.dart';
import 'package:room_play/data/content_repository.dart';

void main() {
  test('loads localized banners from the content endpoint', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'banners': [
            {
              'id': '7',
              'title': 'بطولة',
              'subtitle': 'هذا الأسبوع',
              'cta': 'انضم',
              'image_url': 'https://api.roomsplay.com/storage/banner.webp',
              'action_type': 'games',
              'action_value': null,
            },
          ],
          'offers': [],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ContentRepository(
      api: ApiClient(httpClient: client, baseUrl: 'https://api.roomsplay.com'),
    );

    final banners = await repository.banners('ar');

    expect(captured.url.path, '/api/content');
    expect(captured.headers['Accept-Language'], 'ar');
    expect(banners.single.title, 'بطولة');
    expect(banners.single.actionType, 'games');
    repository.close();
  });
}
