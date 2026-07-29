import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with WidgetsBindingObserver {
  static const int _defaultMinutes = 25;

  late int _totalSeconds;
  late int _remainingSeconds;

  Timer? _timer;
  bool _running = false;
  bool _completed = false;
  int _selectedMinutes = _defaultMinutes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyMinutes(_defaultMinutes, resetProgress: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pause();
    }
  }

  void _applyMinutes(int minutes, {bool resetProgress = false}) {
    final safeMinutes = minutes.clamp(1, 180);
    setState(() {
      _selectedMinutes = safeMinutes;
      _totalSeconds = safeMinutes * 60;
      if (resetProgress) {
        _remainingSeconds = _totalSeconds;
        _completed = false;
      } else {
        _remainingSeconds = _remainingSeconds.clamp(0, _totalSeconds);
      }
      _running = false;
    });
  }

  void _start() {
    if (_running) return;

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _totalSeconds;
      _completed = false;
    }

    setState(() => _running = true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _running = false;
          _completed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('انتهت جلسة التركيز'),
            action: SnackBarAction(
              label: 'إعادة',
              onPressed: _reset,
            ),
          ),
        );
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _pause() {
    if (!_running) return;
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _toggle() {
    if (_running) {
      _pause();
    } else {
      _start();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _completed = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  String get _label {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    if (_totalSeconds <= 0) return 0.0;
    final value = 1 - (_remainingSeconds / _totalSeconds);
    return value.clamp(0.0, 1.0);
  }

  String get _subtitle {
    if (_completed) return 'اكتملت الجلسة بنجاح';
    if (_running) return 'أنت في وضع التركيز الآن';
    if (_remainingSeconds == _totalSeconds) return 'اضغط ابدأ لبدء جلسة جديدة';
    return 'الجلسة متوقفة مؤقتًا';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primary;

    return AppScaffold(
      title: 'مؤقت التركيز',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderCard(
            title: _running
                ? 'حان وقت التركيز'
                : _completed
                    ? 'أحسنت!'
                    : 'جلسة تركيز',
            subtitle: _subtitle,
            minutes: _selectedMinutes,
            progress: _progress,
          ),
          const SizedBox(height: 14),
          _PresetRow(
            selectedMinutes: _selectedMinutes,
            onSelected: (minutes) {
              _applyMinutes(minutes, resetProgress: true);
            },
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 118,
                    lineWidth: 14,
                    percent: _progress,
                    animation: true,
                    animationDuration: 300,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: theme.dividerColor.withOpacity(0.12),
                    progressColor: primary,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _label,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w200,
                            color: primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'دقيقة : ثانية',
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    backgroundColor: theme.dividerColor.withOpacity(0.12),
                    color: primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المنجز: ${(_progress * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'المتبقي: ${_remainingSeconds ~/ 60} دقيقة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('إعادة ضبط'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _toggle,
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(
                            _running
                                ? Icons.pause_rounded
                                : _completed
                                    ? Icons.refresh_rounded
                                    : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            _running
                                ? 'إيقاف مؤقت'
                                : _completed
                                    ? 'ابدأ مرة أخرى'
                                    : 'بدء التركيز',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جلسات اليوم',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accentGreen,
                  ),
                  title: const Text('جلسة 1'),
                  subtitle: const Text('جلسة مكتملة بنجاح'),
                  trailing: const Text('25:00'),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.10)),
                ListTile(
                  leading: Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: theme.hintColor,
                  ),
                  title: const Text('جلسة 2'),
                  subtitle: const Text('لم تبدأ بعد'),
                  trailing: const Text('25:00'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int minutes;
  final double progress;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.timer_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مدة الجلسة: $minutes دقيقة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const _PresetRow({
    required this.selectedMinutes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [15, 25, 45, 60];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final minutes = presets[index];
          final selected = minutes == selectedMinutes;

          return ChoiceChip(
            label: Text('$minutes دقيقة'),
            selected: selected,
            onSelected: (_) => onSelected(minutes),
            selectedColor: AppColors.primary.withOpacity(0.16),
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).dividerColor.withOpacity(0.10),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: presets.length,
      ),
    );
  }
}
