import 'package:intl/intl.dart';

/// Formats a [DateTime] for bilingual display (Traditional Chinese + English).
///
/// Example output:
///   2026年7月27日 星期一
///   Monday, July 27, 2026
class BilingualDateFormatter {
  const BilingualDateFormatter._();

  /// Full date with weekday, suitable for the large date header.
  /// Chinese: 2026年7月27日 星期一
  /// English: Monday, July 27, 2026
  static String full(DateTime date) {
    final zh = DateFormat('yyyy年M月d日 EEEE', 'zh_TW').format(date);
    final en = DateFormat('EEEE, MMMM d, yyyy').format(date);
    return '$zh\n$en';
  }

  /// Compact date for event cards (no year, shorter).
  /// Chinese: 7月27日 週一
  /// English: Mon, Jul 27
  static String compact(DateTime date) {
    final zh = DateFormat('M月d日', 'zh_TW').format(date);
    final weekday = DateFormat('EEEE', 'zh_TW').format(date);
    final en = DateFormat('EEE, MMM d').format(date);
    return '$zh $weekday\n$en';
  }
}
