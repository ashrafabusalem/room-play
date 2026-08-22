import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../games/game_registry.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';

/// Modal sheet behind the centre (+) button.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  static const _repo = MockRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = _repo.games();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.gutter,
                14,
                AppSizes.gutter,
                6,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.close_rounded,
                    size: 32,
                    iconSize: 20,
                    background: Colors.transparent,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.createTitle,
                        style: const TextStyle(
                          fontFamily: kFontFamily,
                          fontFamilyFallback: kFontFallback,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.gutter,
                  8,
                  AppSizes.gutter,
                  32,
                ),
                children: [
                  _ActionCard(
                    gradient: AppColors.createGradient,
                    icon: Icons.mic_rounded,
                    title: l10n.createRoomTitle,
                    subtitle: l10n.createRoomSubtitle,
                    cta: l10n.createRoomCta,
                    ctaColor: AppColors.primary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    gradient: AppColors.liveGradient,
                    icon: Icons.videocam_rounded,
                    title: l10n.goLiveTitle,
                    subtitle: l10n.goLiveSubtitle,
                    cta: l10n.goLiveCta,
                    ctaColor: AppColors.accent,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppSizes.gapXl),
                  Text(
                    l10n.sectionQuickStart,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  _QuickStartGrid(games: games),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.ctaColor,
    required this.onTap,
  });

  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final Color ctaColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        height: 168,
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: kFontFamily,
                          fontFamilyFallback: kFontFallback,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontFamilyFallback: kFontFallback,
                          fontSize: 12,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: ctaColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(cta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStartGrid extends StatelessWidget {
  const _QuickStartGrid({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    final shown = games.take(7).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shown.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        if (i == shown.length) {
          return Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).actionMore,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }

        final game = shown[i];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            GameRegistry.launch(context, game);
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              GlyphTile(
                glyph: game.glyph,
                gradient: game.gradient,
                size: 56,
                radius: 16,
              ),
              const SizedBox(height: 6),
              Text(
                game.name,
                textDirection: directionOf(game.name),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 11,
                  height: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
