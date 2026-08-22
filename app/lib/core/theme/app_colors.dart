import 'package:flutter/material.dart';

/// Palette sampled directly from the Room Play mockup
/// (`Desktop/Room play/Room play.png`). Do not hand-tweak these values —
/// if the design changes, re-sample and update here so every screen moves
/// together.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------- surfaces
  /// Screen base. Near-black with a blue cast.
  static const bg = Color(0xFF01050E);

  /// Bars that sit on top of the base: bottom nav, room control bar.
  static const bgElevated = Color(0xFF0E131D);

  /// Standard card / tile fill (category tiles, game cards).
  static const surface = Color(0xFF14172B);

  /// Slightly warmer card used by the room list rows.
  static const surfaceAlt = Color(0xFF121A27);

  /// Raised panels: chat feed background, chat bubbles.
  static const surfaceHigh = Color(0xFF1F2532);

  /// Text field / search field fill.
  static const inputFill = Color(0xFF1D2230);

  static const divider = Color(0xFF111928);

  /// Visible border on an input or outlined control — lighter than [divider],
  /// which is nearly invisible against a filled field.
  static const line = Color(0xFF2A3140);

  // ------------------------------------------------------------------- brand
  /// Primary action purple ("Start Now", primary buttons).
  static const primary = Color(0xFF634BF7);

  /// Lighter purple used by the small "Play" buttons in the games list.
  static const primaryAlt = Color(0xFF7361E9);

  /// Active nav item, links, live-audio indicator.
  static const accent = Color(0xFF4A9BF7);

  // Hero banner gradient (deep indigo → violet).
  static const heroFrom = Color(0xFF1B1781);
  static const heroTo = Color(0xFF3B1D8A);

  // Create-screen cards.
  static const createCardFrom = Color(0xFF31194E);
  static const createCardTo = Color(0xFF6D2C8F);
  static const liveCardFrom = Color(0xFF0A2445);
  static const liveCardTo = Color(0xFF1560A8);

  // -------------------------------------------------------------- semantic
  /// Mic-enabled state on the room control bar.
  static const micActive = Color(0xFF1B7166);

  /// Host crown, coin counts, treasure chest.
  static const gold = Color(0xFFFEBF3C);

  /// User level badges in chat.
  static const levelPink = Color(0xFFDB42AE);

  /// Gift button, warnings.
  static const warning = Color(0xFFF6810D);

  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF30A46C);

  // ------------------------------------------------------------------- text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AE);
  static const textTertiary = Color(0xFF5A6474);

  // --------------------------------------------------------------- gradients
  static const heroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [heroFrom, heroTo],
  );

  static const createGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [createCardFrom, createCardTo],
  );

  static const liveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [liveCardFrom, liveCardTo],
  );

  /// Deterministic avatar backgrounds — index by `name.hashCode`.
  static const avatarGradients = <List<Color>>[
    [Color(0xFF6C4DF6), Color(0xFF9B6DFF)],
    [Color(0xFF2E7DF7), Color(0xFF57C2FF)],
    [Color(0xFFDB42AE), Color(0xFFFF7AC8)],
    [Color(0xFF1B7166), Color(0xFF3FC7A8)],
    [Color(0xFFE5484D), Color(0xFFFF8A6B)],
    [Color(0xFFF6810D), Color(0xFFFFC46B)],
  ];
}
