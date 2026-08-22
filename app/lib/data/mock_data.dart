import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'models.dart';

/// Hard-coded content mirroring the mockup, so every screen renders something
/// real before a backend exists.
///
/// Everything here is behind [MockRepository]. When the server arrives,
/// implement the same method signatures against it and delete this file.
class MockRepository {
  const MockRepository();

  // ------------------------------------------------------------------ users
  static const me = AppUser(
    id: 'u_me',
    name: 'You',
    coins: 0,
    level: 12,
    micMuted: true,
    isMe: true,
  );

  static const tony = AppUser(
    id: 'u_tony',
    name: 'Tony',
    coins: 680,
    level: 33,
  );
  static const princess = AppUser(
    id: 'u_princess',
    name: 'Princess',
    coins: 1200,
    level: 59,
    isHost: true,
  );
  static const leo = AppUser(id: 'u_leo', name: 'Leo', coins: 560, level: 21);
  static const rose = AppUser(
    id: 'u_rose',
    name: 'Rose',
    coins: 320,
    level: 24,
  );
  static const emily = AppUser(
    id: 'u_emily',
    name: 'Emily',
    coins: 280,
    level: 17,
  );
  static const alex = AppUser(id: 'u_alex', name: 'Alex', coins: 140, level: 8);

  static const _crowd = [tony, princess, leo, rose, emily, alex];

  // ------------------------------------------------------------------ banner
  // Promo copy is app-authored here so it can be translated. In production
  // these come from the server, already localised for the requested locale —
  // that is also where scheduling and targeting will live.
  List<HeroBanner> banners(AppLocalizations l10n) => [
    HeroBanner(
      title: l10n.bannerPlayGamesTitle,
      subtitle: l10n.bannerPlayGamesSubtitle,
      cta: l10n.bannerPlayGamesCta,
    ),
    HeroBanner(
      title: l10n.bannerTournamentTitle,
      subtitle: l10n.bannerTournamentSubtitle,
      cta: l10n.bannerTournamentCta,
    ),
    HeroBanner(
      title: l10n.bannerHostTitle,
      subtitle: l10n.bannerHostSubtitle,
      cta: l10n.bannerHostCta,
    ),
  ];

