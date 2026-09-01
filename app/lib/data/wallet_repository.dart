import '../core/api/api_client.dart';

class CoinEntry {
  const CoinEntry({
    required this.reference,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });
  final String reference;
  final int amount;
  final int balanceAfter;
  final String description;
  final DateTime? createdAt;
  factory CoinEntry.fromJson(Map<String, dynamic> json) => CoinEntry(
    reference: json['reference'] as String? ?? '',
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    balanceAfter: (json['balance_after'] as num?)?.toInt() ?? 0,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );
}

class CoinWalletData {
  const CoinWalletData({required this.balance, required this.entries});
  final int balance;
  final List<CoinEntry> entries;
}

class WalletRepository {
  WalletRepository(this._api);
  final ApiClient _api;
  Future<CoinWalletData> wallet() async {
    final json = await _api.get('/wallet');
    return CoinWalletData(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      entries: (json['transactions'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CoinEntry.fromJson)
          .toList(),
    );
  }
}
