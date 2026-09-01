import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../data/social_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

class PrivacySafetyScreen extends StatefulWidget {
  const PrivacySafetyScreen({super.key, required this.messagePrivacy});

  final String messagePrivacy;

  @override
  State<PrivacySafetyScreen> createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState extends State<PrivacySafetyScreen> {
  late String _privacy = widget.messagePrivacy;
  List<AppUser>? _blocked;
  bool _saving = false;

  SocialRepository get _repository =>
      SocialRepository(AuthScope.of(context).api);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_blocked == null) _loadBlocked();
  }

  Future<void> _loadBlocked() async {
    try {
      final users = await _repository.blockedUsers();
      if (mounted) setState(() => _blocked = users);
    } catch (_) {
      if (mounted) setState(() => _blocked = []);
    }
  }

  Future<void> _setPrivacy(String value) async {
    final previous = _privacy;
    setState(() {
      _privacy = value;
      _saving = true;
    });
    try {
      await _repository.updateMessagePrivacy(value);
    } catch (_) {
      if (mounted) setState(() => _privacy = previous);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _unblock(AppUser user) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyUnblockTitle(user.name)),
        content: Text(l10n.privacyUnblockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileUnblock),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.block(user.id, false);
    await _loadBlocked();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacySafetyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.profileMessagePrivacy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.privacyMessagesDescription,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _privacy,
            decoration: InputDecoration(
              suffixIcon: _saving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            items: [
              DropdownMenuItem(
                value: 'everyone',
                child: Text(l10n.profilePrivacyEveryone),
              ),
              DropdownMenuItem(
                value: 'followers',
                child: Text(l10n.profilePrivacyFollowers),
              ),
              DropdownMenuItem(
                value: 'nobody',
                child: Text(l10n.profilePrivacyNobody),
              ),
            ],
            onChanged: _saving ? null : (value) => _setPrivacy(value!),
          ),
          const SizedBox(height: 30),
          Text(
            l10n.privacyBlockedAccounts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.privacyBlockedDescription,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (_blocked == null)
            const Center(child: CircularProgressIndicator())
          else if (_blocked!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.privacyNoBlockedAccounts,
                textAlign: TextAlign.center,
              ),
            )
          else
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final user in _blocked!)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        backgroundImage: user.avatarUrl == null
                            ? null
                            : NetworkImage(user.avatarUrl!),
                        child: user.avatarUrl == null
                            ? Text(user.initials)
                            : null,
                      ),
                      title: Text(
                        user.name,
                        textDirection: directionOf(user.name),
                      ),
                      trailing: TextButton(
                        onPressed: () => _unblock(user),
                        child: Text(l10n.profileUnblock),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
