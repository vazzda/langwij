import 'package:langwij/l10n/app_localizations.dart';

class RelativeDateFormat {
  const RelativeDateFormat._();

  static String format(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final days = diff.inDays;

    if (days == 0) {
      return l10n.relativeDateToday;
    } else if (days == 1) {
      return l10n.relativeDateYesterday;
    } else if (days < 30) {
      return l10n.relativeDateDays(days);
    } else if (days < 365) {
      final months = (days / 30).floor();
      return l10n.relativeDateMonths(months);
    } else {
      final years = (days / 365).floor();
      return l10n.relativeDateYears(years);
    }
  }
}
