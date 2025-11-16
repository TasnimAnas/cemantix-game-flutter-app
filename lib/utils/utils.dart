import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

int getTodaysCode() {
  final paris = tz.getLocation('Europe/Paris');

  final nowParis = tz.TZDateTime.now(paris);

  final baseDate = tz.TZDateTime(paris, 2025, 11, 13); // 13 Nov 2025
  const baseCode = 1352;

  final daysSince = nowParis.difference(baseDate).inDays;

  return baseCode + daysSince;
}

String getTodaysDate() {
  final paris = tz.getLocation('Europe/Paris');
  final nowParis = tz.TZDateTime.now(paris);
  final date = DateTime(nowParis.year, nowParis.month, nowParis.day);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String emojiForTemperature(double t) {
  if (t > 100.00) return '🥳';
  if (t > 53.69) return '😱';
  if (t > 44.70) return '🔥';
  if (t > 31.85) return '🥵';
  if (t > 19.22) return '😎';
  if (t > 0.00) return '🥶';
  return '🧊';
}

String formatTemperatureWithEmoji(double t) {
  final emoji = emojiForTemperature(t);
  return '${t.toStringAsFixed(2)}° $emoji';
}
