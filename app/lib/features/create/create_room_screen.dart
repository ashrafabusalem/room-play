import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/room_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/widgets/auth_field.dart';
import '../rooms/room_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _language = 'EN';
  String _tag = 'chatting';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = AuthScope.of(context);
    try {
      final room = await RoomRepository(
        auth.api,
        currentUserId: auth.publicId,
      ).create(name: _name.text.trim(), language: _language, tag: _tag);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => RoomScreen(room: room)),
      );
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error.errorFor('name') ??
              error.serverMessage ??
              AppLocalizations.of(context).errorUnexpected,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).errorUnexpected);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topics = <String, String>{
      'chatting': l10n.createRoomTopicChatting,
      'gaming': l10n.createRoomTopicGaming,
      'music': l10n.createRoomTopicMusic,
      'party': l10n.createRoomTopicParty,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createRoomTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.gutter),
            children: [
              AuthField(
                label: l10n.createRoomName,
                controller: _name,
                icon: Icons.mic_rounded,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return l10n.createRoomNameRequired;
                  if (name.length < 2) return l10n.createRoomNameShort;
                  return null;
                },
              ),
              const SizedBox(height: 22),
              _Label(l10n.createRoomLanguage),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'EN', label: Text('English')),
                  ButtonSegment(value: 'AR', label: Text('العربية')),
                ],
                selected: {_language},
                onSelectionChanged: (value) =>
                    setState(() => _language = value.first),
              ),
              const SizedBox(height: 22),
              _Label(l10n.createRoomTopic),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.entries
                    .map(
                      (entry) => ChoiceChip(
                        label: Text(entry.value),
                        selected: _tag == entry.key,
                        onSelected: (_) => setState(() => _tag = entry.key),
                      ),
                    )
                    .toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.createRoomSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: kFontFamily,
      fontFamilyFallback: kFontFallback,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}
