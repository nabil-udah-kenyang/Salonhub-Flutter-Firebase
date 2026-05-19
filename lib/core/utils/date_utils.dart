import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  static String formatDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy').format(date);
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd MMM yyyy').parse(dateString);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } catch (e) {
        return null;
      }
    }
  }

  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateFormat('dd MMM yyyy, HH:mm').parse(dateTimeString);
    } catch (e) {
      try {
        return DateTime.parse(dateTimeString);
      } catch (e) {
        return null;
      }
    }
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(dateTime);
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static List<DateTime> generateTimeSlots(DateTime date, int durationMinutes) {
    final timeSlots = <DateTime>[];
    final startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    final endTime = DateTime(date.year, date.month, date.day, 21, 0); // 9:00 PM

    var currentTime = startTime;
    while (currentTime.isBefore(endTime)) {
      timeSlots.add(currentTime);
      currentTime = currentTime.add(Duration(minutes: durationMinutes));
    }

    return timeSlots;
  }

  static List<String> getTimeSlotStrings(List<DateTime> timeSlots) {
    return timeSlots.map((slot) => formatTime(slot)).toList();
  }

  static DateTime combineDateAndTime(DateTime date, String timeString) {
    try {
      final time = DateFormat('HH:mm').parse(timeString);
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      return date;
    }
  }

  static bool isBusinessHours(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 9 && hour < 21; // 9:00 AM to 9:00 PM
  }

  static List<DateTime> getDaysOfWeek(DateTime startDate) {
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${mins}min';
      }
    }
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
