import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const _repo = MockRepository();

  @override
  Widget build(BuildContext context) {
    final conversations = _repo.conversations();

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
                const CircleIconButton(
                  icon: Icons.add_rounded,
                  background: Colors.transparent,
                  size: 36,
                  iconSize: 26,
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
              itemBuilder: (context, i) =>
                  _ConversationRow(conversation: conversations[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final user = AppUser(id: c.id, name: c.name);

    return InkWell(
      onTap: () {},
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
