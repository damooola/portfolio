import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Loan-rejection recovery, rebuilt from scratch on mock data.
///
/// A declined application comes back with several reasons from the credit
/// decision. Each reason is its own small fix-it flow; fixed ones collapse
/// into "resolved", and the application can go back for review once
/// everything is fixed.
class LoanFixDemo extends StatefulWidget {
  const LoanFixDemo({super.key});

  @override
  State<LoanFixDemo> createState() => _LoanFixDemoState();
}

enum _Reason { contact, collateral, affordability }

extension on _Reason {
  String get title => switch (this) {
    _Reason.contact => 'Guarantor unreachable',
    _Reason.collateral => 'Collateral too low',
    _Reason.affordability => 'Repayment too high',
  };

  String get hint => switch (this) {
    _Reason.contact => 'Verify your guarantor\'s phone with a code.',
    _Reason.collateral => 'Add collateral worth at least ₦300,000.',
    _Reason.affordability => 'Monthly repayment must be under 40% of income.',
  };

  IconData get icon => switch (this) {
    _Reason.contact => Icons.phone_in_talk_outlined,
    _Reason.collateral => Icons.account_balance_outlined,
    _Reason.affordability => Icons.tune,
  };
}

class _LoanFixDemoState extends State<LoanFixDemo> {
  static const _income = 250000;
  static const _months = 6;
  static const _code = '2468';

  final _resolved = <_Reason>{};
  _Reason? _open = _Reason.contact;
  bool _submitted = false;
  bool _submitting = false;

  // Per-flow state.
  bool _codeSent = false;
  String _entered = '';
  bool _wrongCode = false;
  String? _collateralType;
  double _collateralValue = 150000;
  double _amount = 900000;

  String _naira(num v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '₦$b';
  }

  int get _monthly => (_amount * 1.18 / _months).round();
  bool get _affordable => _monthly <= _income * 0.4;

  void _resolve(_Reason r) {
    Sfx.play(Sound.stamp);
    setState(() {
      _resolved.add(r);
      _open = _Reason.values.where((x) => !_resolved.contains(x)).firstOrNull;
    });
  }

  void _toggle(_Reason r) {
    if (_resolved.contains(r)) return;
    Sfx.play(Sound.click);
    setState(() => _open = _open == r ? null : r);
  }

  Future<void> _resubmit() async {
    Sfx.play(Sound.click);
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
    Sfx.play(Sound.ding);
  }

