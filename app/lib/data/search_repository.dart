import '../core/api/api_client.dart';
import 'models.dart';

class SearchResults {
  const SearchResults({required this.users, required this.rooms});
  final List<AppUser> users;
  final List<Room> rooms;
}

class SearchRepository {
  const SearchRepository(this._api, {required this.currentUserId});
  final ApiClient _api;
  final String? currentUserId;
  Future<SearchResults> search(String term) async {
    final j = await _api.get('/search?q=${Uri.encodeQueryComponent(term)}');
    return SearchResults(
      users: (j['users'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList(),
      rooms: (j['rooms'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((r) => Room.fromJson(r, currentUserId: currentUserId))
          .toList(),
    );
  }
}
