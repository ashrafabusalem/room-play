import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../data/notification_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../messages/conversation_screen.dart';
import '../profile/public_profile_screen.dart';
import '../profile/social_hub_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationRepository? _repository;
  NotificationFeed? _feed;
  bool _changed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repository != null) return;
    _repository = NotificationRepository(AuthScope.of(context).api);
    _load();
  }

  Future<void> _load() async {
    try {
      final feed = await _repository!.load();
      if (mounted) setState(() => _feed = feed);
    } catch (_) {
      if (mounted) {
        setState(
          () => _feed = const NotificationFeed(unreadCount: 0, items: []),
        );
      }
    }
  }

  Future<void> _readAll() async {
    await _repository!.readAll();
    _changed = true;
    await _load();
  }

  Future<void> _open(InboxNotification item) async {
    if (item.isUnread) {
      await _repository!.read(item.id);
      _changed = true;
      await _load();
    }
    if (!mounted) return;
    final actor = item.actor;
    Widget? destination;
    switch (item.type) {
      case 'new_follower':
      case 'friend_accepted':
        if (actor != null) destination = PublicProfileScreen(userId: actor.id);
      case 'friend_request':
      case 'room_invitation':
        destination = const SocialHubScreen();
      case 'direct_message':
        final conversationId = item.data['conversation_id']?.toString();
        if (actor != null && conversationId != null) {
          destination = ConversationScreen(
            conversation: Conversation(
              id: conversationId,
              userId: actor.id,
              name: actor.name,
              avatarUrl: actor.avatarUrl,
              preview: item.data['preview']?.toString() ?? '',
              time: '',
            ),
          );
        }
    }
    if (destination != null) {
      await Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => destination!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = _feed;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => Navigator.of(context).pop(_changed),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationsTitle),
          actions: [
            if ((feed?.unreadCount ?? 0) > 0)
              TextButton(
                onPressed: _readAll,
                child: Text(l10n.notificationsMarkAllRead),
              ),
          ],
        ),
        body: feed == null
            ? const Center(child: CircularProgressIndicator())
            : feed.items.isEmpty
            ? Center(child: Text(l10n.notificationsEmpty))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: feed.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = feed.items[index];
                  final title = _title(l10n, item);
                  final body = _body(l10n, item);
                  return Material(
                    color: item.isUnread
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () => _open(item),
                      leading: _NotificationAvatar(item: item),
                      title: Text(title, textDirection: directionOf(title)),
                      subtitle: body == null
                          ? null
                          : Text(
                              body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textDirection: directionOf(body),
                            ),
                      trailing: item.isUnread
                          ? const Icon(
                              Icons.circle,
                              size: 9,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _title(AppLocalizations l10n, InboxNotification item) {
    final name = item.actor?.name ?? l10n.notificationsSomeone;
    return switch (item.type) {
      'new_follower' => l10n.notificationNewFollower(name),
      'friend_request' => l10n.notificationFriendRequest(name),
      'friend_accepted' => l10n.notificationFriendAccepted(name),
      'room_invitation' => l10n.notificationRoomInvitation(name),
      'direct_message' => l10n.notificationDirectMessage(name),
      _ => l10n.notificationsTitle,
    };
  }

  String? _body(AppLocalizations l10n, InboxNotification item) =>
      switch (item.type) {
        'room_invitation' => item.data['room_name']?.toString(),
        'direct_message' => item.data['preview']?.toString(),
        _ => null,
      };
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.item});
  final InboxNotification item;

  @override
  Widget build(BuildContext context) {
    final actor = item.actor;
    if (actor != null) {
      return CircleAvatar(
        backgroundColor: AppColors.primary,
        backgroundImage: actor.avatarUrl == null
            ? null
            : NetworkImage(actor.avatarUrl!),
        child: actor.avatarUrl == null ? Text(actor.initials) : null,
      );
    }
    return const CircleAvatar(child: Icon(Icons.notifications_rounded));
  }
}
