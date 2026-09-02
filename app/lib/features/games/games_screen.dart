import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/room_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import 'spy_game_screen.dart';
import 'truth_or_dare_screen.dart';

/// The catalogue filters.
///
/// An enum rather than a list of strings: the labels are translated, so
/// switching on display text would silently stop matching the moment the user
/// changes language.
enum GameFilter { all, popular, isNew, board, party, action }

extension _GameFilterLabel on GameFilter {
  String label(AppLocalizations l10n) => switch (this) {
    GameFilter.all => l10n.filterAll,
    GameFilter.popular => l10n.filterPopular,
    GameFilter.isNew => l10n.filterNew,
    GameFilter.board => l10n.filterBoard,
    GameFilter.party => l10n.filterParty,
    GameFilter.action => l10n.filterAction,
  };
}

/// Full games catalogue with category filters.
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  static const _repo = MockRepository();

  GameFilter _filter = GameFilter.all;

  List<Game> get _visible {
    final all = _repo
        .games()
        .where((game) => game.id == 'spy' || game.id == 'truthordare')
        .toList();
    return switch (_filter) {
      GameFilter.popular =>
        (all.toList()
          ..sort((a, b) => b.playersOnline.compareTo(a.playersOnline))),
      GameFilter.isNew => all.where((g) => g.isNew).toList(),
      GameFilter.board =>
        all.where((g) => g.category == GameCategory.board).toList(),
      GameFilter.party =>
        all.where((g) => g.category == GameCategory.party).toList(),
      GameFilter.action =>
        all.where((g) => g.category == GameCategory.action).toList(),
      GameFilter.all => all,
    };
  }

  Future<void> _play(Game game) async {
    final l = AppLocalizations.of(context);
    final auth = AuthScope.of(context);
    final repository = RoomRepository(auth.api, currentUserId: auth.publicId);
    List<Room> rooms;
    try {
      rooms = await repository.rooms();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorNetwork)));
      }
      return;
    }
    if (!mounted) return;
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.gameNoRooms)));
      return;
    }
    final selected = await showModalBottomSheet<Room>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l.gameChooseRoom)),
            for (final room in rooms)
              ListTile(
                leading: const Icon(Icons.graphic_eq_rounded),
                title: Text(room.name, textDirection: directionOf(room.name)),
                subtitle: Text(l.playersPlaying('${room.memberCount}')),
                onTap: () => Navigator.pop(context, room),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l.gameJoiningRoom)),
          ],
        ),
      ),
    );
    try {
      final room = await repository.join(selected.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => game.id == 'spy'
              ? SpyGameScreen(room: room)
              : TruthOrDareScreen(room: room),
        ),
      );
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorUnexpected)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = _visible;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.gamesTitle),
        actions: const [
          Icon(Icons.search_rounded),
          SizedBox(width: AppSizes.gutter),
        ],
      ),
      body: Column(
        children: [
          _FilterTabs(
            selected: _filter,
            onSelect: (f) => setState(() => _filter = f),
          ),
          const Divider(height: 1),
          Expanded(
            child: games.isEmpty
                ? NotDesignedYet(
                    screen: l10n.gamesEmptyTitle,
                    note: l10n.gamesEmptyBody,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.gutter,
                      12,
                      AppSizes.gutter,
                      24,
                    ),
                    itemCount: games.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _GameRow(game: games[i], onPlay: () => _play(games[i])),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onSelect});

  final GameFilter selected;
  final ValueChanged<GameFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        itemCount: GameFilter.values.length,
        itemBuilder: (context, i) {
          final filter = GameFilter.values[i];
          final active = filter == selected;
          return GestureDetector(
            onTap: () => onSelect(filter),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    filter.label(l10n),
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontFamilyFallback: kFontFallback,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2.5,
                    width: active ? 22 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.game, required this.onPlay});

  final Game game;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlyphTile(glyph: game.glyph, gradient: game.gradient, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.name,
                textDirection: directionOf(game.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    game.playersLabel,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontFamilyFallback: kFontFallback,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CountPill(
                    label: game.category.label(AppLocalizations.of(context)),
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onPlay,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryAlt,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(AppLocalizations.of(context).actionPlay),
        ),
      ],
    );
  }
}
