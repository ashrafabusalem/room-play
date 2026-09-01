import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../data/social_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../auth/auth_controller.dart';
import '../rooms/room_screen.dart';
import 'public_profile_screen.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});
  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  List<AppUser> _friends = [];
  List<AppUser> _followers = [];
  List<AppUser> _following = [];
  List<FriendRequestItem> _requests = [];
  List<RoomInvitationItem> _invites = [];
  bool _loading = true;

  SocialRepository get _repo => SocialRepository(AuthScope.of(context).api);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        _repo.friends(),
        _repo.friendRequests(),
        _repo.roomInvitations(),
        _repo.followers(),
        _repo.following(),
      ]);
      if (mounted) {
        setState(() {
          _friends = values[0] as List<AppUser>;
          _requests = values[1] as List<FriendRequestItem>;
          _invites = values[2] as List<RoomInvitationItem>;
          _followers = values[3] as List<AppUser>;
          _following = values[4] as List<AppUser>;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respondFriend(FriendRequestItem request, bool accept) async {
    await _repo.respondFriendRequest(request.id, accept);
    await _load();
  }

  Future<void> _removeFriend(AppUser user) async {
    await _repo.removeFriend(user.id);
    await _load();
  }

  Future<void> _respondInvite(RoomInvitationItem invite, bool accept) async {
    final room = await _repo.respondRoomInvitation(invite.id, accept);
    await _load();
    if (room != null && mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => RoomScreen(room: room)));
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.socialTitle),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.socialFriends),
            Tab(text: l10n.profileFollowers),
            Tab(text: l10n.profileFollowing),
            Tab(text: '${l10n.socialRequests} (${_requests.length})'),
            Tab(text: '${l10n.socialInvitations} (${_invites.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _UserList(
                  users: _friends,
                  empty: l10n.socialEmptyFriends,
                  onRemove: _removeFriend,
                ),
                _UserList(users: _followers, empty: l10n.socialEmptyFriends),
                _UserList(users: _following, empty: l10n.socialEmptyFriends),
                _ActionList(
                  empty: l10n.socialEmptyRequests,
                  count: _requests.length,
                  itemBuilder: (context, index) {
                    final item = _requests[index];
                    return _SocialTile(
                      user: item.user,
                      actions: [
                        TextButton(
                          onPressed: () => _respondFriend(item, false),
                          child: Text(l10n.socialDecline),
                        ),
                        FilledButton(
                          onPressed: () => _respondFriend(item, true),
                          child: Text(l10n.socialAccept),
                        ),
                      ],
                    );
                  },
                ),
                _ActionList(
                  empty: l10n.socialEmptyInvites,
                  count: _invites.length,
                  itemBuilder: (context, index) {
                    final item = _invites[index];
                    return ListTile(
                      leading: AvatarCircle(user: item.inviter, size: 46),
                      title: Text(item.room.name),
                      subtitle: Text(item.inviter.name),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          TextButton(
                            onPressed: () => _respondInvite(item, false),
                            child: Text(l10n.socialDecline),
                          ),
                          FilledButton(
                            onPressed: () => _respondInvite(item, true),
                            child: Text(l10n.socialJoinRoom),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.users, required this.empty, this.onRemove});
  final List<AppUser> users;
  final String empty;
  final ValueChanged<AppUser>? onRemove;
  @override
  Widget build(BuildContext context) => users.isEmpty
      ? _Empty(text: empty)
      : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: users.length,
          itemBuilder: (_, index) => _SocialTile(
            user: users[index],
            actions: onRemove == null
                ? const []
                : [
                    IconButton(
                      tooltip: AppLocalizations.of(context).socialRemoveFriend,
                      onPressed: () => onRemove!(users[index]),
                      icon: const Icon(Icons.person_remove_rounded),
                    ),
                  ],
          ),
        );
}

class _ActionList extends StatelessWidget {
  const _ActionList({
    required this.empty,
    required this.count,
    required this.itemBuilder,
  });
  final String empty;
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) => count == 0
      ? _Empty(text: empty)
      : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: count,
          itemBuilder: itemBuilder,
        );
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({required this.user, this.actions = const []});
  final AppUser user;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicProfileScreen(userId: user.id),
      ),
    ),
    leading: AvatarCircle(user: user, size: 46),
    title: Text(user.name),
    subtitle: Text('ID ${user.id} · Lv.${user.level}'),
    trailing: actions.isEmpty
        ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary)
        : Wrap(spacing: 6, children: actions),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
  );
}
