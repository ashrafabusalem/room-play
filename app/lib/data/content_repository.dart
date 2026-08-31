import '../core/api/api_client.dart';
import 'models.dart';

class ContentRepository {
  ContentRepository({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<List<HeroBanner>> banners(String languageCode) async {
    _api.languageCode = languageCode;
    final response = await _api.get('/content');
    final raw = response['banners'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(HeroBanner.fromJson)
        .where((banner) => banner.title.isNotEmpty)
        .toList(growable: false);
  }

  void close() => _api.close();
}
