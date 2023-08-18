import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/global_settings.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/lists/task_list.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:share_plus/share_plus.dart';

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
        if (DateTime(execDate.year, execDate.month, execDate.day) ==
            DateTime(date.year, date.month, date.day)) {
          tasks.add(saveFile.Tasks.Items[i]);
        }
      }
    }
    return tasks;
  }

  int getTaskIndexById(int id) {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].TaskID == id) {
        return i;
      }
    }
    return -1;
  }

  void unscheduleAllTasks() {
    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (!saveFile.Tasks.Items[i].IsCompleted) {
        saveFile.Tasks.Items[i].ExecDate = null;
      }
    }
  }

  static List<Task> sortTasks(SortMethod sortMethod, List<Task> tasks) {
    switch (sortMethod) {
      case SortMethod.DueDate:
        tasks.sort((Task x, Task y) =>
            y.DueDate == null ? -1 : (x.DueDate?.compareTo(y.DueDate!) ?? -1));
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

  void removeCompletedTasks() =>
      saveFile.Tasks.Items.removeWhere((task) => task.IsCompleted);

  void removeAllTasks() => saveFile.Tasks = TaskList();

  void resetTaskIDs() {
    int i;
    for (i = 0; i < saveFile.Tasks.Items.length; i++) {
      saveFile.Tasks.Items[i].TaskID = i;
    }
    saveFile.Tasks.LastIndex = i - 1;
  }

  void resetSubjectIDs([int? startIndex]) {
    startIndex ??= saveFile.Subjects.LastIndex + 1;

    int newId = startIndex;
    for (int count = 0; count < saveFile.Subjects.Items.length; count++) {
      updateSubjectId(saveFile.Subjects.Items[count], newId);
      newId++;
    }

    saveFile.Subjects.LastIndex = newId;

    if (startIndex != 0) {
      resetSubjectIDs(0);
    }
  }

  void updateSubjectId(Subject subject, int newId) {
    int oldId = subject.SubjectID;
    subject.SubjectID = newId;

    for (int i = 0; i < saveFile.Tasks.Items.length; i++) {
      if (saveFile.Tasks.Items[i].SubjectID == oldId) {
        saveFile.Tasks.Items[i].SubjectID = newId;
      }
    }
  }

  void sortSubjectsByName() {
    saveFile.Subjects.Items
        .sort((Subject x, Subject y) => x.SubjectName.compareTo(y.SubjectName));
  }

  void cleanUp(BuildContext context) {
    saveFile.Tasks.Items =
        sortTasks(SortMethod.Alphabetically, saveFile.Tasks.Items);
    resetTaskIDs();
    sortSubjectsByName();
    resetSubjectIDs();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Savefile cleanup successful')));
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

  static Future<void> openFile(BuildContext context, GlobalSettings settings,
      Function(TaskHost host) onLoad,
      [String? filePath]) async {
    if (filePath == null) {
      if (settings.mobileLayout) {
        await FilePicker.platform.clearTemporaryFiles();
      }

      FilePickerResult? result = await FilePicker.platform
          .pickFiles(dialogTitle: 'Select a homeworkplanner plan...');

      String? path = result?.files.single.path;
      if (path != null) {
        _openFileFromPath(path, context, settings, onLoad);
      }
    } else {
      _openFileFromPath(filePath, context, settings, onLoad);
    }
  }

  static Future<void> _openFileFromPath(String path, BuildContext context,
      GlobalSettings settings, Function(TaskHost host) onLoad) async {
    var file = File(path);
    if (await file.exists()) {
      try {
        file.readAsString().then((jsonvalue) {
          settings.addRecentFile(path);
          onLoad(TaskHost(
              settings: settings,
              saveFile: SaveFile.fromJson(jsonDecode(jsonvalue)),
              saveFilePath: path));
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

  static void _showReadWriteFailedDialog(BuildContext context,
      [bool saving = false]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(!saving ? 'Failed to open plan' : 'Failed to save plan'),
        content: Text(!saving
            ? "Couldn't read the file specified. It might have been corrupted, or the system couldn't access it.\nIf the file was created with an earlier version of HomeworkPlanner, try converting it to a newer version first, then try opening it again"
            : "Couldn't save the plan to the specified path. Make sure you have access to it, and that it isn't in a disconnected volume on nonexistant directory, then try again"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> save(BuildContext context, [String? path]) async {
    path ??= saveFilePath;
    if (path != null) {
      try {
        saveFilePath = path;
        String jsonData = _getJsonSaveFile();
        await File(path).writeAsString(jsonData);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File saved at $path')));
        settings.addRecentFile(path);
      } catch (e) {
        _showReadWriteFailedDialog(context, true);
        settings.removeRecentFile(path);
      }
    } else {
      saveAs(context);
    }
  }

  String _getJsonSaveFile() => jsonEncode(saveFile.toJson());

  void saveAs(BuildContext context) {
    if (settings.mobileLayout) {
      save(context, "/storage/emulated/0/Download/Plan.hwpf");
    } else {
      FilePicker.platform.saveFile(
          dialogTitle: "Save plan as...",
          allowedExtensions: ['hwpf', 'txt', '*.*']).then((value) {
        if (value != null) {
          save(context, value);
        }
      });
    }
  }

  Future<void> share(BuildContext context) async {
    await save(context);
    String dataString = jsonEncode(saveFile.toJson());
    Uint8List data = utf8.encoder.convert(dataString);
    XFile xFile;
    if (saveFilePath == null) {
      xFile = XFile.fromData(data);
    } else {
      xFile = XFile.fromData(data, path: saveFilePath);
    }
    Share.shareXFiles([xFile]);
  }

  Map<String, bool> getScheduleDaysOfWeek() {
    List<String> daysOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    List<bool> daysAllowed = [false, false, false, false, false, false, false];
    HelperFunctions.iterateThroughWeekFromThisSaturday(
      saveFile.Schedules.DaysToDisplay.toDouble(),
      (day) {
        daysAllowed[EnumConverters.weekdayToInt(day.weekday)] = true;
      },
    );
    return Map.fromIterables(daysOfWeek, daysAllowed);
  }

  DateTime? getNextSubjectScheduledDate(
      int subjectId, DateTime searchStartDate) {
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
