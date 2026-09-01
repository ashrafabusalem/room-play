import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../data/spy_game_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

class SpyGameScreen extends StatefulWidget {
  const SpyGameScreen({super.key, required this.room});
  final Room room;
  @override
  State<SpyGameScreen> createState() => _SpyGameScreenState();
}

class _SpyGameScreenState extends State<SpyGameScreen> {
  SpyGameSession? _session;
  Timer? _poll;
  bool _busy = false, _loaded = false;
  SpyGameRepository get _repo => SpyGameRepository(AuthScope.of(context).api);
  bool get _amHost => widget.room.seats.any(
    (s) => s.user?.isMe == true && s.user?.isHost == true,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
      _poll = Timer.periodic(const Duration(seconds: 2), (_) => _load());
    }
  }

  Future<void> _load() async {
    try {
      final s = await _repo.current(widget.room.id);
      if (mounted) setState(() => _session = s);
    } catch (_) {}
  }

  Future<void> _act(Future<SpyGameSession> Function() action) async {
    setState(() => _busy = true);
    try {
      final s = await action();
      if (mounted) setState(() => _session = s);
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
    final l = AppLocalizations.of(context), s = _session;
    return Scaffold(
      appBar: AppBar(title: Text(l.spyTitle)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF25354D), AppColors.bg],
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
                  : _round(l, s),
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('🕵️', style: TextStyle(fontSize: 76)),
      Text(l.spyNoGame, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      if (_amHost)
        FilledButton(
          onPressed: _busy
              ? null
              : () => _act(() => _repo.create(widget.room.id)),
          child: Text(l.spyCreate),
        )
      else
        Text(l.spyWaitHost),
    ],
  );
  Widget _lobby(AppLocalizations l, SpyGameSession s) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('🕵️', style: TextStyle(fontSize: 76)),
      Text(l.spyLobbyTitle, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(l.spyLobbyBody, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      if (s.isHost)
        FilledButton(
          onPressed: _busy ? null : () => _act(() => _repo.start(s.id)),
          child: Text(l.spyStart),
        )
      else
        Text(l.spyWaitHost),
    ],
  );
  Widget _round(AppLocalizations l, SpyGameSession s) {
    final revealed = s.status == 'revealed';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          revealed ? '🎭' : (s.isSpy == true ? '🕵️' : '🔐'),
          style: const TextStyle(fontSize: 72),
        ),
        const SizedBox(height: 14),
        Text(
          revealed
              ? l.spyRevealed(s.spy?.name ?? '')
              : (s.isSpy == true ? l.spyYouAreSpy : l.spyYourWord),
          textAlign: TextAlign.center,
          textDirection: directionOf(
            revealed ? s.spy?.name ?? '' : s.word ?? '',
          ),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (s.word != null) ...[
          const SizedBox(height: 12),
          Text(
            s.word!,
            textDirection: directionOf(s.word!),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          revealed
              ? l.spyRoundFinished
              : (s.isSpy == true ? l.spyBlendIn : l.spyGiveClues),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: s.players
              .map(
                (p) => Chip(
                  avatar: AvatarCircle(user: p, size: 24),
                  label: Text(p.name, textDirection: directionOf(p.name)),
                ),
              )
              .toList(),
        ),
        if (s.isHost && !revealed) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : () => _act(() => _repo.reveal(s.id)),
            child: Text(l.spyReveal),
          ),
        ],
      ],
    );
  }
}
