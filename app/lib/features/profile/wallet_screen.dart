import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/wallet_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  CoinWalletData? _wallet;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final wallet = await WalletRepository(AuthScope.of(context).api).wallet();
      if (mounted) setState(() => _wallet = wallet);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = _wallet;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: wallet == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A1E52), Color(0xFF3B2A78)],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.gold,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _number(wallet.balance),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(
                          l10n.profileCoinBalance,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.walletHistory,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (wallet.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        l10n.walletEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...wallet.entries.map(
                      (entry) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                (entry.amount > 0
                                        ? AppColors.success
                                        : AppColors.danger)
                                    .withValues(alpha: .15),
                            child: Icon(
                              entry.amount > 0
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded,
                              color: entry.amount > 0
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                          title: Text(entry.description),
                          subtitle: Text(
                            entry.createdAt?.toLocal().toString().substring(
                                  0,
                                  16,
                                ) ??
                                '',
                          ),
                          trailing: Text(
                            '${entry.amount > 0 ? '+' : ''}${_number(entry.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: entry.amount > 0
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _number(int value) {
    final digits = value.abs().toString();
    final parts = <String>[];
    for (var end = digits.length; end > 0; end -= 3) {
      parts.insert(0, digits.substring(end > 3 ? end - 3 : 0, end));
    }
    return '${value < 0 ? '-' : ''}${parts.join(',')}';
  }
}
