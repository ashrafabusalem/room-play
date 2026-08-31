import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/room_realtime.dart';
import '../../data/room_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

/// The voice room: nine seats, live chat, and the control bar.
///
/// Everything here is local state over mock data. The pieces that will need a
/// backend are marked with `// SERVER:` so they are easy to find later.
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.room});

  final Room room;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  static const _repo = MockRepository();

  final _chatController = TextEditingController();
  final _scrollController = ScrollController();

  late List<ChatMessage> _messages = _repo.roomChat();
  bool _micOn = false;
  bool _following = false;
  late Room _room = widget.room;
  RoomRepository? _rooms;
  RoomRealtime? _realtime;
  bool _connected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_connected) return;
    final auth = AuthScope.maybeOf(context);
    if (auth?.token == null || !RegExp(r'^\d{6}$').hasMatch(widget.room.id)) {
      return;
    }
    _connected = true;
    _rooms = RoomRepository(auth!.api, currentUserId: auth.publicId);
    _realtime = RoomRealtime(token: auth.token!, currentUserId: auth.publicId);
    unawaited(_join());
  }

  Future<void> _join() async {
    try {
      final room = await _rooms!.join(_room.id);
      if (mounted) setState(() => _room = room);
      await _realtime!.listen(_room.id, (room) {
        if (mounted) setState(() => _room = room);
      });
    } catch (_) {
      // Keep the last known room visible if joining or realtime is unavailable.
    }
  }

  Future<void> _takeSeat(Seat seat) async {
    if (_rooms == null || !seat.isOpen) return;
    try {
      final room = await _rooms!.takeSeat(_room.id, seat.index);
      if (mounted) setState(() => _room = room);
    } catch (_) {}
  }

  Future<void> _toggleMic() async {
    final next = !_micOn;
    if (_rooms == null) {
      setState(() => _micOn = next);
      return;
    }
    try {
      final room = await _rooms!.microphone(_room.id, muted: !next);
      if (mounted) {
        setState(() {
          _room = room;
          _micOn = next;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_rooms != null) {
      unawaited(_rooms!.leave(_room.id).catchError((_) => _room));
    }
    unawaited(_realtime?.dispose());
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      // SERVER: publish to the room channel instead of appending locally.
      _messages = [
        ..._messages,
        ChatMessage(sender: MockRepository.me, text: text),
      ];
      _chatController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      // The feed is reversed, so "newest" is offset 0.
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3E334B), Color(0xFF141A26), AppColors.bg],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _RoomHeader(
                room: room,
                following: _following,
                onFollow: () => setState(() => _following = !_following),
              ),
              const SizedBox(height: 10),
              _RoomMetaPills(room: room),
              const SizedBox(height: 18),
              _SeatGrid(seats: room.seats, micOn: _micOn, onSeatTap: _takeSeat),
              const SizedBox(height: 16),
              Expanded(
                child: _ChatPanel(
                  messages: _messages,
                  controller: _chatController,
                  scrollController: _scrollController,
                  onSend: _send,
                ),
              ),
              _ControlBar(micOn: _micOn, onToggleMic: _toggleMic),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.room,
    required this.following,
    required this.onFollow,
  });

  final Room room;
  final bool following;
  final VoidCallback onFollow;

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
          CircleIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            background: Colors.white.withValues(alpha: 0.10),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  room.name,
                  textDirection: directionOf(room.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: kFontFallback,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).roomIdLabel(room.numericId),
                      style: const TextStyle(
                        fontFamily: kFontFamily,
                        fontFamilyFallback: kFontFallback,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.copy_rounded,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: following
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                following
                    ? AppLocalizations.of(context).roomFollowing
                    : AppLocalizations.of(context).roomFollow,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleIconButton(
            icon: Icons.more_horiz_rounded,
            background: Colors.white.withValues(alpha: 0.10),
            size: 36,
          ),
        ],
      ),
    );
  }
}

