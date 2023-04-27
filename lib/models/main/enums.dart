enum TaskStatus {
  Overdue,
  None,
  Scheduled,
  ImportantUnscheduled,
  ImportantScheduled,
  Completed
}

enum SortMethod { None, DueDate, ID, Alphabetically, Status, Subject, ExecDate, DateCompleted }

enum DayOfWeek {Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday}

enum DaysToInclude { Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday }

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
      case DayOfWeek.Sunday:
        return 0;
      case DayOfWeek.Monday:
        return 1;
      case DayOfWeek.Tuesday:
        return 2;
      case DayOfWeek.Wednesday:
        return 3;
      case DayOfWeek.Thursday:
        return 4;
      case DayOfWeek.Friday:
        return 5;
      case DayOfWeek.Saturday:
        return 6;
    }
  }

  static DayOfWeek intToDayOfWeek(int value) {
    switch (value) {
      case 0:
        return DayOfWeek.Sunday;
      case 1:
        return DayOfWeek.Monday;
      case 2:
        return DayOfWeek.Tuesday;
      case 3:
        return DayOfWeek.Wednesday;
      case 4:
        return DayOfWeek.Thursday;
      case 5:
        return DayOfWeek.Friday;
      case 6:
        return DayOfWeek.Saturday;
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
      case DaysToInclude.Sunday:
        return 1;
      case DaysToInclude.Monday:
        return 2;
      case DaysToInclude.Tuesday:
        return 4;
      case DaysToInclude.Wednesday:
        return 8;
      case DaysToInclude.Thursday:
        return 16;
      case DaysToInclude.Friday:
        return 32;
      case DaysToInclude.Saturday:
        return 64;
    }
  }
}