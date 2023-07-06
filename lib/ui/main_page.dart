import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/reports_page.dart';
import 'package:homeworkplanner/ui/schedules_page.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';

import '../models/tasksystem/task_host.dart';

class MainPage extends StatefulWidget {
  final TaskHost host;

  const MainPage({super.key, required this.host});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late TaskHost host;
  AppBar? appBar;
  BottomNavigationBar? bottomNav;
  int bottomNavSelectedIndex = 0;

  @override
  void initState() {
    host = widget.host;
    super.initState();
  }

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
        title: Text((task.SubjectID != -1 && subjectName != null ? "$subjectName - " : "") + task.toString()),
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
      title: Text(HelperFunctions.getFileNameFromPath(host.saveFilePath ?? "Untitled plan")),
      actions: [
        IconButton(onPressed: () => host.save(context), icon: const Icon(Icons.save)),
        IconButton(onPressed: updateTasks, icon: const Icon(Icons.refresh))
      ],
    );
  }

  BottomNavigationBar buildAndroidBottomNav() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Planner"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Tasks')
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
      List<MenuItemButton> recentFilesList = host.settings.recentFiles
          .map((e) => MenuItemButton(
                child: Text(HelperFunctions.getFileNameFromPath(e)),
                onPressed: () => TaskHost.openFile(context, host.settings, (newHost) => setState(() => host = newHost), e),
              ))
          .toList()
          .reversed
          .toList();
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
                    SubmenuButton(menuChildren: recentFilesList, child: const Text('Recent files')),
                    MenuItemButton(onPressed: () => setState(() => host.save(context)), child: const Text('Save')),
                    MenuItemButton(onPressed: () => setState(() => host.saveAs(context)), child: const Text('Save as...')),
                    MenuItemButton(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
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
                  MenuItemButton(
                      child: const Text('Report...'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportsPage(host: host),
                          ))),
                  MenuItemButton(
                    child: const Text('Subjects...'),
                    onPressed: () {
                      SubjectsPage.show(context, host, updateTasks);
                    },
                  ),
                  const MenuItemButton(child: Text('Clean up...')),
                  MenuItemButton(
                    child: const Text('Manage schedules...'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchedulesPage(
                              host: host,
                            ),
                          ));
                    },
                  ),
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

  void createSaveFile() => setState(() => host = TaskHost(settings: host.settings, saveFile: SaveFile()));

  void openFile() => TaskHost.openFile(context, host.settings, (newHost) => setState(() => host = newHost));

  void updateTasks({bool showMessage = false}) {
    setState(() {});
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated tasks')));
    }
  }
}
