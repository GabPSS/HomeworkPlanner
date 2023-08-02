import 'package:flutter/widgets.dart';
import 'package:homeworkplanner/enums.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  static int getDayCount(int data) {
    double numericData = data.toDouble();
    int dayCount = 0;
    iterateThroughWeek(numericData, () => dayCount++);
    return dayCount;
  }

  static DateTime getThisSaturday() {
    return getSunday(getToday()).add(const Duration(days: 6));
  }

  static DateTime getSunday(DateTime dateTime) {
    DayOfWeek dayOfWeek = EnumConverters.weekdayToDayOfWeek(dateTime.weekday);

    return dateTime
        .add(Duration(days: 0 - EnumConverters.dayOfWeekToInt(dayOfWeek)));
  }

  static DateTime iterateThroughWeekFromThisSaturday(
          double daysOfWeekSum, Function(DateTime) callback) =>
      iterateThroughWeekFromDate(daysOfWeekSum, getThisSaturday(), callback);

  static DateTime getToday() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// WARNING: [startDate] MUST be a saturday for this method to return an appropriate day of the week
  /// Returns: a DateTime 7 days before [startDate]
  static DateTime iterateThroughWeekFromDate(
      double daysOfWeekSum, DateTime startDate, Function(DateTime) callback) {
    DateTime selectedDate = startDate;
    for (double dayOfWeek = 64; dayOfWeek >= 1; dayOfWeek /= 2) {
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

  static Duration stringToDuration(String value) {
    List<int> timeSplit = value.split(':').map((e) => int.parse(e)).toList();
    assert(timeSplit.length == 3 || timeSplit.length == 2);
    return timeSplit.length == 2
        ? Duration(hours: timeSplit[0], minutes: timeSplit[1])
        : Duration(
            hours: timeSplit[0], minutes: timeSplit[1], seconds: timeSplit[2]);
  }

  static String durationToString(Duration value, [bool shortString = false]) {
    NumberFormat f = NumberFormat('00');
    String secs = f.format(value.inSeconds.toInt() % 60);
    String mins = f.format(value.inMinutes.toInt() % 60);
    String hrs = f.format(value.inHours.toInt() % 60);
    return shortString ? "$hrs:$mins" : "$hrs:$mins:$secs";
  }

  static bool tryDurationShortStringValidation(String? value) {
    if (value == null) {
      return false;
    }
    var input = value.split(':');
    return input.length == 2
        ? int.tryParse(input[0]) != null && int.tryParse(input[1]) != null
            ? true
            : false
        : false;
  }

  static bool getIsPortrait(BuildContext context) {
    try {
      double? aspectRatio2 = context.size?.aspectRatio;
      return (aspectRatio2 ?? 2) < 1;
    } catch (e) {
      return false;
    }
  }
}
