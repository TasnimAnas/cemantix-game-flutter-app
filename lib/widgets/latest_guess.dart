import 'package:flutter/material.dart';
import '../utils/utils.dart';

class LatestProgressCircle extends StatelessWidget {
  final String word;
  final double progress; // normalized 0..1
  final double temperature;
  final double progressValue; // raw 0..1000
  final int rank;

  const LatestProgressCircle({
    Key? key,
    required this.word,
    required this.progress,
    required this.temperature,
    required this.progressValue,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ringSize = 190.0;
    final textTheme = Theme.of(context).textTheme;
    const orange = Color(0xFFFFA662);

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 12.0,
                  color: orange,
                  backgroundColor: Colors.grey.withOpacity(0.18),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      word,
                      style: textTheme.titleLarge,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Temp: ${formatTemperatureWithEmoji(temperature)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // animate the numeric progress value separately
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: progressValue.clamp(0.0, 1000.0),
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) => Text(
                      'Progress: ${animatedValue.toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
