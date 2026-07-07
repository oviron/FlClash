import 'package:fl_clash/common/app_localizations.dart';

extension DateTimeExtension on DateTime {
  bool get isBeforeNow {
    return isBefore(DateTime.now());
  }

  String get lastUpdateTimeDesc {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final days = difference.inDays;
    if (days >= 365) {
      final years = (days / 365).floor();
      return appLocalizations.yearsAgo(years);
    }
    if (days >= 30) {
      final months = (days / 30).floor();
      return appLocalizations.monthsAgo(months);
    }
    if (days >= 1) {
      return appLocalizations.daysAgo(days);
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return appLocalizations.hoursAgo(hours);
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return appLocalizations.minutesAgo(minutes);
    }
    return appLocalizations.justNow;
  }

  String get expiresInDesc {
    final now = DateTime.now();
    if (isBefore(now)) return appLocalizations.subExpired;
    final diff = difference(now);
    if (diff.inDays >= 1) return appLocalizations.subDaysLeft(diff.inDays);
    // A sub-hour remainder still has time left; show 1h, never "0 hours left".
    return appLocalizations.subHoursLeft(diff.inHours < 1 ? 1 : diff.inHours);
  }

  String get show {
    return toString().substring(0, 10);
  }

  String get showFull {
    return toString().substring(0, 19);
  }

  String get showTime {
    return toString().substring(10, 19);
  }
}
