import 'package:homeworkplanner/models/lists/tasklist.dart';
import 'package:homeworkplanner/tasksystem/savefile.dart';
import 'package:homeworkplanner/models/main/subject.dart';

import '../models/main/enums.dart';
import '../models/main/task.dart';

class TaskHost {
  String? saveFilePath;
  SaveFile saveFile; //TODO: Update code with lowercase saveFile

  TaskHost({required this.saveFile});

  ///Obtains a subject name given its ID
  String getSubject(int id) {
    String output = Subject.defaultMissingSubjectText;
    for (int i = 0; i < saveFile.Subjects.Items.length; i++) {
      if (saveFile.Subjects.Items[i].SubjectID == id) {
        output = saveFile.Subjects.Items[i].SubjectName;
      }
    }
    return output;
  }

  Subject getSubjectById(int id) {
    for (int i = 0; i < saveFile.Subjects.Items.length; i++) {
      if (saveFile.Subjects.Items[i].SubjectID == id) {
        return saveFile.Subjects.Items[i];
      }
    }
    throw Error();
  }

  List<Task> getTasksPlannedForDate(DateTime date) {
    List<Task> tasks = List<Task>.empty();
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].ExecDate != null) {
        if (saveFile.Tasks.Items[i].ExecDate == date) {
          tasks.add(saveFile.Tasks.Items[i]);
        }
      }
    }
    return tasks;
  }

  /// Gets the index of a task in SaveFile.Tasks.Items based on the task ID
  int GetTaskIndexById(int id) {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].TaskID == id) {
        return i;
      }
    }
    return -1;
  }

  /// Unschedules all tasks from the SaveFile
  ///
  /// This makes for the effect where when excludeCompleted is false, everything is unscheduled
  /// However, when it's true, only the items that are not completed are unscheduled
  void unscheduleAllTasks({bool excludeCompleted = false}) {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (!saveFile.Tasks.Items[i].IsCompleted || !excludeCompleted) {
        saveFile.Tasks.Items[i].ExecDate = null;
      }
    }
  }

  /// Sorts a list of tasks using the given sortMethod
  static List<Task> SortTasks(SortMethod sortMethod, List<Task> tasks) {
    switch (sortMethod) {
      case SortMethod.DueDate:
        //tasks.Sort((Task x, Task y) => { return x.DueDate == y.DueDate ? 0 : x.DueDate > y.DueDate ? 1 : -1; });
        tasks.sort((Task x, Task y) => x.DueDate.compareTo(y.DueDate));
        break;
      case SortMethod.ID:
        tasks.sort((Task x, Task y) => x.TaskID - y.TaskID);
        break;
      case SortMethod.Alphabetically:
        tasks.sort((Task x, Task y) => x.Name.compareTo(y.Name));
        break;
      case SortMethod.Status:
        tasks.sort((Task x, Task y) =>
            EnumConverters.taskStatusToInt(x.GetStatus()) -
            EnumConverters.taskStatusToInt(y.GetStatus()));
        break;
      case SortMethod.Subject:
        tasks.sort((Task x, Task y) => x.SubjectID - y.SubjectID);
        break;
      case SortMethod.ExecDate:
        tasks.sort((Task x, Task y) => y.ExecDate != null
            ? (x.ExecDate != null ? x.ExecDate!.compareTo(y.ExecDate!) : 1)
            : -1);
        break;
      case SortMethod.DateCompleted:
        tasks.sort((Task x, Task y) => y.DateCompleted != null
            ? (x.DateCompleted != null
                ? x.DateCompleted!.compareTo(y.DateCompleted!)
                : 1)
            : -1);
        break;
      default:
        break;
    }
    return tasks;
  }

  void RemoveCompletedTasks() => saveFile.Tasks.Items.removeWhere(
      (x) => x.IsCompleted); //TODO: Test if this is the right order

  void RemoveAllTasks() => saveFile.Tasks = TaskList();

  void ResetTaskIDs() {
    int i;
    for (i = 0; i < saveFile.Tasks.Items.length; i++) {
      saveFile.Tasks.Items[i].TaskID = i;
    }
    saveFile.Tasks.LastIndex = i - 1;
  }

  void ResetSubjectIDs() {
    int new_sid;
    for (new_sid = 0; new_sid < saveFile.Subjects.Items.length; new_sid++) {
      int old_sid = saveFile.Subjects.Items[new_sid].SubjectID;

      for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
        if (saveFile.Tasks.Items[i].SubjectID == old_sid) {
          saveFile.Tasks.Items[i].SubjectID = new_sid;
        }
      }

      saveFile.Subjects.Items[new_sid].SubjectID = new_sid;
    }

    saveFile.Subjects.LastIndex = new_sid - 1;
  }

  void SortSubjectsByName() {
    saveFile.Subjects.Items
        .sort((Subject x, Subject y) => x.SubjectName.compareTo(y.SubjectName));
  }

  DateTime? GetNextSubjectScheduledDate(int subjectId, DateTime startDate) {
    DateTime date = startDate.add(Duration(days: 1));
    int dayOfWeek = EnumConverters.weekdayToInt(date.weekday); //2

    //Go through each day of week starting from today
    int dayOffset = dayOfWeek;
    do {
      //Go through each schedule and see if any of them match subjectId at dayOffset position
      for (int i = 0; i < saveFile.Schedules.Items.length; i++) {
        int? scheduledSubject = saveFile.Schedules.Items[i].Subjects[dayOffset];
        if (scheduledSubject != null && scheduledSubject == subjectId) {
          //This means the next subject's day of week is found and is dayOffset!
          //Next, get how many days until then and add that to date
          if (EnumConverters.weekdayToInt(date.weekday) > dayOffset) {
            dayOffset += 7;
          }
          dayOffset -= EnumConverters.weekdayToInt(date.weekday);
          date = date.add(Duration(days: dayOffset));
          return date;
        }
      }
      dayOffset++;
      if (dayOffset > 6) {
        dayOffset = 0;
      }
    } while (dayOffset != dayOfWeek);

    return null;
  }

  static List<Task> filterCompletedTasks(List<Task> tasks) {
    List<Task> completedTasks = List<Task>.empty(growable: true);
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].IsCompleted) {
        completedTasks.add(tasks[i]);
      }
    }
    return completedTasks;
  }

  static List<Task> filterRemainingTasks(List<Task> tasks) {
    List<Task> remainingTasks = List<Task>.empty(growable: true);
    for (int i = 0; i < tasks.length; i++) {
      if (!tasks[i].IsCompleted) {
        remainingTasks.add(tasks[i]);
      }
    }
    return remainingTasks;
  }
}
