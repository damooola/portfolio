import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Marketplace chat that keeps working on a bad connection, rebuilt from
/// scratch with a fake in-memory server.
///
/// Messages show up instantly as pending. Offline, they wait in a queue;
/// back online, the socket signs in first and then sends the queue in
/// order, ticking each one sent and read. "Flaky" makes the server drop the
/// first try of some messages, which you can tap to retry.
class ChatDemo extends StatefulWidget {
  const ChatDemo({super.key});

  @override
  State<ChatDemo> createState() => _ChatDemoState();
}

enum _Status { pending, sending, sent, read, failed }

class _Message {
  final int id;
  final bool mine;
  final String? text;

  /// Voice notes have a length instead of text.
  final Duration? voice;
  _Status status;
  int attempts = 0;

  _Message({
    required this.id,
    required this.mine,
    this.text,
    this.voice,
    this.status = _Status.sent,
  });
}

class _ChatDemoState extends State<ChatDemo> {
  static const _quick = [
    'Can you do 200 guests?',
    'What time can you set up?',
    'Sending the deposit now',
  ];
  static const _replies = [
    'Yes, 200 is fine. I\'ll bring extra centrepieces.',
    'We can be there from 10am.',
    'Received, thank you! You\'re all booked.',
    'Noted 👍',
  ];

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _random = math.Random(5);
  final _messages = <_Message>[
    _Message(
      id: 1,
      mine: false,
      text: 'Hi! Thanks for booking Bloom & Co. for Saturday.',
    ),
    _Message(
      id: 2,
      mine: true,
      text: 'Excited! Do you have the colour palette?',
      status: _Status.read,
    ),
    _Message(id: 3, mine: false, voice: const Duration(seconds: 9)),
  ];

