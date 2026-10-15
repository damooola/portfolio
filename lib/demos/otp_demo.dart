import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Six OTP boxes done properly: type, paste, backspace, use the keypad.
/// Focus always sits on the next empty box, a wrong code shakes, and the
/// right one ticks green box by box.
///
/// Under the hood it's one hidden text field driving six boxes, so paste,
/// autofill and backspace behave like any normal input.
class OtpDemo extends StatefulWidget {
  const OtpDemo({super.key});

  static const length = 6;
  static const code = '482913';

  @override
  State<OtpDemo> createState() => _OtpDemoState();
}

enum _Check { typing, wrong, right }

class _OtpDemoState extends State<OtpDemo> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  _Check _check = _Check.typing;
  int _shakes = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _value => _controller.text;

  void _onChanged() {
    if (_check == _Check.right) return;
    setState(() => _check = _Check.typing);
    if (_value.length == OtpDemo.length) _verify();
  }

  Future<void> _verify() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    if (_value == OtpDemo.code) {
      setState(() => _check = _Check.right);
      Sfx.play(Sound.ding);
    } else {
      setState(() {
        _check = _Check.wrong;
        _shakes++;
      });
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted || _check != _Check.wrong) return;
      _controller.clear();
    }
  }

  void _key(String digit) {
    if (_check == _Check.right || _value.length >= OtpDemo.length) return;
    Sfx.play(Sound.click);
    _controller.text = _value + digit;
  }

  void _backspace() {
    if (_check == _Check.right || _value.isEmpty) return;
    Sfx.play(Sound.click);
    _controller.text = _value.substring(0, _value.length - 1);
  }

  Future<void> _pasteCode() async {
    Sfx.play(Sound.click);
    _reset();
    _controller.text = OtpDemo.code;
  }

  void _reset() {
    setState(() => _check = _Check.typing);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SmsBanner(onPaste: _pasteCode),
          const Spacer(),
          Text(
            'Verify your number',
            style: AppText.heading.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the 6-digit code we sent to +234 803 ••• 0042.',
            style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 22),
          _boxes(),
          const SizedBox(height: 14),
          SizedBox(height: 20, child: Center(child: _message())),
          const Spacer(),
          _Keypad(onDigit: _key, onBackspace: _backspace),
        ],
      ),
    );
  }

  Widget _boxes() {
    final row = Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var i = 0; i < OtpDemo.length; i++) _box(i)],
        ),
        // The real input: invisible, laid over the boxes so a tap focuses it.
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              showCursor: false,
              enableInteractiveSelection: true,
              maxLength: OtpDemo.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );

    if (_check == _Check.wrong) {
      return row
          .animate(key: ValueKey('shake-$_shakes'))
          .shakeX(hz: 6, amount: 7, duration: 450.ms);
    }
    return row;
  }

  Widget _box(int i) {
    final filled = i < _value.length;
    final active =
        _focus.hasFocus &&
        _check == _Check.typing &&
        i == _value.length.clamp(0, OtpDemo.length - 1);
    final color = switch (_check) {
      _Check.right => AppColors.online,
      _Check.wrong => const Color(0xFFFF5A5F),
      _Check.typing =>
        active
            ? AppColors.blue
            : (filled ? AppColors.textMuted : AppColors.line),
    };

    final box = AnimatedContainer(
      duration: AppMotion.hover,
      width: 40,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _check == _Check.right
            ? AppColors.online.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: active ? 2 : 1.2),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: filled
          ? Text(
                  _value[i],
                  style: AppText.mono.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                )
                .animate(key: ValueKey('d$i-${_value[i]}'))
                .scaleXY(
                  begin: 0.6,
                  end: 1,
                  duration: 160.ms,
                  curve: AppMotion.spring,
                )
          : null,
    );

    if (_check == _Check.right) {
      // Tick green one box at a time.
      return box
          .animate(key: ValueKey('right-$i'))
          .scaleXY(begin: 1, end: 1.08, delay: (60 * i).ms, duration: 120.ms)
          .then()
          .scaleXY(begin: 1.08, end: 1, duration: 160.ms);
    }
    return box;
  }

  Widget _message() {
    switch (_check) {
      case _Check.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.online),
            const SizedBox(width: 6),
            Text(
              'Verified',
              style: AppText.mono.copyWith(
                fontSize: 12,
                color: AppColors.online,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _reset,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'again',
                  style: AppText.mono.copyWith(
                    fontSize: 12,
                    color: AppColors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms);
      case _Check.wrong:
        return Text(
          "That code doesn't match",
          style: AppText.mono.copyWith(
            fontSize: 12,
            color: const Color(0xFFFF5A5F),
          ),
        );
      case _Check.typing:
        return Text(
          _focus.hasFocus
              ? 'Paste works too'
              : 'Tap the boxes or use the keypad',
          style: AppText.mono.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        );
    }
  }
}

/// Fake incoming SMS with the code, the way the OS shows it.
class _SmsBanner extends StatelessWidget {
  final VoidCallback onPaste;

  const _SmsBanner({required this.onPaste});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: AppColors.raised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MESSAGES · now',
                      style: AppText.monoLabel.copyWith(fontSize: 9),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Your code is '),
                          TextSpan(
                            text:
                                '${OtpDemo.code.substring(0, 3)} ${OtpDemo.code.substring(3)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: AppText.body.copyWith(
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onPaste,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  textStyle: AppText.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Paste'),
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: -1.2,
          end: 0,
          delay: 500.ms,
          duration: AppMotion.big,
          curve: AppMotion.spring,
        )
        .fadeIn(delay: 500.ms);
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _Keypad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback onTap, String label) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: SizedBox(height: 44, child: Center(child: child)),
            ),
          ),
        ),
      ),
    );
    Widget digit(String d) => key(
      Text(
        d,
        style: AppText.mono.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      () => onDigit(d),
      d,
    );

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            digit('0'),
            key(
              const Icon(
                Icons.backspace_outlined,
                size: 20,
                color: AppColors.text,
              ),
              onBackspace,
              'Backspace',
            ),
          ],
        ),
      ],
    );
  }
}
