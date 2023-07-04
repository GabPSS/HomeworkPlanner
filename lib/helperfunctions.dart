import 'package:homeworkplanner/enums.dart';

class HelperFunctions {
  static int getDayCount(int data) {
    double numericData = data.toDouble();
    int dayCount = 0;
    iterateThroughWeek(numericData, () => dayCount++);
    return dayCount;
  }

  static DateTime getSunday(DateTime dateTime) {
    DayOfWeek dayOfWeek = EnumConverters.weekdayToDayOfWeek(dateTime.weekday);

    return dateTime.add(Duration(days: 0 - EnumConverters.dayOfWeekToInt(dayOfWeek)));
  }

  static DateTime getToday() => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// WARNING: [startDate] MUST be a saturday for this method to work
  /// Returns: a DateTime 7 days before [startDate]
  static DateTime iterateThroughWeekFromDate(double daysOfWeekSum, DateTime startDate, Function(DateTime) callback) {
    DateTime selectedDate = startDate;
    for (double dayOfWeek = 64; dayOfWeek > 0; dayOfWeek /= 2) {
      if (daysOfWeekSum - dayOfWeek >= 0) {
        callback(selectedDate);
        daysOfWeekSum -= dayOfWeek;
      }
      selectedDate = selectedDate.add(const Duration(days: -1));
    }
    return selectedDate;
  }

  static void iterateThroughWeek(double daysOfWeekSum, Function() callback) {
    for (double dayOfWeek = 64; dayOfWeek > 0; dayOfWeek /= 2) {
      if (daysOfWeekSum - dayOfWeek >= 0) {
        callback();
        daysOfWeekSum -= dayOfWeek;
      }
    }
  }

  static String getFileNameFromPath(String filePath) {
    RegExp exp = RegExp(r"[^\\\/]*.$");
    List<String?> matches = exp.allMatches(filePath).map((e) => e[0]).toList();
    if (matches.isEmpty) {
      return filePath;
    }
    return matches[0] ?? filePath;
  }
}