  bool _online = true;
  bool _signedIn = true;
  bool _flaky = false;
  bool _typing = false;
  bool _flushing = false;
  int _nextId = 10;
  int _replyIndex = 0;
  int _replyRun = 0;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  int get _queued =>
      _messages.where((m) => m.mine && m.status == _Status.pending).length;

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: AppMotion.big,
          curve: AppMotion.settle,
        );
      }
    });
  }

  void _send({String? text, Duration? voice}) {
    if ((text == null || text.trim().isEmpty) && voice == null) return;
    Sfx.play(Sound.click);
    setState(() {
      _messages.add(
        _Message(
          id: _nextId++,
          mine: true,
          text: text?.trim(),
          voice: voice,
          status: _Status.pending,
        ),
      );
      _input.clear();
    });
    _scrollToEnd();
    if (_online && _signedIn) _flush();
  }

  Future<void> _toggleOnline() async {
    Sfx.play(Sound.click);
    setState(() {
      _online = !_online;
      _signedIn = false;
      _typing = false;
      // Anything mid-send when the line drops goes back in the queue.
      for (final m in _messages) {
        if (m.status == _Status.sending) m.status = _Status.pending;
      }
    });
    if (!_online) return;
    // The socket has to sign in again before anything is sent.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted || !_online) return;
    setState(() => _signedIn = true);
    _flush();
  }

  /// Sends queued messages one at a time, oldest first.
  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (mounted && _online && _signedIn) {
        final next = _messages
            .where((m) => m.mine && m.status == _Status.pending)
            .firstOrNull;
        if (next == null) break;
        await _deliver(next);
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> _deliver(_Message m) async {
    setState(() {
      m.status = _Status.sending;
      m.attempts++;
    });
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    if (!_online || !_signedIn) {
      setState(() => m.status = _Status.pending);
      return;
    }
    if (_flaky && m.attempts == 1 && _random.nextDouble() < 0.5) {
      setState(() => m.status = _Status.failed);
      return;
    }
    setState(() => m.status = _Status.sent);
    _vendorReads();
  }

  /// The vendor reads everything sent so far, types, then answers once.
  Future<void> _vendorReads() async {
    final run = ++_replyRun;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted || run != _replyRun || !_online) return;
    setState(() {
      for (final m in _messages) {
        if (m.mine && m.status == _Status.sent) m.status = _Status.read;
      }
      _typing = true;
    });
    _scrollToEnd();
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted || run != _replyRun) return;
    setState(() {
      _typing = false;
      if (_online) {
        _messages.add(
          _Message(
            id: _nextId++,
            mine: false,
            text: _replies[_replyIndex++ % _replies.length],
          ),
        );
      }
    });
    if (_online) Sfx.play(Sound.ding);
    _scrollToEnd();
  }

  void _retry(_Message m) {
    Sfx.play(Sound.click);
    setState(() => m.status = _Status.pending);
    if (_online && _signedIn) _flush();
  }

  @override
  Widget build(BuildContext context) {
    final status = !_online
        ? 'offline'
        : !_signedIn
        ? 'reconnecting…'
        : _typing
        ? 'typing…'
        : 'online';

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 10, 8),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.blueDeep,
                child: Icon(
                  Icons.local_florist_outlined,
                  size: 17,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bloom & Co.',
                      style: AppText.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppMotion.hover,
                      child: Text(
                        status,
                        key: ValueKey(status),
                        style: AppText.mono.copyWith(
                          fontSize: 10,
                          color: _online && _signedIn
                              ? AppColors.online
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Toggle(
                icon: _flaky
                    ? Icons.signal_cellular_connected_no_internet_4_bar
                    : Icons.signal_cellular_alt,
                label: 'Flaky',
                active: _flaky,
                tooltip: 'Flaky server: drops some first tries',
                onTap: () {
                  Sfx.play(Sound.click);
                  setState(() => _flaky = !_flaky);
                },
              ),
              const SizedBox(width: 6),
              _Toggle(
                icon: _online ? Icons.wifi : Icons.wifi_off,
                label: _online ? 'On' : 'Off',
                active: !_online,
                tooltip: _online ? 'Go offline' : 'Go back online',
                onTap: _toggleOnline,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.hover,
          child: !_online || !_signedIn
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  child: Text(
                    !_online
                        ? 'Offline · $_queued queued, they\'ll send when you\'re back'
                        : 'Signing in, then sending $_queued queued…',
                    style: AppText.mono.copyWith(
                      fontSize: 10,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Container(height: 1, color: AppColors.line),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            children: [
              for (final m in _messages)
                _Bubble(
                      key: ValueKey(m.id),
                      message: m,
                      onRetry: () => _retry(m),
                    )
                    .animate(key: ValueKey('in-${m.id}'))
                    .fadeIn(duration: 200.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: AppMotion.big,
                      curve: AppMotion.settle,
                    ),
              if (_typing) const _TypingBubble(),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final q in _quick)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(q),
                    onPressed: () => _send(text: q),
                    labelStyle: AppText.body.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.line),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    shape: const StadiumBorder(),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  onSubmitted: (t) => _send(text: t),
                  style: AppText.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: AppText.bodyMuted.copyWith(fontSize: 13),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: AppColors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _RoundIcon(
                icon: Icons.mic_rounded,
                tooltip: 'Send a voice note',
                onTap: () =>
                    _send(voice: Duration(seconds: 4 + _random.nextInt(9))),
              ),
              const SizedBox(width: 6),
              _RoundIcon(
                icon: Icons.send_rounded,
                tooltip: 'Send',
                primary: true,
                onTap: () => _send(text: _input.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _Toggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const warn = Color(0xFFF59E0B);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        toggled: active,
        label: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: AppMotion.hover,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? warn.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? warn : AppColors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: active ? warn : AppColors.text),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppText.mono.copyWith(
                      fontSize: 10,
                      color: active ? warn : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool primary;
  final VoidCallback onTap;

  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: primary ? AppColors.blue : AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  final VoidCallback onRetry;

  const _Bubble({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final m = message;
    final failed = m.status == _Status.failed;
    final content = m.voice != null
        ? _VoiceNote(length: m.voice!, mine: m.mine)
        : Text(
            m.text ?? '',
            style: AppText.body.copyWith(
              fontSize: 13,
              height: 1.35,
              color: AppColors.text,
            ),
          );

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 6),
      decoration: BoxDecoration(
        color: m.mine ? AppColors.blueDeep : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(m.mine ? 14 : 4),
          bottomRight: Radius.circular(m.mine ? 4 : 14),
        ),
        border: Border.all(
          color: failed
              ? const Color(0xFFFF5A5F)
              : (m.mine ? Colors.transparent : AppColors.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          if (m.mine) ...[const SizedBox(height: 3), _Ticks(status: m.status)],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: m.mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (failed)
            Tooltip(
              message: 'Not sent. Tap to retry',
              child: GestureDetector(
                onTap: onRetry,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.error_outline,
                      size: 18,
                      color: Color(0xFFFF5A5F),
                    ),
                  ),
                ),
              ),
            ).animate().shakeX(hz: 5, amount: 3, duration: 350.ms),
          Flexible(
            child: failed
                ? GestureDetector(onTap: onRetry, child: bubble)
                : bubble,
          ),
        ],
      ),
    );
  }
}

class _Ticks extends StatelessWidget {
  final _Status status;

  const _Ticks({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      _Status.pending => (Icons.schedule, AppColors.textMuted, 'queued'),
      _Status.sending => (Icons.check, AppColors.textMuted, 'sending'),
      _Status.sent => (Icons.done_all, AppColors.textMuted, 'sent'),
      _Status.read => (Icons.done_all, const Color(0xFF7DB4FF), 'read'),
      _Status.failed => (
        Icons.error_outline,
        const Color(0xFFFF5A5F),
        'tap to retry',
      ),
    };
    return AnimatedSwitcher(
      duration: AppMotion.hover,
      child: Row(
        key: ValueKey(status),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppText.mono.copyWith(fontSize: 8.5, color: color),
          ),
          const SizedBox(width: 3),
          Icon(icon, size: 12, color: color),
        ],
      ),
    );
  }
}

/// A voice note with a fixed fake waveform. Tap play to watch it progress.
class _VoiceNote extends StatefulWidget {
  final Duration length;
  final bool mine;

  const _VoiceNote({required this.length, required this.mine});

  @override
  State<_VoiceNote> createState() => _VoiceNoteState();
}

class _VoiceNoteState extends State<_VoiceNote>
    with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(
    vsync: this,
    duration: widget.length,
  );
  late final _bars = List.generate(
    22,
    (i) =>
        0.25 + 0.75 * ((math.sin(i * 1.7 + widget.length.inSeconds) + 1) / 2),
  );

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _toggle() {
    Sfx.play(Sound.click);
    if (_progress.isAnimating) {
      _progress.stop();
    } else {
      if (_progress.isCompleted) _progress.value = 0;
      _progress.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final left = widget.length * (1 - _progress.value);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggle,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  _progress.isAnimating
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 28,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < _bars.length; i++)
                  Container(
                    width: 2.5,
                    height: 20 * _bars[i],
                    margin: const EdgeInsets.only(right: 1.5),
                    decoration: BoxDecoration(
                      color: i / _bars.length <= _progress.value
                          ? AppColors.online
                          : AppColors.text.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
            Text(
              '0:${left.inSeconds.toString().padLeft(2, '0')}',
              style: AppText.mono.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: 0,
                    end: -3,
                    delay: (120 * i).ms,
                    duration: 300.ms,
                  ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }
}
