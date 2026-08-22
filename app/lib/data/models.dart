import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/gen/app_localizations.dart';

/// Plain immutable models for the UI shell.
///
/// These deliberately have no serialisation logic yet. When the backend lands,
/// add `fromJson`/`toJson` here and swap [MockRepository] for a real one —
/// no screen should need to change.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.coins = 0,
    this.level = 1,
    this.verified = false,
    this.micMuted = false,
    this.isHost = false,
    this.isMe = false,
  });

  final String id;
  final String name;
  final int coins;
  final int level;
  final bool verified;
  final bool micMuted;
  final bool isHost;
  final bool isMe;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Stable per-user avatar gradient, so the same person is always the same
  /// colour without needing an image asset.
  List<Color> get avatarGradient =>
      AppColors.avatarGradients[id.hashCode.abs() %
          AppColors.avatarGradients.length];
}

/// One of the nine seats in a voice room. A null [user] means the seat is open.
class Seat {
  const Seat({required this.index, this.user, this.locked = false});

  final int index;
  final AppUser? user;
  final bool locked;

  bool get isOpen => user == null && !locked;
}

class Room {
  const Room({
    required this.id,
    required this.name,
    required this.numericId,
    required this.language,
    required this.memberCount,
    required this.members,
    this.tag = 'Chatting',
    this.seats = const [],
    this.following = false,
  });

  final String id;
  final String name;
  final String numericId;
  final String language;
  final int memberCount;

  /// Small avatar stack shown on the home-screen room rows.
  final List<AppUser> members;
  final String tag;
  final List<Seat> seats;
  final bool following;
}

enum GameCategory { board, card, party, puzzle, action }

extension GameCategoryLabel on GameCategory {
  /// Display name in the active language.
  ///
  /// Game *titles* stay untranslated on purpose — "Ludo" and "UNO" are proper
  /// nouns, and once there is a backend the titles will arrive already
  /// localised. Only the category chrome is translated here.
  String label(AppLocalizations l10n) => switch (this) {
    GameCategory.board => l10n.gameCategoryBoard,
    GameCategory.card => l10n.gameCategoryCard,
    GameCategory.party => l10n.gameCategoryParty,
    GameCategory.puzzle => l10n.gameCategoryPuzzle,
    GameCategory.action => l10n.gameCategoryAction,
  };
}

class Game {
  const Game({
    required this.id,
    required this.name,
    required this.category,
    required this.playersOnline,
    required this.glyph,
    required this.gradient,
    this.isNew = false,
  });

  final String id;
  final String name;
  final GameCategory category;
  final int playersOnline;

  /// Placeholder art. Replace with real icon assets before launch —
  /// see `assets/games/README.md`.
  final String glyph;
  final List<Color> gradient;
  final bool isNew;

  String get playersLabel => formatCount(playersOnline);
}

class ChatMessage {
  const ChatMessage({this.sender, required this.text, this.isSystem = false});

  final AppUser? sender;
  final String text;
  final bool isSystem;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.preview,
    required this.time,
    this.unread = 0,
    this.dot = false,
    this.verified = false,
    this.isVoiceNote = false,
    this.isGroup = false,
  });

  final String id;
  final String name;
  final String preview;
  final String time;

  /// Numeric unread badge. 0 hides it.
  final int unread;

  /// Small blue dot for "unread but uncounted" rows, as in the mockup.
  final bool dot;
  final bool verified;
  final bool isVoiceNote;
  final bool isGroup;
}

class HeroBanner {
  const HeroBanner({
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final String title;
  final String subtitle;
  final String cta;
}

class HomeCategory {
  const HomeCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// 12400 -> "12.4K", 1200 -> "1.2K", 680 -> "680".
String formatCount(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(v >= 10 ? 1 : 1)}K';
  }
  return '$n';
}
