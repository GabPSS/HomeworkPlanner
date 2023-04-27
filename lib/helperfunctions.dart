import 'package:homeworkplanner/models/main/enums.dart';

class HelperFunctions {
  static int getDayCount(int data) {
    double numericData = data.toDouble();
    int dayCount = 0;
    for (double i = 64; i >= 1; i /= 2) {
      if (numericData - i >= 0) {
        dayCount++;
        numericData -= i;
      }
    }
    return dayCount;
  }

  static DateTime getSunday(DateTime dateTime) {
    DayOfWeek dayOfWeek = EnumConverters.weekdayToDayOfWeek(dateTime.weekday);

    return dateTime
        .add(Duration(days: 0 - EnumConverters.dayOfWeekToInt(dayOfWeek)));
  }
}
