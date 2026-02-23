/// Normalizes a string for write-mode comparison: trim, lowercase, and
/// replace Serbian diacritic letters with ASCII equivalents (ž→z, č/ć→c, š→s, đ→d).
String normalizeForComparison(String s) {
  final t = s.trim().toLowerCase();
  return t
      .replaceAll('ž', 'z')
      .replaceAll('č', 'c')
      .replaceAll('ć', 'c')
      .replaceAll('š', 's')
      .replaceAll('đ', 'd');
}
