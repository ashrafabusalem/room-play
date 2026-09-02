import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/social_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../../data/direct_message_repository.dart';
import '../messages/conversation_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  SocialProfile? _profile;
  bool _busy = false;

  SocialRepository get _repo => SocialRepository(AuthScope.of(context).api);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null && !_busy) _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final profile = await _repo.profile(widget.userId);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // The loading state is cleared below; retrying is handled by reopening.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _follow() async {
    final current = _profile!;
    setState(() => _busy = true);
    try {
      final updated = await _repo.follow(current.id, !current.isFollowing);
      if (mounted) setState(() => _profile = updated);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _block() async {
    final profile = _profile!;
    await _repo.block(profile.id, !profile.isBlocked);
    if (mounted) await _load();
  }

  Future<void> _addFriend() async {
    final l10n = AppLocalizations.of(context);
    await _repo.sendFriendRequest(widget.userId);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.socialRequestSent)));
    }
  }

  Future<void> _message() async {
    setState(() => _busy = true);
    try {
      final auth = AuthScope.of(context);
      final conversation = await DirectMessageRepository(
        auth.api,
        currentUserId: auth.publicId,
      ).start(widget.userId);
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConversationScreen(conversation: conversation),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    var reason = 'harassment';
    final details = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.profileReport),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: reason,
                decoration: InputDecoration(
                  labelText: l10n.profileReportReason,
                ),
                items:
                    [
                          ('harassment', l10n.profileReportHarassment),
                          ('spam', l10n.profileReportSpam),
                          ('impersonation', l10n.profileReportImpersonation),
                          ('inappropriate', l10n.profileReportInappropriate),
                          ('other', l10n.profileReportOther),
                        ]
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.$1,
                            child: Text(item.$2),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setDialogState(() => reason = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: details,
                maxLength: 1000,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.profileReportDetails,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () async {
                await _repo.report(widget.userId, reason, details.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.profileReport),
            ),
          ],
        ),
      ),
    );
    details.dispose();
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileReportSent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? l10n.profileTitle),
        actions: profile == null || profile.isMe
            ? null
            : [
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      value == 'block' ? _block() : _report(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Text(
                        profile.isBlocked
                            ? l10n.profileUnblock
                            : l10n.profileBlock,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Text(l10n.profileReport),
                    ),
                  ],
                ),
              ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: _ProfileAvatar(profile: profile)),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  textDirection: directionOf(profile.name),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'ID ${profile.id} · Lv.${profile.level}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (profile.bio?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    textDirection: directionOf(profile.bio!),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                      value: profile.following,
                      label: l10n.profileFollowing,
                    ),
                    _Stat(
                      value: profile.followers,
                      label: l10n.profileFollowers,
                    ),
                  ],
                ),
                if (!profile.isMe && !profile.blockedBy) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy || profile.isBlocked
                              ? null
                              : _follow,
                          child: Text(
                            profile.isFollowing
                                ? l10n.profileUnfollow
                                : l10n.profileFollow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _busy ||
                                  profile.isBlocked ||
                                  profile.friendshipStatus == 'accepted' ||
                                  profile.friendshipStatus == 'pending'
                              ? null
                              : _addFriend,
                          child: Text(
                            profile.friendshipStatus == 'accepted'
                                ? l10n.socialAlreadyFriends
                                : profile.friendshipStatus == 'pending'
                                ? (profile.friendRequestDirection == 'received'
                                      ? l10n.socialRequestReceived
                                      : l10n.socialRequestPending)
                                : l10n.socialAddFriend,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (profile.friendshipStatus == 'accepted') ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _busy || profile.isBlocked ? null : _message,
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: Text(l10n.messagesNewChat),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});
  final SocialProfile profile;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 46,
    backgroundColor: AppColors.primary,
    backgroundImage: profile.avatarUrl == null
        ? null
        : NetworkImage(profile.avatarUrl!),
    child: profile.avatarUrl == null
        ? Text(
            profile.name.isEmpty
                ? '?'
                : profile.name.characters.first.toUpperCase(),
            style: const TextStyle(fontSize: 32, color: Colors.white),
          )
        : null,
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: Theme.of(context).textTheme.titleLarge),
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
    ],
  );
}
