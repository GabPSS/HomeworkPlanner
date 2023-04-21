import 'package:homeworkplanner/tasksystem/savefile.dart';
import 'package:homeworkplanner/models/main/subject.dart';

import '../models/main/task.dart';

class TaskHost {
  String? SaveFilePath;
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
}
