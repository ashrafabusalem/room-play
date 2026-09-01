import '../core/api/api_client.dart';
import 'models.dart';

class RankingEntry {
  const RankingEntry({
    required this.rank,
    required this.user,
    required this.gold,
  });
  final int rank;
  final AppUser user;
  final int gold;
  factory RankingEntry.fromJson(Map<String, dynamic> j) => RankingEntry(
    rank: (j['rank'] as num).toInt(),
    user: AppUser.fromJson(j['user'] as Map<String, dynamic>),
    gold: (j['gold'] as num).toInt(),
  );
}

class RankingFeed {
  const RankingFeed({required this.sent, required this.received});
  final List<RankingEntry> sent;
  final List<RankingEntry> received;
}

class RankingRepository {
  const RankingRepository(this._api);
  final ApiClient _api;
  Future<RankingFeed> load(String period) async {
    final j = await _api.get('/rankings?period=$period');
    List<RankingEntry> map(String k) => (j[k] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RankingEntry.fromJson)
        .toList();
    return RankingFeed(sent: map('sent'), received: map('received'));
  }
}
