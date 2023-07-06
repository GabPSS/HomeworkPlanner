enum TaskStatus { Overdue, None, Scheduled, ImportantUnscheduled, ImportantScheduled, Completed }

enum SortMethod { None, DueDate, ID, Alphabetically, Status, Subject, ExecDate, DateCompleted }

enum DayOfWeek { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

enum DaysToInclude { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class EnumConverters {
  static int taskStatusToInt(TaskStatus value) {
    switch (value) {
      case TaskStatus.Overdue:
        return -10;
      case TaskStatus.None:
        return 0;
      case TaskStatus.Scheduled:
        return 10;
      case TaskStatus.ImportantUnscheduled:
        return 20;
      case TaskStatus.ImportantScheduled:
        return 30;
      case TaskStatus.Completed:
        return 70;
    }
  }

  static TaskStatus intToTaskStatus(int value) {
    switch (value) {
      case -10:
        return TaskStatus.Overdue;
      case 0:
        return TaskStatus.None;
      case 10:
        return TaskStatus.Scheduled;
      case 20:
        return TaskStatus.ImportantUnscheduled;
      case 30:
        return TaskStatus.ImportantScheduled;
      case 70:
        return TaskStatus.Completed;
      default:
        throw Error();
    }
  }

  //TODO: Add SortMethod conversion methods

  static int dayOfWeekToInt(DayOfWeek value) {
    switch (value) {
      case DayOfWeek.sunday:
        return 0;
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
    }
  }

  static DayOfWeek intToDayOfWeek(int value) {
    switch (value) {
      case 0:
        return DayOfWeek.sunday;
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      default:
        throw Error();
    }
  }

  static DayOfWeek weekdayToDayOfWeek(int value) {
    return intToDayOfWeek(weekdayToInt(value));
  }

  /// Converts a value from DateTime.weekday onto the corresponding int for DayOfWeek
  static int weekdayToInt(int value) {
    if (value >= 7) {
      value = 0;
    }
    return value;
  }

  static int daysToIncludeToInt(DaysToInclude value) {
    switch (value) {
      case DaysToInclude.sunday:
        return 1;
      case DaysToInclude.monday:
        return 2;
      case DaysToInclude.tuesday:
        return 4;
      case DaysToInclude.wednesday:
        return 8;
      case DaysToInclude.thursday:
        return 16;
      case DaysToInclude.friday:
        return 32;
      case DaysToInclude.saturday:
        return 64;
    }
  }

  static DaysToInclude dayOfWeekToDaysToInclude(DayOfWeek value) {
    switch (value) {
      case DayOfWeek.sunday:
        return DaysToInclude.sunday;
      case DayOfWeek.monday:
        return DaysToInclude.monday;
      case DayOfWeek.tuesday:
        return DaysToInclude.tuesday;
      case DayOfWeek.wednesday:
        return DaysToInclude.wednesday;
      case DayOfWeek.thursday:
        return DaysToInclude.thursday;
      case DayOfWeek.friday:
        return DaysToInclude.friday;
      case DayOfWeek.saturday:
        return DaysToInclude.saturday;
    }
  }
}
