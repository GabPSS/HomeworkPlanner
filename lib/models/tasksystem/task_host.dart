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
import '../main/day_note.dart';
import '../main/task.dart';

class TaskHost {
  String? saveFilePath;
  SaveFile saveFile;
  GlobalSettings settings;

  TaskHost({required this.settings, required this.saveFile, this.saveFilePath});

  String? getSubjectNameById(int id) {
    for (int i = 0; i < saveFile.subjects.items.length; i++) {
      if (saveFile.subjects.items[i].id == id) {
        return saveFile.subjects.items[i].name;
      }
    }
    return null;
  }

  Subject? getSubjectById(int? id) {
    //Special check for editSubject and noSubject
    if (id == -123 || id == -1) {
      return null;
    }

    for (int i = 0; i < saveFile.subjects.items.length; i++) {
      if (saveFile.subjects.items[i].id == id) {
        return saveFile.subjects.items[i];
      }
    }
    return null;
  }

  List<Task> getTasksByExecDate(DateTime date) => saveFile.tasks.items
      .where((element) => element.execDate == date)
      .toList();

  List<Task> getTasksByDueDate(DateTime date) =>
      saveFile.tasks.items.where((element) => element.dueDate == date).toList();

  int getTaskIndexById(int id) {
    for (int i = 0; i < saveFile.tasks.items.length; i++) {
      if (saveFile.tasks.items[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  void unscheduleAllTasks() {
    for (int i = 0; i < saveFile.tasks.items.length; i++) {
      if (!saveFile.tasks.items[i].isCompleted) {
        saveFile.tasks.items[i].execDate = null;
      }
    }
  }

  void rescheduleDueDates(List<Task> tasks) {
    for (var task in tasks) {
      if (task.dueDate == null) continue;
      task.dueDate =
          getNextScheduledDateForSubject(task.subjectID, task.dueDate!);
    }
  }

  static List<Task> sortTasks(SortMethod sortMethod, List<Task> tasks) {
    switch (sortMethod) {
      case SortMethod.DueDate:
        tasks.sort((Task x, Task y) => y.dueDate == null && x.dueDate == null
            ? 0
            : y.dueDate == null
                ? 1
                : x.dueDate == null
                    ? -1
                    : x.dueDate!.compareTo(y.dueDate!));
        break;
      case SortMethod.ID:
        tasks.sort((Task x, Task y) => x.id - y.id);
        break;
      case SortMethod.Alphabetically:
        tasks.sort((Task x, Task y) => x.name.compareTo(y.name));
        break;
      case SortMethod.Status:
        tasks.sort((Task x, Task y) =>
            EnumConverters.taskStatusToInt(x.getStatus()) -
            EnumConverters.taskStatusToInt(y.getStatus()));
        break;
      case SortMethod.Subject:
        tasks.sort((Task x, Task y) => x.subjectID - y.subjectID);
        break;
      case SortMethod.ExecDate:
        tasks.sort((Task x, Task y) => y.execDate != null
            ? (x.execDate != null ? x.execDate!.compareTo(y.execDate!) : 1)
            : -1);
        break;
      case SortMethod.DateCompleted:
        tasks.sort((Task x, Task y) => y.dateCompleted != null
            ? (x.dateCompleted != null
                ? x.dateCompleted!.compareTo(y.dateCompleted!)
                : 1)
            : -1);
        break;
      default:
        break;
    }
    return tasks;
  }

  void removeCompletedTasks() =>
      saveFile.tasks.items.removeWhere((task) => task.isCompleted);

  void removeAllTasks() => saveFile.tasks = TaskList();

  void resetTaskIDs() {
    int i;
    for (i = 0; i < saveFile.tasks.items.length; i++) {
      saveFile.tasks.items[i].id = i;
    }
    saveFile.tasks.lastIndex = i - 1;
  }

  void resetSubjectIDs([int? startIndex]) {
    startIndex ??= saveFile.subjects.lastIndex + 1;

    int newId = startIndex;
    for (int count = 0; count < saveFile.subjects.items.length; count++) {
      updateSubjectId(saveFile.subjects.items[count], newId);
      newId++;
    }

    saveFile.subjects.lastIndex = newId;

    if (startIndex != 0) {
      resetSubjectIDs(0);
    }
  }

  void updateSubjectId(Subject subject, int newId) {
    int oldId = subject.id;
    subject.id = newId;

    for (int i = 0; i < saveFile.tasks.items.length; i++) {
      if (saveFile.tasks.items[i].subjectID == oldId) {
        saveFile.tasks.items[i].subjectID = newId;
      }
    }
  }

  void sortSubjectsByName() {
    saveFile.subjects.items
        .sort((Subject x, Subject y) => x.name.compareTo(y.name));
  }

  void cleanUp(BuildContext context) {
    saveFile.tasks.items =
        sortTasks(SortMethod.Alphabetically, saveFile.tasks.items);
    resetTaskIDs();
    sortSubjectsByName();
    resetSubjectIDs();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savefile cleanup successful')));
  }

  static List<Task> filterCompletedTasks(List<Task> tasks) {
    List<Task> completedTasks = List<Task>.empty(growable: true);
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isCompleted) {
        completedTasks.add(tasks[i]);
      }
    }
    return completedTasks;
  }

  static List<Task> filterRemainingTasks(List<Task> tasks) {
    List<Task> remainingTasks = List<Task>.empty(growable: true);
    for (int i = 0; i < tasks.length; i++) {
      if (!tasks[i].isCompleted) {
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
        if (!context.mounted) return;
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
        if (!context.mounted) return;
        _showReadWriteFailedDialog(context);
        settings.removeRecentFile(path);
      }
    } else {
      if (!context.mounted) return;
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
        if (!context.mounted) return;
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
      saveFile.schedules.daysToDisplay.toDouble(),
      (day) {
        daysAllowed[EnumConverters.weekdayToInt(day.weekday)] = true;
      },
    );
    return Map.fromIterables(daysOfWeek, daysAllowed);
  }

  DateTime? getNextScheduledDateForSubject(
      int subjectId, DateTime searchStartDate) {
    DateTime startDate = searchStartDate.add(const Duration(days: 1));

    int startDayOfWeek = EnumConverters.weekdayToInt(startDate.weekday);
    int dayOfWeek = startDayOfWeek;

    do {
      for (int scheduleHour = 0;
          scheduleHour < saveFile.schedules.items.length;
          scheduleHour++) {
        int? scheduledSubjectId =
            saveFile.schedules.items[scheduleHour].subjects[dayOfWeek];
        if (scheduledSubjectId != null && scheduledSubjectId == subjectId) {
          if (dayOfWeek < startDayOfWeek) {
            dayOfWeek += 7;
          }
          dayOfWeek -= startDayOfWeek;
          DateTime? foundDate = startDate.add(Duration(days: dayOfWeek));
          if (isClassCancelled(foundDate)) {
            foundDate = getNextScheduledDateForSubject(subjectId, foundDate);
          }
          return foundDate;
        }
      }
      dayOfWeek++;
      if (dayOfWeek > 6) {
        dayOfWeek = 0; //Reset to sunday
      }
    } while (dayOfWeek != startDayOfWeek);

    return null;
  }

  List<DayNote> getNotesForDate(DateTime date,
          [bool getCancelledNotes = false, bool getAnyNote = false]) =>
      saveFile.dayNotes
          .where((element) =>
              element.date == date &&
              (element.cancelled == getCancelledNotes || getAnyNote))
          .toList();

  bool isClassCancelled(DateTime date) {
    List<DayNote> notes = getNotesForDate(date, true, true);
    for (var note in notes) {
      if (note.noClass) return true;
    }
    return false;
  }
}
