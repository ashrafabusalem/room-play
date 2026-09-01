import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../data/social_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

/// Profile tab.
///
/// NOTE: not part of the delivered mockup. Built to the established style so
/// the nav is complete — treat the layout as a proposal, not a spec.
///
/// It is also where the language picker lives for now; it belongs in a proper
/// Settings screen once one is designed.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SocialProfile? _profile;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null && !_loading) _load();
  }

  Future<void> _load() async {
    final auth = AuthScope.of(context);
    if (auth.publicId == null) return;
    setState(() => _loading = true);
    try {
      final profile = await SocialRepository(auth.api).profile(auth.publicId!);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // Keep showing the locally cached account details while offline.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final l10n = AppLocalizations.of(context);
    final auth = AuthScope.of(context);
    final profile = _profile;
    if (profile == null) return;
    final name = TextEditingController(text: profile.name);
    final bio = TextEditingController(text: profile.bio ?? '');
    var privacy = profile.dmPrivacy;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.profileEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  maxLength: 80,
                  decoration: InputDecoration(labelText: l10n.authUsername),
                ),
                TextField(
                  controller: bio,
                  maxLength: 240,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.profileBio,
                    hintText: l10n.profileBioHint,
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: privacy,
                  decoration: InputDecoration(
                    labelText: l10n.profileMessagePrivacy,
                  ),
                  items:
                      [
                            ('everyone', l10n.profilePrivacyEveryone),
                            ('followers', l10n.profilePrivacyFollowers),
                            ('nobody', l10n.profilePrivacyNobody),
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.$1,
                              child: Text(item.$2),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setDialogState(() => privacy = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().length < 2) return;
                final user = await SocialRepository(auth.api).updateProfile(
                  name: name.text.trim(),
                  bio: bio.text.trim(),
                  dmPrivacy: privacy,
                );
                await auth.applyProfileUpdate(user);
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.profileSave),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    bio.dispose();
    if (saved == true && mounted) await _load();
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (image == null || !mounted) return;
    final auth = AuthScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final successMessage = AppLocalizations.of(context).profilePhotoUpdated;
    setState(() => _loading = true);
    try {
      final user = await SocialRepository(auth.api)
          .updateAvatar(await image.readAsBytes(), image.name);
      await auth.applyProfileUpdate(user);
      if (mounted) {
        await _load();
        messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = AuthScope.of(context);

    // Real account details now. Everything else on this screen — coins, the
    // follower counts — is still mock and stays that way until Phase 4.
    final displayName = auth.name?.trim().isNotEmpty == true
        ? auth.name!.trim()
        : l10n.navProfile;
    final me = AppUser(
      id: auth.publicId ?? 'u_me',
      name: displayName,
      level: auth.level,
      isMe: true,
      avatarUrl: _profile?.avatarUrl,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
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
                  l10n.profileTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.settings_rounded,
                  background: Colors.transparent,
                  size: 36,
                  iconSize: 22,
                  onTap: _edit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _loading ? null : _pickAvatar,
                      child: AvatarCircle(
                        user: me,
                        size: 88,
                        ringColor: AppColors.primary,
                      ),
                    ),
                    PositionedDirectional(
                      end: -2,
                      bottom: -2,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: l10n.profileChangePhoto,
                          onPressed: _loading ? null : _pickAvatar,
                          icon: const Icon(Icons.camera_alt_rounded, size: 17),
                          color: Colors.white,
                          constraints: const BoxConstraints.tightFor(
                            width: 34,
                            height: 34,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  textDirection: directionOf(displayName),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (auth.publicId != null) ...[
                  const SizedBox(height: 6),
                  CountPill(
                    label: l10n.roomIdLabel(auth.publicId!),
                    icon: Icons.badge_rounded,
                  ),
                ],
                if (_profile?.bio?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _profile!.bio!,
                      textAlign: TextAlign.center,
                      textDirection: directionOf(_profile!.bio!),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _StatsRow(
            following: _profile?.following ?? 0,
            followers: _profile?.followers ?? 0,
          ),
          const SizedBox(height: 20),
          const _CoinCard(),
          const SizedBox(height: 20),
          _MenuGroup(
            items: [
              (
                Icons.language_rounded,
                l10n.profileLanguage,
                _currentLanguageLabel(context, l10n),
                () => _openLanguagePicker(context),
              ),
              (
                Icons.account_balance_wallet_rounded,
                l10n.profileWallet,
                null,
                null,
              ),
              (Icons.backpack_rounded, l10n.profileBackpack, null, null),
              (
                Icons.emoji_events_rounded,
                l10n.profileAchievements,
                null,
                null,
              ),
              (Icons.group_rounded, l10n.profileFriends, null, null),
              (Icons.help_outline_rounded, l10n.profileHelp, null, null),
              (
                Icons.logout_rounded,
                l10n.authSignOut,
                null,
                () => AuthScope.of(context).signOut(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
            child: Text(
              l10n.profileNotDesignedNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _currentLanguageLabel(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final controller = LocaleScope.of(context);
    if (controller.followsSystem) return l10n.languageSystemDefault;
    return languageNameFor(controller.locale!);
  }

  static void _openLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguagePickerSheet(),
    );
  }
}

/// Lists every locale that has an ARB file, plus "follow the system".
///
/// Nothing here is hardcoded per language — add an ARB file, run
/// `flutter gen-l10n`, and the new language appears in this list on its own.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = LocaleScope.of(context);

    // Material, not a decorated Container: the rows are ListTiles and paint
    // their ink on the nearest Material ancestor.
    return Material(
      color: AppColors.bgElevated,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.languagePickerTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _LanguageTile(
              label: l10n.languageSystemDefault,
              selected: controller.followsSystem,
              onTap: () {
                controller.setLocale(null);
                Navigator.of(context).pop();
              },
            ),
            for (final locale in LocaleController.supported)
              _LanguageTile(
                // Each language names itself, so it stays readable to the person
                // looking for it even when the UI is in a language they cannot
                // read.
                label: languageNameFor(locale),
                selected:
                    !controller.followsSystem &&
                    controller.locale!.languageCode == locale.languageCode,
                onTap: () {
                  controller.setLocale(locale);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontFamilyFallback: kFontFallback,
          fontSize: 15,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.accent, size: 20)
          : null,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.following, required this.followers});
  final int following;
  final int followers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = [
      ('$following', l10n.profileFollowing),
      ('$followers', l10n.profileFollowers),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (value, label) in stats)
          Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: kFontFallback,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _CoinCard extends StatelessWidget {
  const _CoinCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1E52), Color(0xFF3B2A78)],
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.gold,
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2,480',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: kFontFallback,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  l10n.profileCoinBalance,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: const Color(0xFF2A1E52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.profileTopUp),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  /// (icon, label, trailing value, tap handler)
  final List<(IconData, String, String?, VoidCallback?)> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
      // Material, not a plain Container: ListTile paints its ink splash on the
      // nearest Material ancestor, so a DecoratedBox would swallow it.
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, indent: 52, color: AppColors.divider),
              ListTile(
                leading: Icon(
                  items[i].$1,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  items[i].$2,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: kFontFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (items[i].$3 != null)
                      Text(
                        items[i].$3!,
                        style: const TextStyle(
                          fontFamily: kFontFamily,
                          fontFamilyFallback: kFontFallback,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(width: 4),
                    // Icons do not mirror themselves; a "forward" chevron has
                    // to point the other way in RTL.
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                onTap: items[i].$4 ?? () {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}
