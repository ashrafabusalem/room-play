import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../data/truth_or_dare_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key, required this.room});
  final Room room;
  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  TruthOrDareSession? _session;
  Timer? _poll;
  bool _busy = false;
  bool _started = false;
  TruthOrDareRepository get _repo =>
      TruthOrDareRepository(AuthScope.of(context).api);
  bool get _amRoomHost => widget.room.seats.any(
    (s) => s.user?.isMe == true && s.user?.isHost == true,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
      _poll = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _load(silent: true),
      );
    }
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final value = await _repo.current(widget.room.id);
      if (mounted) setState(() => _session = value);
    } catch (_) {}
  }

  Future<void> _act(Future<TruthOrDareSession> Function() action) async {
    setState(() => _busy = true);
    try {
      final value = await action();
      if (mounted) setState(() => _session = value);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.truthDareTitle),
        actions: [
          if (s?.isHost == true && s?.status == 'active')
            IconButton(
              onPressed: _busy ? null : () => _act(() => _repo.finish(s!.id)),
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: l.truthDareEnd,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF421A55), AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: s == null
                  ? _empty(l)
                  : s.status == 'lobby'
                  ? _lobby(l, s)
                  : _active(l, s),
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('❓', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 18),
      Text(l.truthDareNoGame, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      if (_amRoomHost)
        FilledButton(
          onPressed: _busy
              ? null
              : () => _act(() => _repo.create(widget.room.id)),
          child: Text(l.truthDareCreate),
        )
      else
        Text(
          l.truthDareWaitHost,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
    ],
  );
  Widget _lobby(AppLocalizations l, TruthOrDareSession s) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('🎭', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 16),
      Text(
        l.truthDareLobbyTitle,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        l.truthDareLobbyBody,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 24),
      if (s.isHost)
        FilledButton(
          onPressed: _busy ? null : () => _act(() => _repo.start(s.id)),
          child: Text(l.truthDareStart),
        )
      else
        Text(
          l.truthDareWaitHost,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
    ],
  );
  Widget _active(AppLocalizations l, TruthOrDareSession s) {
    final current = s.currentPlayer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.truthDareTurn(s.turnNumber),
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        if (current != null) ...[
          AvatarCircle(user: current, size: 76, ringColor: AppColors.gold),
          const SizedBox(height: 10),
          Text(
            current.name,
            textDirection: directionOf(current.name),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
        const SizedBox(height: 22),
        if (s.promptText == null) ...[
          Text(
            s.isMyTurn ? l.truthDareYourChoice : l.truthDareWaitingChoice,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          if (s.isMyTurn)
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _act(() => _repo.choose(s.id, 'truth')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(l.truthDareTruth),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _act(() => _repo.choose(s.id, 'dare')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    child: Text(l.truthDareDare),
                  ),
                ),
              ],
            ),
        ] else ...[
          _PromptCard(type: s.promptType!, text: s.promptText!),
          const SizedBox(height: 20),
          if (s.isMyTurn || s.isHost)
            FilledButton.icon(
              onPressed: _busy ? null : () => _act(() => _repo.next(s.id)),
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(l.truthDareNext),
            ),
        ],
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: s.players
              .map(
                (p) => Chip(
                  avatar: AvatarCircle(user: p, size: 24),
                  label: Text(p.name),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.type, required this.text});
  final String type, text;
  @override
  Widget build(BuildContext context) {
    final truth = type == 'truth';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (truth ? AppColors.primary : AppColors.danger).withValues(
          alpha: .18,
        ),
        border: Border.all(color: truth ? AppColors.primary : AppColors.danger),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            truth
                ? Icons.psychology_alt_rounded
                : Icons.local_fire_department_rounded,
            color: truth ? AppColors.accent : AppColors.danger,
            size: 36,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            textDirection: directionOf(text),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
