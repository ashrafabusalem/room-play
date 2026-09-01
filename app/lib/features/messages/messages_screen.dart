import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../data/direct_message_repository.dart';
import '../auth/auth_controller.dart';
import 'conversation_screen.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const _repo = MockRepository();
  List<Conversation> _items = _repo.conversations();
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    unawaited(_load());
  }

  Future<void> _load() async {
    final a = AuthScope.of(context);
    try {
      final v = await DirectMessageRepository(
        a.api,
        currentUserId: a.publicId,
      ).conversations();
      if (mounted) setState(() => _items = v);
    } catch (_) {}
  }

  Future<void> _newChat() async {
    final a = AuthScope.of(context);
    final repo = DirectMessageRepository(a.api, currentUserId: a.publicId);
    final controller = TextEditingController();
    List<AppUser> users = [];
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(AppLocalizations.of(context).messagesNewChat),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).actionSearch,
                  ),
                  onChanged: (q) async {
                    if (q.trim().length < 2) return;
                    final r = await repo.search(q.trim());
                    if (context.mounted) setDialog(() => users = r);
                  },
                ),
                const SizedBox(height: 8),
                ...users.map(
                  (u) => ListTile(
                    title: Text(u.name),
                    subtitle: Text(u.id),
                    onTap: () async {
                      final c = await repo.start(u.id);
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ConversationScreen(conversation: c),
                        ),
                      );
                      await _load();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _items;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.gutter,
              12,
              AppSizes.gutter,
              0,
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).messagesTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.add_rounded,
                  background: Colors.transparent,
                  size: 36,
                  iconSize: 26,
                  onTap: _newChat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).actionSearch,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: conversations.length,
              itemBuilder: (context, i) => _ConversationRow(
                conversation: conversations[i],
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ConversationScreen(conversation: conversations[i]),
                    ),
                  );
                  await _load();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final user = AppUser(
      id: c.userId ?? c.id,
      name: c.name,
      avatarUrl: c.avatarUrl,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.gutter,
          vertical: 10,
        ),
        child: Row(
          children: [
            AvatarCircle(user: user, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.name,
                          textDirection: directionOf(c.name),
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
                      ),
                      if (c.verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (c.isVoiceNote) ...[
                        const Icon(
                          Icons.mic_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          // A voice note has no text to show, so the label is
                          // app chrome and gets translated. Real message text
                          // is user content and is shown as-is.
                          c.isVoiceNote
                              ? AppLocalizations.of(context).messagesVoiceNote
                              : c.preview,
                          // The label follows the UI language; a real preview
                          // follows whatever language it was written in.
                          textDirection: c.isVoiceNote
                              ? null
                              : directionOf(c.preview),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: kFontFamily,
                            fontFamilyFallback: kFontFallback,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c.time,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: kFontFallback,
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                if (c.unread > 0)
                  UnreadBadge(count: c.unread, color: AppColors.accent)
                else if (c.dot)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
