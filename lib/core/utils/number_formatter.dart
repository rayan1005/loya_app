/// Formats a number to a compact string (1k, 1.2m, etc.)
String formatCompactNumber(int number) {
  if (number < 1000) {
    return number.toString();
  } else if (number < 1000000) {
    final k = number / 1000;
    if (k == k.roundToDouble()) {
      return '${k.round()}k';
    }
    return '${k.toStringAsFixed(1)}k';
  } else if (number < 1000000000) {
    final m = number / 1000000;
    if (m == m.roundToDouble()) {
      return '${m.round()}m';
    }
    return '${m.toStringAsFixed(1)}m';
  } else {
    final b = number / 1000000000;
    if (b == b.roundToDouble()) {
      return '${b.round()}b';
    }
    return '${b.toStringAsFixed(1)}b';
  }
}
