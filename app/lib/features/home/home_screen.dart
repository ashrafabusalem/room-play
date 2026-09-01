import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/content_repository.dart';
import '../../data/models.dart';
import '../../data/notification_repository.dart';
import '../../data/room_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../rooms/room_screen.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_screen.dart';
import '../rankings/rankings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSeeAllGames});

  final VoidCallback onSeeAllGames;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _fallback = MockRepository();
  final _content = ContentRepository();
  List<HeroBanner>? _banners;
  List<Room>? _rooms;
  String? _loadedLocale;
  int _unreadNotifications = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_loadedLocale == locale) return;
    _loadedLocale = locale;
    _banners = _fallback.banners(AppLocalizations.of(context));
    unawaited(_loadBanners(locale));
    unawaited(_loadRooms());
    unawaited(_loadNotifications());
  }

  Future<void> _loadNotifications() async {
    try {
      final feed = await NotificationRepository(AuthScope.of(context).api)
          .load();
      if (mounted) setState(() => _unreadNotifications = feed.unreadCount);
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) await _loadNotifications();
  }

  Future<void> _loadRooms() async {
    final auth = AuthScope.of(context);
    try {
      final rooms = await RoomRepository(
        auth.api,
        currentUserId: auth.publicId,
      ).rooms();
      if (mounted) setState(() => _rooms = rooms);
    } catch (_) {
      // Keep the built-in recommendations available while offline.
    }
  }

  Future<void> _loadBanners(String locale) async {
    try {
      final banners = await _content.banners(locale);
      if (!mounted || _loadedLocale != locale || banners.isEmpty) return;
      setState(() => _banners = banners);
    } catch (_) {
      // The translated built-in banners remain visible while offline.
    }
  }

  @override
  void dispose() {
    _content.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rooms = _rooms ?? _fallback.rooms();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _HomeHeader(
            unreadNotifications: _unreadNotifications,
            onNotifications: _openNotifications,
            onRankings: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RankingsScreen()),
            ),
          ),
          const SizedBox(height: AppSizes.gapL),
          _HeroCarousel(banners: _banners ?? _fallback.banners(l10n)),
          const SizedBox(height: AppSizes.gapXl),
          _CategoryRow(categories: _fallback.categories(l10n)),
          const SizedBox(height: AppSizes.gapXl),
          SectionHeader(
            title: l10n.sectionPopularGames,
            onSeeAll: widget.onSeeAllGames,
          ),
          _PopularGamesRail(games: _fallback.games()),
          const SizedBox(height: AppSizes.gapXl),
          SectionHeader(title: l10n.sectionRecommendedRooms),
          for (final room in rooms) ...[
            _RoomRow(room: room),
            const SizedBox(height: AppSizes.gapM),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.unreadNotifications,
    required this.onNotifications,
    required this.onRankings,
  });

  final int unreadNotifications;
  final VoidCallback onNotifications;
  final VoidCallback onRankings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.gutter,
        8,
        AppSizes.gutter,
        0,
      ),
      child: Row(
        children: [
          // Badge mark from the logo. The lockup's own lettering is unreadable
          // at this size, so it reads as a mark and the wordmark carries the
          // name.
          Image.asset(
            'assets/brand/logo.png',
            width: 30,
            height: 30,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Room',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: 'Play',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const Spacer(),
          _HeaderIcon(icon: Icons.emoji_events_rounded, onTap: onRankings),
          const SizedBox(width: 4),
          const _HeaderIcon(icon: Icons.search_rounded),
          const SizedBox(width: 4),
          _HeaderIcon(
            icon: Icons.notifications_rounded,
            hasDot: unreadNotifications > 0,
            onTap: onNotifications,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.hasDot = false, this.onTap});

  final IconData icon;
  final bool hasDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            if (hasDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ hero

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.banners});

  final List<HeroBanner> banners;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          // The mockup's 168 fits English exactly and clips Arabic: Cairo's
          // line metrics are taller than Inter's, and translated copy is rarely
          // the same length. Sized for the tallest script instead — English
          // just gets a little more air under the button.
          height: 196,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
              child: _HeroCard(banner: widget.banners[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.banner});

  final HeroBanner banner;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            if (banner.imageUrl case final imageUrl?)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            if (banner.imageUrl != null)
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
              ),
            // Soft light blooms, standing in for the mascot illustration.
            Positioned(
              right: -30,
              top: -20,
              child: _Bloom(
                size: 150,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: _Bloom(
                size: 110,
                color: AppColors.accent.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flexible with maxLines is the safety net for a language
                  // longer than any tested here — it ellipsises rather than
                  // throwing an overflow. The card is sized so it should never
                  // actually trigger.
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            banner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: kFontFamily,
                              fontFamilyFallback: kFontFallback,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            banner.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontFamilyFallback: kFontFallback,
                              fontSize: 12,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(banner.cta),
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

class _Bloom extends StatelessWidget {
  const _Bloom({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ------------------------------------------------------------- categories

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<HomeCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _CategoryTile(category: categories[i])),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(category.icon, size: 24, color: category.color),
              const SizedBox(height: 8),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- popular games

class _PopularGamesRail extends StatelessWidget {
  const _PopularGamesRail({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    // 118 tile + label + player count. Inter's line metrics need ~179; do not
    // trim this further without re-running the widget tests.
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _PopularGameCard(game: games[i]),
      ),
    );
  }
}

class _PopularGameCard extends StatelessWidget {
  const _PopularGameCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlyphTile(
            glyph: game.glyph,
            gradient: game.gradient,
            size: 118,
            radius: AppSizes.tileRadius,
          ),
          const SizedBox(height: 8),
          Text(
            game.name,
            textDirection: directionOf(game.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppLocalizations.of(context).playersPlaying(game.playersLabel),
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- room rows

class _RoomRow extends StatelessWidget {
  const _RoomRow({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final gradient =
        AppColors.avatarGradients[room.id.hashCode.abs() %
            AppColors.avatarGradients.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: Material(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => RoomScreen(room: room)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        textDirection: directionOf(room.name),
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
                          AvatarStack(users: room.members, size: 20),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${room.memberCount}',
                            style: const TextStyle(
                              fontFamily: kFontFamily,
                              fontFamilyFallback: kFontFallback,
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CountPill(label: room.language, dense: true),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF9B6DFF)],
                    ),
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
