import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/direct_message_repository.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../profile/public_profile_screen.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversation});
  final Conversation conversation;
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _text = TextEditingController();
  List<ChatMessage> _messages = [];
  DirectMessageRepository? _repo;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repo != null) return;
    final a = AuthScope.of(context);
    _repo = DirectMessageRepository(a.api, currentUserId: a.publicId);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final m = await _repo!.messages(widget.conversation.id);
      if (mounted) setState(() => _messages = m);
    } catch (_) {}
  }

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    try {
      final m = await _repo!.send(widget.conversation.id, t);
      if (mounted) setState(() => _messages = [..._messages, m]);
    } catch (_) {
      if (mounted) _text.text = t;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: InkWell(
        onTap: widget.conversation.userId == null
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PublicProfileScreen(userId: widget.conversation.userId!),
                ),
              ),
        child: Text(widget.conversation.name),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (c, i) {
                final m = _messages[_messages.length - 1 - i];
                final me = m.sender?.isMe ?? false;
                return Align(
                  alignment: me
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: me ? AppColors.primary : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).roomChatHint,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