class _RoomMetaPills extends StatelessWidget {
  const _RoomMetaPills({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CountPill(
          // The tag is data, but the only value the mock produces is the
          // "chatting" state, so it is rendered from the catalogue for now.
          label: AppLocalizations.of(context).roomTagChatting,
          background: Colors.white.withValues(alpha: 0.10),
          foreground: AppColors.textPrimary,
        ),
        const SizedBox(width: 8),
        CountPill(
          label: room.language,
          icon: Icons.language_rounded,
          background: Colors.white.withValues(alpha: 0.10),
          foreground: AppColors.accent,
        ),
        const SizedBox(width: 8),
        CountPill(
          label: '${room.memberCount}',
          icon: Icons.people_rounded,
          background: Colors.white.withValues(alpha: 0.10),
          foreground: AppColors.textPrimary,
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- seat grid

class _SeatGrid extends StatelessWidget {
  const _SeatGrid({
    required this.seats,
    required this.micOn,
    required this.onSeatTap,
  });

  final List<Seat> seats;
  final bool micOn;
  final ValueChanged<Seat> onSeatTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: seats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 8,
          // Sized to the seat contents (avatar + name + coins); a looser ratio
          // leaves dead space between the rows.
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, i) => _SeatTile(
          seat: seats[i],
          micOn: micOn,
          onTap: () => onSeatTap(seats[i]),
        ),
      ),
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.micOn,
    required this.onTap,
  });

  final Seat seat;
  final bool micOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final user = seat.user;

    if (user == null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${seat.index}',
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              AppLocalizations.of(context).roomSeatOpen,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // "You" reflects the live mic toggle; everyone else uses their mock state.
    final muted = user.isMe ? !micOn : user.micMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AvatarCircle(
                user: user,
                size: 56,
                ringColor: user.isHost
                    ? AppColors.danger
                    : AppColors.primary.withValues(alpha: 0.8),
              ),
              if (user.isHost)
                const Positioned(
                  top: -8,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 18,
                    color: AppColors.gold,
                  ),
                ),
              if (muted)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off_rounded,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.name,
          textDirection: directionOf(user.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: kFontFamily,
            fontFamilyFallback: kFontFallback,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              size: 10,
              color: AppColors.gold,
            ),
            const SizedBox(width: 2),
            Text(
              formatCount(user.coins),
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ chat panel

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  final List<ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        children: [
          Expanded(
            // Reversed so the feed sits on the bottom edge and new messages
            // land next to the input, the way chat is expected to behave.
            child: ListView.separated(
              controller: scrollController,
              reverse: true,
              padding: EdgeInsets.zero,
              itemCount: messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _ChatRow(message: messages[messages.length - 1 - i]),
            ),
          ),
          const SizedBox(height: 8),
          _ChatInput(controller: controller, onSend: onSend),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 13,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).roomSystemSender,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              textDirection: directionOf(message.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    final sender = message.sender!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarCircle(user: sender, size: 26),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LevelBadge(level: sender.level),
              const SizedBox(width: 5),
              Text(
                sender.name,
                textDirection: directionOf(sender.name),
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message.text,
                    textDirection: directionOf(message.text),
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontFamilyFallback: kFontFallback,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSend(),
            textInputAction: TextInputAction.send,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).roomChatHint,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: onSend,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.danger, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------- control bar

class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.micOn, required this.onToggleMic});

  final bool micOn;
  final VoidCallback onToggleMic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ControlButton(
            icon: micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: l10n.roomControlMic,
            background: micOn ? AppColors.micActive : AppColors.surfaceHigh,
            onTap: onToggleMic,
          ),
          _ControlButton(
            icon: Icons.volume_up_rounded,
            label: l10n.roomControlSound,
          ),
          _ControlButton(
            icon: Icons.auto_awesome_rounded,
            label: l10n.roomControlEffects,
          ),
          _ControlButton(
            icon: Icons.sports_esports_rounded,
            label: l10n.roomControlGame,
          ),
          _ControlButton(
            icon: Icons.more_horiz_rounded,
            label: l10n.roomControlMore,
          ),
          const _TreasureChest(),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.background = AppColors.surfaceHigh,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Timed reward chest. The countdown is cosmetic here —
/// SERVER: the real timer must be authoritative or it will be farmed.
class _TreasureChest extends StatelessWidget {
  const _TreasureChest();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.warning, AppColors.gold],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '01:59',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontFamilyFallback: kFontFallback,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
