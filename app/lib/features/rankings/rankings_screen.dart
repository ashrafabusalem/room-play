import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/ranking_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../auth/auth_controller.dart';
import '../profile/public_profile_screen.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});
  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  String period = 'weekly';
  bool received = false;
  RankingFeed? feed;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (feed == null) _load();
  }

  Future<void> _load() async {
    try {
      final value = await RankingRepository(AuthScope.of(context).api)
          .load(period);
      if (mounted) setState(() => feed = value);
    } catch (_) {
      if (mounted) {
        setState(() => feed = const RankingFeed(sent: [], received: []));
      }
    }
  }

  void _period(String value) {
    if (value == period) return;
    setState(() {
      period = value;
      feed = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = received ? feed?.received : feed?.sent;
    return Scaffold(
      appBar: AppBar(title: Text(l.rankingsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'weekly',
                      label: Text(l.rankingsWeekly),
                    ),
                    ButtonSegment(value: 'all', label: Text(l.rankingsAllTime)),
                  ],
                  selected: {period},
                  onSelectionChanged: (v) => _period(v.first),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(l.rankingsTopSenders),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(l.rankingsTopReceivers),
                    ),
                  ],
                  selected: {received},
                  onSelectionChanged: (v) => setState(() => received = v.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries == null
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                ? Center(child: Text(l.rankingsEmpty))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _RankingRow(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry});
  final RankingEntry entry;
  @override
  Widget build(BuildContext context) {
    final label = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '${entry.rank}',
    };
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: entry.user.id.isEmpty
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PublicProfileScreen(userId: entry.user.id),
                ),
              ),
        leading: SizedBox(
          width: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: entry.rank <= 3 ? 24 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(entry.user.name),
        subtitle: Text(AppLocalizations.of(context).rankingsGold(entry.gold)),
        trailing: AvatarCircle(user: entry.user, size: 40),
      ),
    );
  }
}
