import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:room_play/core/api/api_client.dart';
import 'package:room_play/data/room_repository.dart';

void main() {
  test('creates a room and maps the host seat', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'room': {
            'id': '123456',
            'name': 'Music Night',
            'language': 'AR',
            'tag': 'music',
            'member_count': 1,
            'members': [
              {'id': 'me', 'name': 'Ashraf', 'level': 1, 'is_host': true},
            ],
            'seats': [
              {
                'position': 1,
                'is_locked': false,
                'mic_muted': true,
                'user': {
                  'id': 'me',
                  'name': 'Ashraf',
                  'level': 1,
                  'is_host': true,
                },
              },
            ],
          },
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = RoomRepository(
      ApiClient(httpClient: client, baseUrl: 'https://api.roomsplay.com'),
      currentUserId: 'me',
    );

    final room = await repository.create(
      name: 'Music Night',
      language: 'AR',
      tag: 'music',
    );

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/rooms');
    expect(jsonDecode(captured.body), {
      'name': 'Music Night',
      'language': 'AR',
      'tag': 'music',
    });
    expect(room.id, '123456');
    expect(room.seats.single.user!.isMe, isTrue);
    expect(room.seats.single.user!.isHost, isTrue);
  });

  test('claim reward keeps the returned wallet balance', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'reward': 5,
          'available': false,
          'balance': 15,
          'server_time': '2026-09-02T00:00:00Z',
          'next_claim_at': '2026-09-02T00:10:00Z',
        }),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final repository = RoomRepository(
      ApiClient(httpClient: client, baseUrl: 'https://api.roomsplay.com'),
      currentUserId: 'me',
    );

    final status = await repository.claimReward('123456');

    expect(status.reward, 5);
    expect(status.balance, 15);
  });
}
