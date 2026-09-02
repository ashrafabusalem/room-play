import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/room_realtime.dart';
import '../../data/room_repository.dart';
import '../../data/social_repository.dart';
import '../../data/gift_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../profile/public_profile_screen.dart';
import '../games/truth_or_dare_screen.dart';
import '../games/spy_game_screen.dart';

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

  late List<ChatMessage> _messages = RegExp(r'^\d{6}$').hasMatch(widget.room.id)
      ? const []
      : _repo.roomChat();
  bool _micOn = false;
  bool _following = false;
  late Room _room = widget.room;
  RoomRepository? _rooms;
  RoomRealtime? _realtime;
  bool _connected = false;
  final Completer<bool> _joined = Completer<bool>();
  bool _seatRequestInFlight = false;
  LiveGift? _liveGift;
  Timer? _giftTimer;
  RoomRewardStatus? _reward;
  Timer? _rewardTimer;

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

  Future<bool> _join() async {
    try {
      final room = await _rooms!.join(_room.id);
      if (mounted) setState(() => _room = room);
      if (!_joined.isCompleted) _joined.complete(true);
      await _loadReward();
      final messages = await _rooms!.messages(_room.id);
      if (mounted) setState(() => _messages = messages);
      await _realtime!.listen(
        _room.id,
        (room) {
          if (!mounted) return;
          if (_seatRequestInFlight || room.stateVersion <= _room.stateVersion) {
            return;
          }
          if (room.isClosed) {
            Navigator.of(context).maybePop();
          } else {
            setState(() => _room = room);
          }
        },
        onMessage: (message) {
          if (mounted) setState(() => _messages = [..._messages, message]);
          _scrollToNewest();
        },
        onGift: _showGift,
      );
      return true;
    } catch (_) {
      // Keep the last known room visible if joining or realtime is unavailable.
      if (!_joined.isCompleted) _joined.complete(false);
      return false;
    }
  }

  Future<void> _takeSeat(Seat seat) async {
    if (_rooms == null || !seat.isOpen || _seatRequestInFlight) return;
    final joined = await _joined.future;
    if (!mounted || !joined || !seat.isOpen || _seatRequestInFlight) return;
    final previousRoom = _room;
    final knownMe = _room.seats
        .map((seat) => seat.user)
        .followedBy(_room.members)
        .whereType<AppUser>()
        .where((user) => user.isMe)
        .firstOrNull;
    final auth = AuthScope.of(context);
    final me =
        knownMe ??
        (auth.publicId == null
            ? null
            : AppUser(
                id: auth.publicId!,
                name: auth.name ?? '',
                level: auth.level,
                isMe: true,
              ));
    _seatRequestInFlight = true;
    if (me != null) {
      setState(
        () => _room = _room.copyWith(
          seats: _room.seats
              .map(
                (current) => current.index == seat.index
                    ? current.copyWith(user: me)
                    : current.user?.isMe == true
                    ? current.copyWith(clearUser: true)
                    : current,
              )
              .toList(growable: false),
        ),
      );
    }
    try {
      final room = await _rooms!.takeSeat(_room.id, seat.index);
      if (mounted) setState(() => _room = room);
    } catch (_) {
      if (mounted) setState(() => _room = previousRoom);
    } finally {
      _seatRequestInFlight = false;
    }
  }

  Future<void> _seatAction(Seat seat) async {
    final isHost = _room.seats.any(
      (s) => s.user?.isMe == true && s.user?.isHost == true,
    );
    if (!isHost) return _takeSeat(seat);
    final l = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (seat.user == null && !seat.locked)
              ListTile(
                leading: const Icon(Icons.event_seat_rounded),
                title: Text(l.roomTakeSeat),
                onTap: () => Navigator.pop(context, 'take'),
              ),
            if (seat.user == null)
              ListTile(
                leading: Icon(
                  seat.locked ? Icons.lock_open_rounded : Icons.lock_rounded,
                ),
                title: Text(seat.locked ? l.roomUnlockSeat : l.roomLockSeat),
                onTap: () => Navigator.pop(context, 'lock'),
              ),
            if (seat.user != null)
              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: Text(l.roomViewProfile),
                onTap: () => Navigator.pop(context, 'profile'),
              ),
            if (seat.user != null && !seat.user!.isHost && !seat.user!.isMe)
              ListTile(
                leading: const Icon(
                  Icons.person_remove_rounded,
                  color: AppColors.danger,
                ),
                title: Text(l.roomRemoveMember),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            if (seat.user != null && !seat.user!.isHost && !seat.user!.isMe)
              ListTile(
                leading: const Icon(
                  Icons.block_rounded,
                  color: AppColors.danger,
                ),
                title: Text(l.roomBanMember),
                onTap: () => Navigator.pop(context, 'ban'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'take') return _takeSeat(seat);
    if (action == 'profile') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PublicProfileScreen(userId: seat.user!.id),
        ),
      );
      return;
    }
    try {
      final room = switch (action) {
        'lock' => await _rooms!.lockSeat(
          _room.id,
          seat.index,
          locked: !seat.locked,
        ),
        'ban' => await _rooms!.banMember(_room.id, seat.user!.id),
        _ => await _rooms!.removeMember(_room.id, seat.user!.id),
      };
      if (mounted) setState(() => _room = room);
    } catch (_) {}
  }

  Future<void> _roomSettings() async {
    final isHost = _room.seats.any(
      (s) => s.user?.isMe == true && s.user?.isHost == true,
    );
    if (!isHost || _rooms == null) return;
    final l = AppLocalizations.of(context);
    final name = TextEditingController(text: _room.name);
    var language = _room.language;
    var tag = _room.tag.toLowerCase();
    var locked = _room.isLocked;
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.roomSettingsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  maxLength: 80,
                  decoration: InputDecoration(labelText: l.createRoomName),
                ),
                DropdownButtonFormField<String>(
                  initialValue: language,
                  decoration: InputDecoration(labelText: l.createRoomLanguage),
                  items: const [
                    DropdownMenuItem(value: 'EN', child: Text('English')),
                    DropdownMenuItem(value: 'AR', child: Text('العربية')),
                  ],
                  onChanged: (v) => setDialogState(() => language = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tag,
                  decoration: InputDecoration(labelText: l.createRoomTopic),
                  items:
                      [
                            ('chatting', l.createRoomTopicChatting),
                            ('gaming', l.createRoomTopicGaming),
                            ('music', l.createRoomTopicMusic),
                            ('party', l.createRoomTopicParty),
                          ]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v.$1,
                              child: Text(v.$2),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setDialogState(() => tag = v!),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.roomLockEntry),
                  value: locked,
                  onChanged: (v) => setDialogState(() => locked = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.block_rounded),
                  title: Text(l.roomBannedUsers),
                  trailing: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                  ),
                  onTap: () => Navigator.pop(dialogContext, 'bans'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'close'),
              child: Text(
                l.roomCloseRoom,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              child: Text(l.profileSave),
            ),
          ],
        ),
      ),
    );
    final roomName = name.text.trim();
    name.dispose();
    if (!mounted || action == null) return;
    if (action == 'bans') {
      await _manageRoomBans();
      return;
    }
    if (action == 'close') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.roomCloseConfirmTitle),
          content: Text(l.roomCloseConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.roomCloseRoom),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await _rooms!.close(_room.id);
        if (mounted) Navigator.of(context).pop();
      }
      return;
    }
    if (roomName.length < 2) return;
    final room = await _rooms!.updateSettings(
      _room.id,
      name: roomName,
      language: language,
      tag: tag,
      isLocked: locked,
    );
    if (mounted) setState(() => _room = room);
  }

  Future<void> _leaveRoom() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.roomLeaveConfirmTitle),
        content: Text(l.roomLeaveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.roomLeaveRoom),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (_rooms == null) {
      Navigator.of(context).pop();
      return;
    }
    try {
      await _rooms!.leave(_room.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {}
  }

  Future<void> _manageRoomBans() async {
    final l = AppLocalizations.of(context);
    List<AppUser> users;
    try {
      users = await _rooms!.bannedUsers(_room.id);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text(l.roomBannedUsers)),
                if (users.isEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      8,
                      24,
                      24,
                    ),
                    child: Text(l.roomNoBannedUsers),
                  ),
                for (final user in users)
                  ListTile(
                    leading: AvatarCircle(user: user, size: 40),
                    title: Text(
                      user.name,
                      textDirection: directionOf(user.name),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        try {
                          await _rooms!.unban(_room.id, user.id);
                          setSheetState(() => users = [...users]..remove(user));
                        } catch (_) {}
                      },
                      child: Text(l.roomUnban),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
    unawaited(_realtime?.dispose());
    _chatController.dispose();
    _scrollController.dispose();
    _giftTimer?.cancel();
    _rewardTimer?.cancel();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    if (_rooms == null) {
      setState(
        () => _messages = [
          ..._messages,
          ChatMessage(sender: MockRepository.me, text: text),
        ],
      );
    } else {
      final auth = AuthScope.of(context);
      final pending = ChatMessage(
        sender: AppUser(
          id: auth.publicId ?? '',
          name: auth.name ?? '',
          level: auth.level,
          isMe: true,
        ),
        text: text,
      );
      setState(() => _messages = [..._messages, pending]);
      _scrollToNewest();
      try {
        final message = await _rooms!.sendMessage(_room.id, text);
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere(
              (item) => identical(item, pending),
            );
            if (index < 0) return;
            _messages = [..._messages]..[index] = message;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(
            () => _messages = _messages
                .where((item) => !identical(item, pending))
                .toList(growable: false),
          );
          _chatController.text = text;
        }
        return;
      }
    }
    _scrollToNewest();
  }

  Future<void> _openChatComposer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  autofocus: true,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    Navigator.pop(sheetContext);
                    unawaited(_send());
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).roomChatHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  unawaited(_send());
                },
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToNewest() {
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

  void _showGift(LiveGift gift) {
    _giftTimer?.cancel();
    if (mounted) setState(() => _liveGift = gift);
    _giftTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _liveGift = null);
    });
  }

  Future<void> _loadReward() async {
    try {
      final reward = await _rooms!.rewardStatus(_room.id);
      if (!mounted) return;
      setState(() => _reward = reward);
      _rewardTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (_) {}
  }

  Future<void> _claimReward() async {
    if (_rooms == null || _reward?.available != true) return;
    try {
      final reward = await _rooms!.claimReward(_room.id);
      if (!mounted) return;
      setState(() => _reward = reward);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).roomRewardClaimed(reward.reward),
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _openGifts() async {
    if (_rooms == null) return;
    final auth = AuthScope.of(context);
    final recipients = _room.members
        .where((user) => user.id != auth.publicId)
        .toList();
    final gifts = await GiftRepository(auth.api).gifts();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _GiftSheet(
        gifts: gifts,
        recipients: recipients,
        onSend: (gift, recipient) async {
          await GiftRepository(auth.api).send(_room.id, gift.id, recipient.id);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).giftSent(recipient.name),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _inviteFriends() async {
    final l10n = AppLocalizations.of(context);
    final social = SocialRepository(AuthScope.of(context).api);
    final friends = await social.friends();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.socialInvite),
        content: SizedBox(
          width: 360,
          child: friends.isEmpty
              ? Text(l10n.socialEmptyFriends)
              : ListView(
                  shrinkWrap: true,
                  children: friends
                      .map(
                        (friend) => ListTile(
                          leading: AvatarCircle(user: friend, size: 42),
                          title: Text(friend.name),
                          trailing: const Icon(Icons.send_rounded),
                          onTap: () async {
                            await social.inviteToRoom(_room.id, friend.id);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.socialInvited)),
                              );
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }

  Future<void> _openGames() async {
    final l = AppLocalizations.of(context);
    final game = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🕵️', style: TextStyle(fontSize: 30)),
              title: Text(l.spyTitle),
              onTap: () => Navigator.pop(context, 'spy'),
            ),
            ListTile(
              leading: const Text('🎭', style: TextStyle(fontSize: 30)),
              title: Text(l.truthDareTitle),
              onTap: () => Navigator.pop(context, 'truth'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || game == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => game == 'spy'
            ? SpyGameScreen(room: _room)
            : TruthOrDareScreen(room: _room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final isHost = room.seats.any(
      (seat) => seat.user?.isMe == true && seat.user?.isHost == true,
    );
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3E334B), Color(0xFF141A26), AppColors.bg],
              stops: [0, 0.45, 1],
            ),
          ),
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Column(
              children: [
                keyboardOpen
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoomHeader(
                            room: room,
                            following: _following,
                            onFollow: () =>
                                setState(() => _following = !_following),
                            onInvite: _inviteFriends,
                            onGame: _openGames,
                          ),
                          const SizedBox(height: 10),
                          _RoomMetaPills(room: room),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _liveGift == null
                                ? const SizedBox.shrink()
                                : _LiveGiftBanner(
                                    key: ValueKey(_liveGift),
                                    gift: _liveGift!,
                                  ),
                          ),
                          const SizedBox(height: 18),
                          _SeatGrid(
                            seats: room.seats,
                            micOn: _micOn,
                            onSeatTap: _seatAction,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                Expanded(
                  child: _ChatPanel(
                    messages: _messages,
                    controller: _chatController,
                    scrollController: _scrollController,
                    onInputTap: _openChatComposer,
                    onGift: _openGifts,
                  ),
                ),
                keyboardOpen
                    ? const SizedBox.shrink()
                    : _ControlBar(
                        micOn: _micOn,
                        onToggleMic: _toggleMic,
                        reward: _reward,
                        onReward: _claimReward,
                        onGame: _openGames,
                        onMore: isHost ? _roomSettings : _leaveRoom,
                      ),
              ],
            ),
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
    required this.onInvite,
    required this.onGame,
  });

  final Room room;
  final bool following;
  final VoidCallback onFollow;
  final VoidCallback onInvite;
  final VoidCallback onGame;

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
          CircleIconButton(
            icon: following
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            background: following
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.10),
            size: 36,
            onTap: onFollow,
          ),
          const SizedBox(width: 6),
          CircleIconButton(
            icon: Icons.casino_rounded,
            background: Colors.white.withValues(alpha: 0.10),
            size: 36,
            onTap: onGame,
          ),
          const SizedBox(width: 6),
          CircleIconButton(
            icon: Icons.person_add_alt_1_rounded,
            background: Colors.white.withValues(alpha: 0.10),
            size: 36,
            onTap: onInvite,
          ),
        ],
      ),
    );
  }
}

