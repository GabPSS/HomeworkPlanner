import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';

import '../models/tasksystem/task_host.dart';

class MainPage extends StatefulWidget {
  TaskHost host;

  MainPage({super.key, required this.host});

  @override
  State<MainPage> createState() => _MainPageState(host: host);
}

class _MainPageState extends State<MainPage> {
  TaskHost host;
  AppBar? appBar;
  BottomNavigationBar? bottomNav;
  int bottomNavSelectedIndex = 0;

  _MainPageState({required this.host});

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    if (Platform.isAndroid) {
      appBar = buildAndroidAppBar();
      bottomNav = buildAndroidBottomNav();
      switch (bottomNavSelectedIndex) {
        case 0:
          currentPage = Expanded(child: buildPlannerViewPanel());
          break;
        case 1:
          currentPage = Expanded(child: buildAllTasksPanel());
          break;
        default:
          throw UnimplementedError('Page not implemented');
      }
    } else {
      currentPage = Expanded(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: buildPlannerViewPanel(),
            ),
            Expanded(
              flex: 1,
              child: buildAllTasksPanel(),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createTask();
        },
        child: const Icon(Icons.assignment_add),
      ),
      body: Column(
        children: [buildDesktopMenuBar(context), currentPage],
      ),
    );
  }

  Widget buildAllTasksPanel() {
    List<Widget> items = List.empty(growable: true);
    items.add(const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text("All tasks"),
    ));

    List<Task> allTasks = host.saveFile.Tasks.Items
        .where((element) =>
            host.saveFile.Settings.DisplayPreviousTasks ||
            !(element.IsCompleted && element.DateCompleted!.isBefore(HelperFunctions.getToday())))
        .toList();

    for (var i = 0; i < allTasks.length; i++) {
      Task task = allTasks[i];
      String? subjectName = host.getSubjectNameById(task.SubjectID);
      Widget itemTile = ListTile(
        leading: IconButton(
            onPressed: () {
              setState(() {
                task.IsCompleted = !task.IsCompleted;
              });
            },
            icon: task.GetIcon()),
        title: Text((task.SubjectID != -1 && subjectName != null ? "${subjectName} - " : "") + task.toString()),
        subtitle: Text("Due: ${task.DueDate}"),
        onTap: () {
          TaskEditor.show(context: context, host: host, task: task, onTaskUpdated: updateTasks);
        },
      );
      items.add(LongPressDraggable(
        data: task,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: task.GetIcon(),
        child: itemTile,
        onDragStarted: () {
          setState(() {
            task.ExecDate = null;
            if (Platform.isAndroid) {
              bottomNavSelectedIndex = 0;
            }
          });
        },
      ));
    }

    return ListView(
      children: items,
    );
  }

  Column buildPlannerViewPanel() {
    List<Widget> rows = List.empty(growable: true);
    List<Widget> cols;

    int rowCount = host.saveFile.Settings.FutureWeeks + 1;

    DateTime selectedDay = HelperFunctions.getSunday(DateTime.now()).add(const Duration(days: 6));

    for (int row = 0; row < rowCount; row++) {
      cols = List.empty(growable: true);

      selectedDay = HelperFunctions.iterateThroughWeekFromDate(
        host.saveFile.Settings.DaysToDisplay.toDouble(),
        selectedDay,
        (p0) {
          cols.add(buildTaskListForDate(p0));
        },
      ).add(const Duration(days: 14));

      cols = cols.reversed.cast<Widget>().toList(growable: true);
      rows.add(Expanded(child: Row(children: cols)));
    }

    return Column(children: rows);
  }

  Widget buildTaskListForDate(DateTime selectedDay) {
    List<Widget> taskWidgets = List.empty(growable: true);
    taskWidgets.add(Text("${selectedDay.day}/${selectedDay.month}"));
    List<Task> tasksForDate = host.getTasksPlannedForDate(selectedDay);

    taskWidgets.addAll(tasksForDate
        .map<ListTile>((e) => ListTile(
              title: Text(e.toString()),
              subtitle: Text(e.DueDate != Task.minimumDateTime ? "Due ${e.DueDate.toString()}" : "No due date"),
            ))
        .toList());
    return Expanded(
        child: DragTarget(
      builder: (context, candidateData, rejectedData) {
        return ListView(
          children: taskWidgets,
        );
      },
      onAccept: (data) {
        setState(() {
          if (data is Task) {
            data.ExecDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          }
        });
      },
    ));
  }

  AppBar buildAndroidAppBar() {
    return AppBar(
      title: const Text('HomeworkPlanner'),
      actions: [
        IconButton(onPressed: openFile, icon: const Icon(Icons.file_open)),
        IconButton(onPressed: saveSavefile, icon: const Icon(Icons.save)),
        IconButton(onPressed: updateTasks, icon: const Icon(Icons.refresh))
      ],
    );
  }

  BottomNavigationBar buildAndroidBottomNav() {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Planner"),
        const BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Tasks')
      ],
      currentIndex: bottomNavSelectedIndex,
      onTap: (value) {
        setState(() {
          bottomNavSelectedIndex = value;
        });
      },
    );
  }

  Row buildDesktopMenuBar(BuildContext context) {
    if (Platform.isAndroid) {
      return const Row();
    } else {
      return Row(
        children: [
          Expanded(
            child: MenuBar(
              children: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: createSaveFile,
                      child: const Text('New'),
                    ),
                    MenuItemButton(
                      onPressed: openFile,
                      child: const Text('Open...'),
                    ),
                    const MenuItemButton(
                      child: Text('Import...'),
                    ),
                    const SubmenuButton(menuChildren: [], child: Text('Recent files')),
                    MenuItemButton(onPressed: saveSavefile, child: const Text('Save')),
                    MenuItemButton(
                      onPressed: saveAs,
                      child: const Text('Save as...'),
                    ),
                    const MenuItemButton(child: Text('Exit'))
                  ],
                  child: const Text('File'),
                ),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                    onPressed: createTask,
                    child: const Text('New...'),
                  ),
                  const MenuItemButton(child: Text('Import...')),
                  const SubmenuButton(menuChildren: [
                    MenuItemButton(child: Text('Remaining only')),
                    MenuItemButton(child: Text('Everything')),
                  ], child: Text('Unschedule tasks')),
                  const SubmenuButton(
                      menuChildren: [MenuItemButton(child: Text('Completed')), MenuItemButton(child: Text('Everything'))],
                      child: Text('Remove tasks'))
                ], child: const Text('Tasks')),
                SubmenuButton(menuChildren: [
                  const MenuItemButton(child: Text('Day notes...')),
                  const MenuItemButton(child: Text('Report...')),
                  MenuItemButton(
                    child: const Text('Subjects...'),
                    onPressed: () {
                      SubjectsPage.show(context, host, updateTasks);
                    },
                  ),
                  const MenuItemButton(child: Text('Clean up...')),
                  const MenuItemButton(child: Text('Manage schedules...')),
                ], child: const Text('Tools')),
                SubmenuButton(menuChildren: [
                  const MenuItemButton(child: Text('Get help...')),
                  MenuItemButton(
                    child: const Text('About...'),
                    onPressed: () {
                      showAboutDialog(
                          context: context, applicationName: 'HomeworkPlanner', applicationLegalese: '(C) Gabriel P. 2023');
                    },
                  )
                ], child: const Text('About'))
              ],
            ),
          ),
        ],
      );
    }
  }

  void createTask() {
    Task task = Task();
    setState(() {
      host.saveFile.Tasks.Add(task);
    });
    TaskEditor.show(context: context, task: task, host: host, onTaskUpdated: updateTasks, isAdding: true);
  }

  void createSaveFile() {
    setState(() {
      host = TaskHost(saveFile: SaveFile());
    });
  }

  void openFile() {
    FilePicker.platform.pickFiles(dialogTitle: 'Select a homeworkplanner plan...').then((value) {
      if (value != null && value.files.single.path != null) {
        File(value.files.single.path!).readAsString().then((jsonvalue) {
          setState(() {
            host = TaskHost(saveFile: SaveFile.fromJson(jsonDecode(jsonvalue)));
            host.saveFilePath = value.files.single.path;
          });
        });
      }
    });
  }

  void saveSavefile({String? path, bool noRetry = false}) {
    path = path ?? host.saveFilePath;
    if (path != null) {
      try {
        host.saveFilePath = path;
        String jsonData = jsonEncode(host.saveFile.toJson());
        File(path).writeAsString(jsonData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File saved at ' + path)));
      } catch (e) {
        if (!noRetry) {
          saveAs(noRetry: true);
        } else {
          //TODO: Implement an alert dialog with some options
          throw UnimplementedError("Alert dialog not implemented here");
        }
      }
    } else {
      saveAs();
    }
  }

  void saveAs({bool noRetry = false}) {
    if (Platform.isAndroid) {
      saveSavefile(path: "/storage/emulated/0/Download/Plan.hwpf");
    } else {
      FilePicker.platform.saveFile(dialogTitle: "Save plan as...", allowedExtensions: ['hwpf', 'txt', '*.*']).then((value) {
        if (value != null) {
          saveSavefile(path: value);
        }
      });
    }
  }

  void updateTasks({bool showMessage = false}) {
    setState(() {});
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated tasks')));
    }
  }
}
