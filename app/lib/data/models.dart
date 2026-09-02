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
    this.avatarUrl,
  });

  final String id;
  final String name;
  final int coins;
  final int level;
  final bool verified;
  final bool micMuted;
  final bool isHost;
  final bool isMe;
  final String? avatarUrl;

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) => AppUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    coins: (json['coins'] as num?)?.toInt() ?? 0,
    level: (json['level'] as num?)?.toInt() ?? 1,
    micMuted: json['mic_muted'] as bool? ?? false,
    isHost: json['is_host'] as bool? ?? false,
    isMe: json['id'] == currentUserId,
    avatarUrl: json['avatar_url'] as String?,
  );

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

  Seat copyWith({AppUser? user, bool clearUser = false, bool? locked}) => Seat(
    index: index,
    user: clearUser ? null : (user ?? this.user),
    locked: locked ?? this.locked,
  );

  factory Seat.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final rawUser = json['user'];
    return Seat(
      index: (json['position'] as num?)?.toInt() ?? 0,
      locked: json['is_locked'] as bool? ?? false,
      user: rawUser is Map<String, dynamic>
          ? AppUser.fromJson({
              ...rawUser,
              'mic_muted': json['mic_muted'],
            }, currentUserId: currentUserId)
          : null,
    );
  }
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
    this.isLocked = false,
    this.isClosed = false,
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
  final bool isLocked;
  final bool isClosed;

  Room copyWith({List<Seat>? seats}) => Room(
    id: id,
    name: name,
    numericId: numericId,
    language: language,
    memberCount: memberCount,
    members: members,
    tag: tag,
    seats: seats ?? this.seats,
    following: following,
    isLocked: isLocked,
    isClosed: isClosed,
  );

  factory Room.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final members = (json['members'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => AppUser.fromJson(item, currentUserId: currentUserId))
        .toList(growable: false);
    final seats = (json['seats'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => Seat.fromJson(item, currentUserId: currentUserId))
        .toList(growable: false);
    final id = json['id'] as String? ?? '';
    return Room(
      id: id,
      numericId: id,
      name: json['name'] as String? ?? '',
      language: json['language'] as String? ?? 'EN',
      memberCount: (json['member_count'] as num?)?.toInt() ?? members.length,
      members: members,
      tag: json['tag'] as String? ?? 'chatting',
      seats: seats,
      isLocked: json['is_locked'] as bool? ?? false,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }
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

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final rawSender = json['sender'];
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isSystem: json['type'] == 'system',
      sender: rawSender is Map<String, dynamic>
          ? AppUser.fromJson(rawSender, currentUserId: currentUserId)
          : null,
    );
  }
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
    this.userId,
    this.avatarUrl,
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
  final String? userId;
  final String? avatarUrl;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final last = json['last_message'] as Map<String, dynamic>?;
    final created = DateTime.tryParse(last?['created_at'] as String? ?? '');
    return Conversation(
      id: json['id'] as String? ?? '',
      userId: user['id'] as String?,
      name: user['name'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String?,
      preview: last?['text'] as String? ?? '',
      time: created == null
          ? ''
          : '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}',
      unread: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class HeroBanner {
  const HeroBanner({
    this.id,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.imageUrl,
    this.actionType = 'none',
    this.actionValue,
  });

  final String? id;
  final String title;
  final String subtitle;
  final String cta;
  final String? imageUrl;
  final String actionType;
  final String? actionValue;

  factory HeroBanner.fromJson(Map<String, dynamic> json) => HeroBanner(
    id: json['id'] as String?,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    cta: json['cta'] as String? ?? '',
    imageUrl: json['image_url'] as String?,
    actionType: json['action_type'] as String? ?? 'none',
    actionValue: json['action_value'] as String?,
  );
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
