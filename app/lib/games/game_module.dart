import 'package:flutter/widgets.dart';

import '../data/models.dart';

/// How a game keeps two devices in agreement.
///
/// Every game in the current design is [turnBased]: one player acts, the
/// server validates, everyone is told the new state. Cheap, robust, tolerant
/// of bad networks.
///
/// [realtime] is reserved for continuous-simulation games such as 8-ball pool.
/// It is NOT implemented yet, and deliberately so — it needs a different
/// transport (fixed-tick snapshots, interpolation, server-side physics) and a
/// different server. The enum exists now so the boundary is drawn in the right
/// place and adding pool later is an addition, not a rewrite.
enum GameSyncModel { turnBased, realtime }

/// A single move a player attempts. Never trust it on the client: the server
/// is the authority on whether it is legal.
class GameAction {
  const GameAction({required this.type, this.payload = const {}});

  final String type;
  final Map<String, Object?> payload;
}

/// Something that happened in the match, pushed from the server.
class GameEvent {
  const GameEvent({required this.type, this.payload = const {}});

  final String type;
  final Map<String, Object?> payload;
}

/// The wire between a running game and the server.
///
/// Implementations to come: `MockTransport` (local, for UI work),
/// `WebSocketTransport` (turn-based), and later a snapshot-based transport for
/// [GameSyncModel.realtime].
abstract class GameTransport {
  Stream<GameEvent> get events;

  Future<void> send(GameAction action);

  Future<void> dispose();
}

/// Live state of one match.
class GameSession {
  const GameSession({
    required this.matchId,
    required this.game,
    required this.players,
    required this.currentTurn,
    required this.transport,
  });

  final String matchId;
  final Game game;
  final List<AppUser> players;

  /// Index into [players]. Meaningless for realtime games.
  final int currentTurn;
  final GameTransport transport;
}

/// Contract every game must satisfy to appear in the app.
///
/// Keeping games behind this interface is what stops the platform and the game
/// logic growing into each other — the room, matchmaking, and wagering code
/// should never know whether it is running Ludo or pool.
abstract class GameModule {
  String get id;

  String get displayName;

  GameSyncModel get syncModel;

  int get minPlayers;

  int get maxPlayers;

  /// The playing surface, rendered inside the room.
  Widget buildTable(BuildContext context, GameSession session);
}
