import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/gen/app_localizations.dart';

/// Reading direction for a piece of *content* — a username, room name, game
/// title, chat message.
///
/// UI chrome follows the app's language, but content does not: an English game
/// title inside an Arabic UI is still English. Without this, bidi reordering
/// throws trailing punctuation to the wrong end and "Who's The Spy?" renders as
/// "?Who's The Spy".
///
/// Detected per string, so it keeps working when names start arriving from the
/// server in mixed languages.
TextDirection directionOf(String text) =>
    Bidi.detectRtlDirectionality(text) ? TextDirection.rtl : TextDirection.ltr;

/// "Popular Games            See All >"
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(
      AppSizes.gutter,
      0,
      AppSizes.gutter,
      12,
    ),
  });

  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).actionSeeAll,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontFamilyFallback: kFontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Icons do not mirror themselves; a "forward" chevron has to
                  // point the other way in RTL.
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Small pill: "👥 25", "🪙 680", "EN".
class CountPill extends StatelessWidget {
  const CountPill({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// The pink level chip that precedes a username in room chat.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.levelPink, Color(0xFFFF7AC8)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 9, color: Colors.white),
          Text(
            '$level',
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Red unread counter used by the bottom nav and message rows.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count, this.color});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color ?? AppColors.danger,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontFamily: kFontFamily,
          fontFamilyFallback: kFontFallback,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

/// Rounded gradient square standing in for game artwork.
///
/// PLACEHOLDER — real games need illustrated icons. See
/// `assets/games/README.md` for the sizes to supply.
class GlyphTile extends StatelessWidget {
  const GlyphTile({
    super.key,
    required this.glyph,
    required this.gradient,
    this.size = 48,
    this.radius = 14,
  });

  final String glyph;
  final List<Color> gradient;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size * 0.46,
          // Inter carries no emoji glyphs. Android and iOS fall back on their
          // own, but web and desktop need to be told where to look.
          fontFamilyFallback: kFontFallback,
        ),
      ),
    );
  }
}

/// Circular icon button used across the room control bar and app bars.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.background = AppColors.surfaceHigh,
    this.foreground = AppColors.textPrimary,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color foreground;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize ?? size * 0.5, color: foreground),
        ),
      ),
    );
  }
}

/// Placeholder body for screens that exist in the nav bar but were not part of
/// the delivered mockup.
class NotDesignedYet extends StatelessWidget {
  const NotDesignedYet({super.key, required this.screen, required this.note});

  final String screen;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.design_services_rounded,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(screen, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              note,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