  void _restart() {
    Sfx.play(Sound.click);
    setState(() {
      _resolved.clear();
      _open = _Reason.contact;
      _submitted = false;
      _codeSent = false;
      _entered = '';
      _wrongCode = false;
      _collateralType = null;
      _collateralValue = 150000;
      _amount = 900000;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _done();
    final remaining = _Reason.values
        .where((r) => !_resolved.contains(r))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        Text(
          'Loan application',
          style: AppText.monoLabel.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 2),
        Text(
          remaining.isEmpty
              ? 'All fixed. Ready to resubmit'
              : 'Declined: ${remaining.length} things to fix',
          style: AppText.heading.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          '₦900,000 over $_months months · decision #A-2041',
          style: AppText.mono.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _resolved.length / _Reason.values.length),
            duration: AppMotion.big,
            curve: AppMotion.settle,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 5,
              backgroundColor: AppColors.raised,
              color: AppColors.online,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final r in _Reason.values)
          if (!_resolved.contains(r)) _card(r),
        if (_resolved.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'RESOLVED',
            style: AppText.monoLabel.copyWith(
              fontSize: 9,
              color: AppColors.online,
            ),
          ),
          const SizedBox(height: 6),
          for (final r in _Reason.values)
            if (_resolved.contains(r))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.online,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.title,
                        style: AppText.body.copyWith(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.1, end: 0),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: remaining.isEmpty && !_submitting ? _resubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blue,
            disabledBackgroundColor: AppColors.raised,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  remaining.isEmpty
                      ? 'Resubmit application'
                      : 'Fix ${remaining.length} more to resubmit',
                ),
        ),
      ],
    );
  }

  Widget _card(_Reason r) {
    final open = _open == r;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: AppMotion.hover,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: open ? AppColors.blue : AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggle(r),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(r.icon, size: 18, color: const Color(0xFFFF8A8E)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: AppText.body.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          Text(
                            r.hint,
                            style: AppText.bodyMuted.copyWith(
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: AppMotion.hover,
                      child: const Icon(
                        Icons.expand_more,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: AppMotion.big,
              curve: AppMotion.settle,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: switch (r) {
                        _Reason.contact => _contactFix(),
                        _Reason.collateral => _collateralFix(),
                        _Reason.affordability => _amountFix(),
                      },
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactFix() {
    if (!_codeSent) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Kemi A. · +234 803 ••• 0099',
              style: AppText.mono.copyWith(fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () {
              Sfx.play(Sound.click);
              setState(() => _codeSent = true);
            },
            child: const Text('Send code'),
          ),
        ],
      );
    }
    Widget key(String d) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: AppColors.raised,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Sfx.play(Sound.click);
              setState(() {
                _wrongCode = false;
                if (d == '⌫') {
                  if (_entered.isNotEmpty) {
                    _entered = _entered.substring(0, _entered.length - 1);
                  }
                } else if (_entered.length < 4) {
                  _entered += d;
                }
              });
              if (_entered.length == 4) {
                if (_entered == _code) {
                  _resolve(_Reason.contact);
                } else {
                  setState(() {
                    _wrongCode = true;
                    _entered = '';
                  });
                }
              }
            },
            child: SizedBox(
              height: 30,
              child: Center(
                child: Text(d, style: AppText.mono.copyWith(fontSize: 14)),
              ),
            ),
          ),
        ),
      ),
    );
    final boxes = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 34,
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.night,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _wrongCode
                    ? const Color(0xFFFF5A5F)
                    : (i == _entered.length ? AppColors.blue : AppColors.line),
              ),
            ),
            child: Text(
              i < _entered.length ? _entered[i] : '',
              style: AppText.mono.copyWith(fontSize: 16),
            ),
          ),
      ],
    );
    return Column(
      children: [
        Text(
          _wrongCode ? 'Wrong code, try again' : 'Kemi got an SMS: code $_code',
          style: AppText.mono.copyWith(
            fontSize: 10,
            color: _wrongCode ? const Color(0xFFFF5A5F) : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        _wrongCode
            ? boxes
                  .animate(key: ValueKey(_wrongCode))
                  .shakeX(hz: 6, amount: 5, duration: 400.ms)
            : boxes,
        const SizedBox(height: 6),
        for (final row in const [
          ['1', '2', '3', '4', '5'],
          ['6', '7', '8', '9', '0'],
        ])
          Row(children: [for (final d in row) key(d)]),
        Row(children: [const Spacer(flex: 4), key('⌫')]),
      ],
    );
  }

  Widget _collateralFix() {
    const types = ['Vehicle', 'Land', 'Cash'];
    final enough = _collateralType != null && _collateralValue >= 300000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          children: [
            for (final t in types)
              ChoiceChip(
                label: Text(t),
                selected: _collateralType == t,
                onSelected: (_) {
                  Sfx.play(Sound.click);
                  setState(() => _collateralType = t);
                },
                labelStyle: AppText.body.copyWith(fontSize: 11),
                visualDensity: VisualDensity.compact,
                selectedColor: AppColors.blue,
                backgroundColor: AppColors.raised,
                side: const BorderSide(color: AppColors.line),
                showCheckmark: false,
              ),
          ],
        ),
        Row(
          children: [
            Text('Value', style: AppText.monoLabel.copyWith(fontSize: 9)),
            Expanded(
              child: Slider(
                value: _collateralValue,
                min: 50000,
                max: 600000,
                divisions: 22,
                onChanged: (v) => setState(() => _collateralValue = v),
                activeColor: enough ? AppColors.online : AppColors.blue,
              ),
            ),
            Text(
              _naira(_collateralValue),
              style: AppText.mono.copyWith(fontSize: 11),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: enough ? () => _resolve(_Reason.collateral) : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              _collateralType == null
                  ? 'Pick a type'
                  : (enough ? 'Add collateral' : 'Need ₦300,000+'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountFix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Amount', style: AppText.monoLabel.copyWith(fontSize: 9)),
            Expanded(
              child: Slider(
                value: _amount,
                min: 200000,
                max: 900000,
                divisions: 14,
                onChanged: (v) => setState(() => _amount = v),
                activeColor: _affordable
                    ? AppColors.online
                    : const Color(0xFFFF8A8E),
              ),
            ),
            Text(_naira(_amount), style: AppText.mono.copyWith(fontSize: 11)),
          ],
        ),
        Text(
          'Monthly ${_naira(_monthly)} · limit ${_naira(_income * 0.4)}',
          style: AppText.mono.copyWith(
            fontSize: 10,
            color: _affordable ? AppColors.online : const Color(0xFFFF8A8E),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _affordable
                ? () => _resolve(_Reason.affordability)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(_affordable ? 'Use this amount' : 'Lower the amount'),
          ),
        ),
      ],
    );
  }

  Widget _done() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.online.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 40,
              color: AppColors.online,
            ),
          ).animate().scaleXY(
            begin: 0.4,
            end: 1,
            duration: AppMotion.big,
            curve: AppMotion.spring,
          ),
          const SizedBox(height: 16),
          Text('Back in review', style: AppText.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            'All three reasons fixed. The application goes back to the credit team with the new details.',
            textAlign: TextAlign.center,
            style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: _restart, child: const Text('Start over')),
        ],
      ),
    );
  }
}