class _LiveGiftBanner extends StatelessWidget {
  const _LiveGiftBanner({super.key, required this.gift});
  final LiveGift gift;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = gift.name(Localizations.localeOf(context).languageCode);
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(gift.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l.giftLive(gift.senderName, name, gift.recipientName),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: directionOf(
                l.giftLive(gift.senderName, name, gift.recipientName),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
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
          // Sized to the seat contents (avatar + name + Gold); a looser ratio
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
              child: Icon(
                seat.locked ? Icons.lock_rounded : Icons.add_rounded,
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
              seat.locked
                  ? AppLocalizations.of(context).roomSeatLocked
                  : AppLocalizations.of(context).roomSeatOpen,
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
              GestureDetector(
                onTap: user.isMe
                    ? onTap
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PublicProfileScreen(userId: user.id),
                        ),
                      ),
                child: AvatarCircle(
                  user: user,
                  size: 56,
                  ringColor: user.isHost
                      ? AppColors.danger
                      : AppColors.primary.withValues(alpha: 0.8),
                ),
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
    required this.onInputTap,
    required this.onGift,
  });

  final List<ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onInputTap;
  final VoidCallback onGift;

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
          _ChatInput(controller: controller, onTap: onInputTap, onGift: onGift),
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
        GestureDetector(
          onTap: sender.isMe
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PublicProfileScreen(userId: sender.id),
                  ),
                ),
          child: AvatarCircle(user: sender, size: 26),
        ),
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

