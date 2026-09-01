import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import '../widgets/common.dart';
import 'game_module.dart';

/// Maps a catalogue [Game] to its playable [GameModule].
///
/// Empty on purpose: this build is the UI shell, and no game logic exists yet.
/// Registering a module here is the single step that makes a game playable, so
/// this map is the checklist of what remains.
class GameRegistry {
  GameRegistry._();

  static final Map<String, GameModule> _modules = {};

  static void register(GameModule module) => _modules[module.id] = module;

  static GameModule? moduleFor(Game game) => _modules[game.id];

  /// Sync model each game will need once implemented. Everything in the
  /// current design is turn-based; pool would be the first realtime entry.
  static const plannedSyncModels = <String, GameSyncModel>{
    'spy': GameSyncModel.turnBased,
    'ludo': GameSyncModel.turnBased,
    'uno': GameSyncModel.turnBased,
    'werewolf': GameSyncModel.turnBased,
    'guessit': GameSyncModel.turnBased,
    'bingo': GameSyncModel.turnBased,
    'crazy8': GameSyncModel.turnBased,
    'truthordare': GameSyncModel.turnBased,
  };

  static void launch(BuildContext context, Game game) {
    final module = moduleFor(game);
    if (module != null) {
      // Real matchmaking goes here once a backend exists.
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotImplementedSheet(game: game),
    );
  }
}

class _NotImplementedSheet extends StatelessWidget {
  const _NotImplementedSheet({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = GameRegistry.plannedSyncModels[game.id];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.playersPlaying(game.playersLabel),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            game.id == 'truthordare'
                ? l10n.truthDareRoomOnlyTitle
                : l10n.gameNotBuiltTitle,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game.id == 'truthordare'
                ? l10n.truthDareRoomOnlyBody
                : l10n.gameNotBuiltBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (sync != null) ...[
            const SizedBox(height: 12),
            CountPill(
              label: sync == GameSyncModel.turnBased
                  ? l10n.gameSyncTurnBased
                  : l10n.gameSyncRealtime,
              icon: Icons.sync_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
