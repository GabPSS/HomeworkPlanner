enum TaskStatus {
  Overdue,
  None,
  Scheduled,
  ImportantUnscheduled,
  ImportantScheduled,
  Completed
}

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
}