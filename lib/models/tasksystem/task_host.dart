import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/global_settings.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/lists/task_list.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:homeworkplanner/models/main/subject.dart';

import '../../enums.dart';
import '../main/task.dart';

class TaskHost {
  String? saveFilePath;
  SaveFile saveFile;
  GlobalSettings settings;

  TaskHost({required this.settings, required this.saveFile, this.saveFilePath});

  String? getSubjectNameById(int id) {
    for (int i = 0; i < saveFile.Subjects.Items.length; i++) {
      if (saveFile.Subjects.Items[i].SubjectID == id) {
        return saveFile.Subjects.Items[i].SubjectName;
      }
    }
    return null;
  }

  Subject? getSubjectById(int? id) {
    //Special check for editSubject and noSubject
    if (id == -123 || id == -1) {
      return null;
    }

    for (int i = 0; i < saveFile.Subjects.Items.length; i++) {
      if (saveFile.Subjects.Items[i].SubjectID == id) {
        return saveFile.Subjects.Items[i];
      }
    }
    return null;
  }

  List<Task> getTasksPlannedForDate(DateTime date) {
    List<Task> tasks = List<Task>.empty(growable: true);
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].ExecDate != null) {
        DateTime execDate = saveFile.Tasks.Items[i].ExecDate!;
        if (DateTime(execDate.year, execDate.month, execDate.day) == DateTime(date.year, date.month, date.day)) {
          tasks.add(saveFile.Tasks.Items[i]);
        }
      }
    }
    return tasks;
  }

  int GetTaskIndexById(int id) {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].TaskID == id) {
        return i;
      }
    }
    return -1;
  }

  void unscheduleAllTasks({bool excludeCompleted = false}) {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (!saveFile.Tasks.Items[i].IsCompleted || !excludeCompleted) {
        saveFile.Tasks.Items[i].ExecDate = null;
      }
    }
  }

  static List<Task> SortTasks(SortMethod sortMethod, List<Task> tasks) {
    switch (sortMethod) {
      case SortMethod.DueDate:
        tasks.sort((Task x, Task y) => y.DueDate == null ? -1 : (x.DueDate?.compareTo(y.DueDate!) ?? -1));
        break;
      case SortMethod.ID:
        tasks.sort((Task x, Task y) => x.TaskID - y.TaskID);
        break;
      case SortMethod.Alphabetically:
        tasks.sort((Task x, Task y) => x.Name.compareTo(y.Name));
        break;
      case SortMethod.Status:
        tasks.sort(
            (Task x, Task y) => EnumConverters.taskStatusToInt(x.GetStatus()) - EnumConverters.taskStatusToInt(y.GetStatus()));
        break;
      case SortMethod.Subject:
        tasks.sort((Task x, Task y) => x.SubjectID - y.SubjectID);
        break;
      case SortMethod.ExecDate:
        tasks.sort((Task x, Task y) => y.ExecDate != null ? (x.ExecDate != null ? x.ExecDate!.compareTo(y.ExecDate!) : 1) : -1);
        break;
      case SortMethod.DateCompleted:
        tasks.sort((Task x, Task y) =>
            y.DateCompleted != null ? (x.DateCompleted != null ? x.DateCompleted!.compareTo(y.DateCompleted!) : 1) : -1);
        break;
      default:
        break;
    }
    return tasks;
  }

  void RemoveCompletedTasks() => saveFile.Tasks.Items.removeWhere((x) => x.IsCompleted); //TODO: Test if this is the right order

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
    saveFile.Subjects.Items.sort((Subject x, Subject y) => x.SubjectName.compareTo(y.SubjectName));
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

  static void openFile(BuildContext context, GlobalSettings settings, Function(TaskHost host) onLoad, [String? filePath]) {
    if (filePath == null) {
      FilePicker.platform.pickFiles(dialogTitle: 'Select a homeworkplanner plan...').then((value) {
        String? path = value?.files.single.path;
        if (value != null && path != null) {
          _openFileFromPath(path, context, settings, onLoad);
        }
      });
    } else {
      _openFileFromPath(filePath, context, settings, onLoad);
    }
  }

  static Future<void> _openFileFromPath(
      String path, BuildContext context, GlobalSettings settings, Function(TaskHost host) onLoad) async {
    var file = File(path);
    if (await file.exists()) {
      try {
        file.readAsString().then((jsonvalue) {
          settings.addRecentFile(path);
          onLoad(TaskHost(settings: settings, saveFile: SaveFile.fromJson(jsonDecode(jsonvalue)), saveFilePath: path));
        });
      } catch (e) {
        _showReadWriteFailedDialog(context);
        settings.removeRecentFile(path);
      }
    } else {
      _showReadWriteFailedDialog(context);
      settings.removeRecentFile(path);
    }
  }

  static void _showReadWriteFailedDialog(BuildContext context, [bool saving = false]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(!saving ? 'Failed to open plan' : 'Failed to save plan'),
        content: Text(!saving
            ? "Couldn't read the file specified. It might have been corrupted, or the system couldn't access it.\nIf the file was created with an earlier version of HomeworkPlanner, try converting it to a newer version first, then try opening it again"
            : "Couldn't save the plan to the specified path. Make sure you have access to it, and that it isn't in a disconnected volume on nonexistant directory, then try again"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void save(BuildContext context, [String? path]) {
    path ??= saveFilePath;
    if (path != null) {
      try {
        saveFilePath = path;
        String jsonData = jsonEncode(saveFile.toJson());
        File(path).writeAsString(jsonData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File saved at $path')));
        settings.addRecentFile(path);
      } catch (e) {
        _showReadWriteFailedDialog(context, true);
        settings.removeRecentFile(path);
      }
    } else {
      saveAs(context);
    }
  }

  void saveAs(BuildContext context) {
    if (Platform.isAndroid) {
      save(context, "/storage/emulated/0/Download/Plan.hwpf");
    } else {
      FilePicker.platform.saveFile(dialogTitle: "Save plan as...", allowedExtensions: ['hwpf', 'txt', '*.*']).then((value) {
        if (value != null) {
          save(context, value);
        }
      });
    }
  }

  Map<String, bool> getScheduleDaysOfWeek() {
    List<String> daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    List<bool> daysAllowed = [false, false, false, false, false, false, false];
    HelperFunctions.iterateThroughWeekFromThisSaturday(
      saveFile.Schedules.DaysToDisplay.toDouble(),
      (day) {
        daysAllowed[EnumConverters.weekdayToInt(day.weekday)] = true;
      },
    );
    return Map.fromIterables(daysOfWeek, daysAllowed);
  }

  DateTime? getNextSubjectScheduledDate(int subjectId, DateTime searchStartDate) {
    DateTime searchDate = searchStartDate.add(const Duration(days: 1));

    int dayOfWeek = EnumConverters.weekdayToInt(searchDate.weekday);
    int dayOffset = dayOfWeek;

    do {
      for (var i = 0; i < saveFile.Schedules.Items.length; i++) {
        int? scheduledSubject = saveFile.Schedules.Items[i].Subjects[dayOffset];
        if (scheduledSubject != null && scheduledSubject == subjectId) {
          if (dayOfWeek > dayOffset) {
            dayOffset += 7;
          }
          dayOffset -= dayOfWeek;
          return searchDate.add(Duration(days: dayOffset));
        }
      }
      dayOffset++;
      if (dayOffset > 6) {
        dayOffset = 0;
      }
    } while (dayOffset != dayOfWeek);

    return null;
  }
}
