import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const int totalSeconds = 25 * 60;
  int _remaining = totalSeconds;
  Timer? _timer;
  bool _running = false;

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining <= 0) {
          t.cancel();
          setState(() => _running = false);
          return;
        }
        setState(() => _remaining--);
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remaining = totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final percent = 1 - (_remaining / totalSeconds);
    return AppScaffold(
      title: 'مؤقت التركيز',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('جلسة تركيز', style: Theme.of(context).textTheme.titleMedium),
                  Text('تصميم واجهة التطبيق', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  CircularPercentIndicator(
                    radius: 110,
                    lineWidth: 14,
                    percent: percent.clamp(0, 1),
                    animation: false,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Theme.of(context).dividerColor,
                    progressColor: AppColors.primary,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_label, style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text('دقيقة', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(onPressed: _reset, icon: const Icon(Icons.replay)),
                      const SizedBox(width: 20),
                      FilledButton.icon(
                        onPressed: _toggle,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                        icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                        label: Text(_running ? 'إيقاف مؤقت' : 'بدء التركيز'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('جلسات اليوم', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.check_circle, color: AppColors.accentGreen), title: const Text('جلسة 1'), trailing: const Text('25:00')),
                  const Divider(height: 1),
                  ListTile(leading: Icon(Icons.circle_outlined, color: Theme.of(context).dividerColor), title: const Text('جلسة 2'), trailing: const Text('25:00')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
