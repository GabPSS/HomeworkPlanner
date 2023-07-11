// ignore_for_file: unused_import

import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/reports_page.dart';
import 'package:homeworkplanner/ui/schedules_page.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:intl/intl.dart';

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
  bool onMobile = false;

  @override
  void initState() {
    onMobile = widget.host.settings.mobileLayout;
    host = widget.host;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    if (onMobile) {
      appBar = buildAndroidAppBar();
      bottomNav = buildAndroidBottomNav();
      switch (bottomNavSelectedIndex) {
        case 0:
          currentPage = buildPlannerViewPanel();
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
            buildPlannerViewPanel(),
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
    List<Task> allTasks = host.saveFile.Tasks.Items
        .where((element) =>
            host.saveFile.Settings.DisplayPreviousTasks ||
            !(element.IsCompleted && element.DateCompleted!.isBefore(HelperFunctions.getToday())))
        .toList();

    List<Widget> widgets = List.empty(growable: true);
    widgets.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text("All tasks (${allTasks.where((element) => !element.IsCompleted).length})"),
    ));

    for (var i = 0; i < allTasks.length; i++) {
      widgets.add(buildTaskWidget(allTasks[i]));
    }

    return ListView(
      children: widgets,
    );
  }

  ListTile _buildTaskListTile(Task task, [bool compact = false]) {
    String taskTitle;
    if (compact) {
      taskTitle = task.toString();
    } else {
      String subjectPrefix = (Subject.isIdValid(task.SubjectID, host) ? "${host.getSubjectNameById(task.SubjectID)} - " : "");
      String dueSuffix = task.DueDate != null ? " - Due ${DateFormat.yMMMd().format(task.DueDate!)}" : "";
      taskTitle = subjectPrefix + task.toString() + dueSuffix;
    }

    return ListTile(
      leading: !compact
          ? IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                setState(() {
                  task.IsCompleted = !task.IsCompleted;
                });
              },
              icon: task.GetIcon())
          : null,
      title: Text(
        taskTitle,
        style: TextStyle(decoration: task.IsCompleted ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(!compact
          ? (task.Description != "" ? task.Description : "No description")
          : (task.DueDate != null ? "Due ${DateFormat.yMMMd().format(task.DueDate!)}" : "No due date")),
      onTap: () {
        TaskEditor.show(context: context, host: host, task: task, onTaskUpdated: updateTasks);
      },
    );
  }

  Widget buildTaskWidget(Task task, [bool compact = false]) {
    var listTile = _buildTaskListTile(task, compact);
    return host.settings.mobileLayout
        ? listTile
        : LongPressDraggable(
            data: task,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: task.GetIcon(),
            child: listTile,
            onDragStarted: () => setState(() {
              task.ExecDate = null;
              if (onMobile) {
                bottomNavSelectedIndex = 0;
              }
            }),
          );
  }

  Widget buildPlannerViewPanel() {
    List<Widget> rows = List.empty(growable: true);
    List<Widget> days = List.empty(growable: true);
    List<Widget> tmpDays;
    List<Widget> cols;

    int rowCount = host.saveFile.Settings.FutureWeeks + 1;

    DateTime selectedDay = HelperFunctions.getThisSaturday();

    for (int row = 0; row < rowCount; row++) {
      cols = List.empty(growable: true);
      tmpDays = List.empty(growable: true);

      selectedDay = HelperFunctions.iterateThroughWeekFromDate(
        host.saveFile.Settings.DaysToDisplay.toDouble(),
        selectedDay,
        (p0) {
          var dateWidget = buildTaskListForDate(p0, !onMobile);
          cols.add(dateWidget);
          tmpDays.add(dateWidget);
        },
      ).add(const Duration(days: 14));

      cols = cols.reversed.cast<Widget>().toList(growable: true);
      days.addAll(tmpDays.reversed);
      rows.add(Expanded(child: Row(children: cols)));
    }
    if (!onMobile) {
      return Expanded(flex: 2, child: Column(children: rows));
    } else {
      return Expanded(
          child: CarouselSlider(
              items: days,
              options: CarouselOptions(
                  scrollDirection: Axis.horizontal, viewportFraction: 1, height: MediaQuery.of(context).size.height)));
      // return buildTaskListForDate(HelperFunctions.getToday());
    }
  }

  Widget buildTaskListForDate(DateTime selectedDay, [bool expand = true]) {
    List<Widget> taskWidgets = List.empty(growable: true);
    List<Task> tasksForDate = host.getTasksPlannedForDate(selectedDay);
    Iterable<Task> tasksCompletedForDate = tasksForDate.where((element) => element.IsCompleted);

    bool isToday = selectedDay == HelperFunctions.getToday();
    String taskCountSuffix = isToday ? ' (${tasksCompletedForDate.length}/${tasksForDate.length})' : '';

    taskWidgets.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "${selectedDay.day}/${selectedDay.month}$taskCountSuffix",
        style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
      ),
    ));

    taskWidgets.addAll(tasksForDate.map<Widget>((task) => buildTaskWidget(task, true)).toList());

    var finalTaskListWidget = DragTarget(
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
    );
    return expand ? Expanded(child: finalTaskListWidget) : finalTaskListWidget;
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
    if (onMobile) {
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
