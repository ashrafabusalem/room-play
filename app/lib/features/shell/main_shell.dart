import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../create/create_screen.dart';
import '../create/create_room_screen.dart';
import '../games/games_screen.dart';
import '../home/home_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';
import '../rooms/rooms_screen.dart';

/// Bottom-nav container: Home · Rooms · (+) · Messages · Profile.
///
/// The centre (+) is not a tab — it opens the Create sheet, matching the
/// mockup where "Create" is a modal, not a destination.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _repo = MockRepository();
  int _index = 0;

  /// Games is not a nav destination in the mockup — it is pushed on top, so
  /// the back arrow in its app bar has somewhere to go.
  void _openGames() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const GamesScreen()));
  }

  Future<void> _openCreate() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateScreen(),
    );
    if (!mounted || action != 'room') return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateRoomScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The nav bar is opaque, so letting content slide under it just hides
      // rows. Keep the body above it.
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSeeAllGames: _openGames),
          const RoomsScreen(),
          const MessagesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        current: _index,
        unread: _repo.unreadTotal,
        onTap: (i) => setState(() => _index = i),
        onCreate: _openCreate,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.current,
    required this.onTap,
    required this.onCreate,
    required this.unread,
  });

  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset, top: 8),
      child: SizedBox(
        height: 58,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.navHome,
                  selected: current == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.hexagon_outlined,
                  label: l10n.navRooms,
                  selected: current == 1,
                  onTap: () => onTap(1),
                ),
                const Spacer(flex: 1),
                _NavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: l10n.navMessages,
                  selected: current == 2,
                  badge: unread,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: l10n.navProfile,
                  selected: current == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
            Positioned(
              top: -22,
              child: GestureDetector(
                onTap: onCreate,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, Color(0xFF2E7DF7)],
                    ),
                    border: Border.all(color: AppColors.bgElevated, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textTertiary;

    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                if (badge > 0)
                  Positioned(
                    top: -6,
                    right: -12,
                    child: UnreadBadge(count: badge),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