class _GiftSheet extends StatefulWidget {
  const _GiftSheet({
    required this.gifts,
    required this.recipients,
    required this.onSend,
  });
  final List<GiftItem> gifts;
  final List<AppUser> recipients;
  final Future<void> Function(GiftItem, AppUser) onSend;
  @override
  State<_GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<_GiftSheet> {
  AppUser? recipient;
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.giftSendTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            if (widget.recipients.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l.giftNoRecipients),
              )
            else ...[
              DropdownButtonFormField<AppUser>(
                initialValue: recipient,
                decoration: InputDecoration(labelText: l.giftRecipient),
                items: widget.recipients
                    .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                    .toList(),
                onChanged: busy ? null : (u) => setState(() => recipient = u),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.gifts.length,
                itemBuilder: (_, i) {
                  final gift = widget.gifts[i];
                  return Material(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: busy || recipient == null
                          ? null
                          : () async {
                              setState(() => busy = true);
                              try {
                                await widget.onSend(gift, recipient!);
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                        SnackBar(content: Text(l.giftFailed)),
                                      );
                                }
                              } finally {
                                if (mounted) setState(() => busy = false);
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gift.emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              gift.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l.giftPrice(gift.price),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onTap,
    required this.onGift,
  });

  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onGift;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onTap: onTap,
            readOnly: true,
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
                onPressed: onTap,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onGift,
          child: Container(
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
  const _ControlBar({
    required this.micOn,
    required this.onToggleMic,
    required this.reward,
    required this.onReward,
    required this.onGame,
    required this.onMore,
  });

  final bool micOn;
  final VoidCallback onToggleMic;
  final RoomRewardStatus? reward;
  final VoidCallback onReward;
  final VoidCallback onGame;
  final VoidCallback onMore;

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
            onTap: onGame,
          ),
          _ControlButton(
            icon: Icons.more_horiz_rounded,
            label: l10n.roomControlMore,
            onTap: onMore,
          ),
          _TreasureChest(status: reward, onTap: onReward),
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
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
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
      ),
    );
  }
}

/// Timed reward chest. The countdown is cosmetic here —
/// SERVER: the real timer must be authoritative or it will be farmed.
class _TreasureChest extends StatelessWidget {
  const _TreasureChest({required this.status, required this.onTap});
  final RoomRewardStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = status?.readyAt?.difference(DateTime.now());
    final available =
        status?.available == true ||
        (remaining != null && remaining.inSeconds <= 0);
    final seconds = remaining == null || remaining.inSeconds <= 0
        ? 0
        : remaining.inSeconds;
    final label = status == null
        ? '--:--'
        : available
        ? AppLocalizations.of(context).roomRewardReady
        : '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Column(
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
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