  List<HomeCategory> categories(AppLocalizations l10n) => [
    HomeCategory(
      label: l10n.categoryGames,
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFF8B6BFF),
    ),
    HomeCategory(
      label: l10n.categoryVoiceRooms,
      icon: Icons.mic_rounded,
      color: const Color(0xFF4A9BF7),
    ),
    HomeCategory(
      label: l10n.categoryParty,
      icon: Icons.celebration_rounded,
      color: const Color(0xFFDB42AE),
    ),
    HomeCategory(
      label: l10n.categoryEvents,
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFF6810D),
    ),
  ];

  // ------------------------------------------------------------------- games
  List<Game> games() => const [
    Game(
      id: 'spy',
      name: "Who's The Spy?",
      category: GameCategory.party,
      playersOnline: 12400,
      glyph: '🕵️',
      gradient: [Color(0xFF6D4C2F), Color(0xFFB07A45)],
    ),
    Game(
      id: 'ludo',
      name: 'Ludo',
      category: GameCategory.board,
      playersOnline: 8700,
      glyph: '🎲',
      gradient: [Color(0xFF2E7DF7), Color(0xFF57C2FF)],
    ),
    Game(
      id: 'uno',
      name: 'UNO',
      category: GameCategory.card,
      playersOnline: 16300,
      glyph: '🃏',
      gradient: [Color(0xFFD32F2F), Color(0xFFFF6B6B)],
    ),
    Game(
      id: 'werewolf',
      name: 'Werewolf',
      category: GameCategory.party,
      playersOnline: 7100,
      glyph: '🐺',
      gradient: [Color(0xFF3E2723), Color(0xFF8D6E63)],
    ),
    Game(
      id: 'guessit',
      name: 'Guess It',
      category: GameCategory.puzzle,
      playersOnline: 5600,
      glyph: '🙈',
      gradient: [Color(0xFF6D4C41), Color(0xFFC49A6C)],
    ),
    Game(
      id: 'bingo',
      name: 'Bingo',
      category: GameCategory.board,
      playersOnline: 4300,
      glyph: '🎱',
      gradient: [Color(0xFF00695C), Color(0xFF4DB6AC)],
    ),
    Game(
      id: 'crazy8',
      name: 'Crazy 8',
      category: GameCategory.card,
      playersOnline: 3800,
      glyph: '🎴',
      gradient: [Color(0xFF1565C0), Color(0xFF64B5F6)],
    ),
    Game(
      id: 'truthordare',
      name: 'Truth or Dare',
      category: GameCategory.party,
      playersOnline: 2900,
      glyph: '❓',
      gradient: [Color(0xFFAD1457), Color(0xFFF06292)],
      isNew: true,
    ),
  ];

  List<Game> popularGames() => games().take(4).toList();

  // ------------------------------------------------------------------- rooms
  List<Room> rooms() => [
    Room(
      id: 'r_chill',
      name: 'Chill & Talk',
      numericId: '102938',
      language: 'EN',
      memberCount: 25,
      members: _crowd.take(5).toList(),
      seats: _chillSeats(),
    ),
    Room(
      id: 'r_squad',
      name: 'Squad Goals',
      numericId: '884120',
      language: 'EN',
      memberCount: 18,
      members: _crowd.skip(1).take(5).toList(),
      seats: _sparseSeats(),
    ),
    Room(
      id: 'r_music',
      name: 'Music Lounge',
      numericId: '551037',
      language: 'EN',
      memberCount: 32,
      members: _crowd.take(4).toList(),
      seats: _sparseSeats(),
    ),
    Room(
      id: 'r_night',
      name: 'Late Night Ludo',
      numericId: '773901',
      language: 'EN',
      memberCount: 14,
      members: _crowd.skip(2).take(4).toList(),
      seats: _sparseSeats(),
    ),
  ];

  Room roomById(String id) =>
      rooms().firstWhere((r) => r.id == id, orElse: () => rooms().first);

  /// Matches the room screen in the mockup: six taken seats, seats 7-9 open.
  static List<Seat> _chillSeats() => const [
    Seat(index: 1, user: tony),
    Seat(index: 2, user: princess),
    Seat(index: 3, user: leo),
    Seat(index: 4, user: rose),
    Seat(index: 5, user: me),
    Seat(index: 6, user: emily),
    Seat(index: 7),
    Seat(index: 8),
    Seat(index: 9),
  ];

  static List<Seat> _sparseSeats() => const [
    Seat(index: 1, user: princess),
    Seat(index: 2, user: rose),
    Seat(index: 3),
    Seat(index: 4),
    Seat(index: 5),
    Seat(index: 6),
    Seat(index: 7),
    Seat(index: 8),
    Seat(index: 9),
  ];

  // -------------------------------------------------------------------- chat
  List<ChatMessage> roomChat() => const [
    ChatMessage(sender: tony, text: 'Hey everyone! 👋'),
    ChatMessage(sender: rose, text: 'Hii! Nice to see you all!'),
    ChatMessage(sender: princess, text: "Let's play a game later! 🎉"),
    ChatMessage(text: 'Welcome Alex to the room 🎉', isSystem: true),
  ];

  // ---------------------------------------------------------------- messages
  List<Conversation> conversations() => const [
    Conversation(
      id: 'c_team',
      name: 'Room Play Team',
      preview: '🎉 New update is live!',
      time: '09:30',
      dot: true,
      verified: true,
    ),
    Conversation(
      id: 'c_princess',
      name: 'Princess',
      preview: '🎁 Let\'s play together later!',
      time: '09:15',
      unread: 2,
    ),
    Conversation(
      id: 'c_tony',
      name: 'Tony',
      preview: '😂 Check this out',
      time: '08:50',
      dot: true,
    ),
    Conversation(
      id: 'c_squad',
      name: 'Squad Goals',
      preview: 'Rose: See you tonight!',
      time: '08:30',
      unread: 5,
      isGroup: true,
    ),
    Conversation(
      id: 'c_emily',
      name: 'Emily',
      preview: 'Thanks! 💜',
      time: 'Yesterday',
    ),
    Conversation(
      id: 'c_leo',
      name: 'Leo',
      preview: 'Good game!',
      time: 'Yesterday',
      dot: true,
    ),
    Conversation(
      id: 'c_rose',
      name: 'Rose',
      preview: 'Voice message',
      time: '2d ago',
      isVoiceNote: true,
    ),
    Conversation(
      id: 'c_alex',
      name: 'Alex',
      preview: 'Hey! How are you?',
      time: '2d ago',
      unread: 2,
    ),
  ];

  /// Nav badge count: numbered unreads plus the dot-only rows.
  int get unreadTotal =>
      conversations().fold(0, (sum, c) => sum + c.unread + (c.dot ? 1 : 0));
}
