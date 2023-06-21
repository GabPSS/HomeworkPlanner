import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/pages/subjectspage.dart';
import 'package:homeworkplanner/pages/taskpage.dart';
import 'package:homeworkplanner/tasksystem/savefile.dart';

import '../tasksystem/taskhost.dart';

class PlannerPage extends StatefulWidget {
  TaskHost? host;

  PlannerPage({super.key, this.host});

  @override
  State<PlannerPage> createState() => _PlannerPageState(host: host);
}

class _PlannerPageState extends State<PlannerPage> {
  TaskHost? host;
  AppBar? appBar;
  BottomNavigationBar? bottomNav;
  int bottomNavSelectedIndex = 0;

  _PlannerPageState({this.host});

  void openFile() {
    FilePicker.platform
        .pickFiles(dialogTitle: 'Select a homeworkplanner plan...')
        .then((value) {
      if (value != null && value.files.single.path != null) {
        File(value.files.single.path!).readAsString().then((jsonvalue) {
          setState(() {
            host = TaskHost(saveFile: SaveFile.fromJson(jsonDecode(jsonvalue)));
            host!.saveFilePath = value.files.single.path;
          });
        });
      }
    });
  }

  Widget getAllTasksPanel() {
    if (host != null) {
      List<Widget> items = List.empty(growable: true);
      items.add(const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text("All tasks"),
      ));

      List<Task> allTasks = host!.saveFile.Tasks.Items
          .where((element) =>
              host!.saveFile.Settings.DisplayPreviousTasks ||
              !(element.IsCompleted &&
                  element.DateCompleted!.isBefore(HelperFunctions.getToday())))
          .toList();

      for (var i = 0; i < allTasks.length; i++) {
        var task = allTasks[i];
        Widget itemTile = ListTile(
          leading: IconButton(
              onPressed: () {
                setState(() {
                  task.IsCompleted = !task.IsCompleted;
                });
              },
              icon: task.GetIcon()),
          title: Text((task.SubjectID != -1
                  ? "${host!.getSubject(task.SubjectID)} - "
                  : "") +
              task.toString()),
          subtitle: Text("Due: ${task.DueDate}"),
          onTap: () {
            showTaskPageOrDialog(task);
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
    } else {
      return const Text("Select a file!");
    }
  }

  void showTaskPageOrDialog(Task item) {
    if (Platform.isAndroid) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskPage(task: item, host: host!),
          ));
    } else {
      _showTaskDialog(item);
    }
  }

  Future<void> _showTaskDialog(Task task) async {
    switch (await showDialog(
      context: context,
      builder: ((context) {
        return StatefulBuilder(
          builder: (context, setState) {
            TaskPageBuilder pageBuilder = TaskPageBuilder(
                onTaskCompleted: taskCompleted,
                onTaskMarkedImportant: taskMarkedImportant,
                setState: setState,
                host: host);
            List<Widget> dialogWidgets = List.empty(growable: true);
            dialogWidgets.addAll(pageBuilder.buildPageContent(task));
            dialogWidgets.add(Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (host != null) {
                          host?.saveFile.Tasks.Items.remove(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task deleted')));
                        }
                      },
                      icon: const Icon(Icons.delete)),
                  const Spacer(),
                  OutlinedButton(
                    child: const Row(
                      children: [Icon(Icons.check), Text('OK')],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ));

            return SimpleDialog(
                title: const Text('Editing task'), children: dialogWidgets);
          },
        );
      }),
    )) {
      default:
        updateEverything();
        break;
    }
  }

  void taskCompleted(Task task, bool value, Function(Function())? setState) {
    if (setState != null) {
      setState(() {
        task.IsCompleted = value;
      });
      updateEverything();
    }
  }

  void taskMarkedImportant(
      Task task, bool value, Function(Function())? setState) {
    if (setState != null) {
      setState(() {
        task.IsImportant = value;
      });
      updateEverything();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    if (Platform.isAndroid) {
      appBar = buildAndroidAppBar();
      bottomNav = BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: "Planner"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined), label: 'Tasks')
        ],
        currentIndex: bottomNavSelectedIndex,
        onTap: (value) {
          setState(() {
            bottomNavSelectedIndex = value;
          });
        },
      );
      switch (bottomNavSelectedIndex) {
        case 0:
          currentPage = Expanded(child: getPlannerViewWidget());
          break;
        case 1:
          currentPage = Expanded(child: getAllTasksPanel());
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
              child: getPlannerViewWidget(),
            ),
            Expanded(
              flex: 1,
              child: getAllTasksPanel(),
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
        children: [
          buildDesktopMenuBar(context),
          // Expanded(child: getFileStatistics()),
          currentPage
        ],
      ),
    );
  }

  Column getPlannerViewWidget() {
    if (host != null) {
      List<Widget> Rows = List.empty(growable: true);
      List<Widget> Cols;

      int colCount =
          HelperFunctions.getDayCount(host!.saveFile.Settings.DaysToDisplay);
      int rowCount = host!.saveFile.Settings.FutureWeeks + 1;

      DateTime selectedDay = HelperFunctions.getSunday(DateTime.now())
          .add(const Duration(days: 6));
      for (int row = 0; row < rowCount; row++) {
        Cols = List.empty(growable: true);

        int col = colCount - 1;
        double DaysToDisplayData =
            host!.saveFile.Settings.DaysToDisplay.toDouble();

        for (double i = 64; i >= 1; i /= 2) {
          if (DaysToDisplayData - i >= 0) {
            Cols.add(getTaskListForADay(selectedDay));
            DaysToDisplayData -= i;
            col--;
          }
          selectedDay = selectedDay.add(const Duration(days: -1));
          // selectedDay = selectedDay.Subtract(TimeSpan.FromDays(1));
        }
        Cols = Cols.reversed.cast<Widget>().toList(growable: true);
        Rows.add(Expanded(child: Row(children: Cols)));
        selectedDay = selectedDay.add(const Duration(days: 14));
      }

      return Column(children: Rows);
    } else {
      throw UnimplementedError('Case not analysed yet');
    }
  }

  Widget getTaskListForADay(DateTime selectedDay) {
    List<Widget> taskWidgets = List.empty(growable: true);
    taskWidgets.add(Text("${selectedDay.day}/${selectedDay.month}"));
    if (host != null) {
      List<Task> tasksForDate = host!.getTasksPlannedForDate(selectedDay);

      taskWidgets.addAll(tasksForDate
          .map<ListTile>((e) => ListTile(
                title: Text(e.toString()),
                subtitle: Text(e.DueDate != Task.minimumDateTime
                    ? "Due ${e.DueDate.toString()}"
                    : "No due date"),
              ))
          .toList());
    }
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
            data.ExecDate =
                DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          }
        });
      },
    ));
  }

  void createTask() {
    Task task = Task();
    host!.saveFile.Tasks.Add(task);
    showTaskPageOrDialog(task);
  }

  void createSaveFile() {
    setState(() {
      host = TaskHost(saveFile: SaveFile());
    });
  }

  void saveSavefile({String? path, bool noRetry = false}) {
    path = path ?? (host != null ? host!.saveFilePath : null);
    if (path != null) {
      if (host != null) {
        try {
          host!.saveFilePath = path;
          String jsonData = jsonEncode(host!.saveFile.toJson());
          File(path).writeAsString(jsonData);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('File saved at ' + path)));
        } catch (e) {
          if (!noRetry) {
            saveAs(noRetry: true);
          } else {
            //TODO: Implement an alert dialog with some options
            throw new UnimplementedError("Alert dialog not implemented here");
          }
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
      FilePicker.platform.saveFile(
          dialogTitle: "Save plan as...",
          allowedExtensions: ['hwpf', 'txt', '*.*']).then((value) {
        if (value != null) {
          saveSavefile(path: value);
        }
      });
    }
  }

  AppBar buildAndroidAppBar() {
    return AppBar(
      title: const Text('HomeworkPlanner'),
      actions: [
        IconButton(onPressed: openFile, icon: const Icon(Icons.file_open)),
        IconButton(onPressed: saveSavefile, icon: const Icon(Icons.save)),
        IconButton(onPressed: updateEverything, icon: const Icon(Icons.refresh))
      ],
    );
  }

  void updateEverything({bool showMessage = true}) {
    setState(() {});
    if (showMessage) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Updated tasks')));
    }
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
                    const SubmenuButton(
                        menuChildren: [], child: Text('Recent files')),
                    MenuItemButton(
                        onPressed: saveSavefile,
                        child: const Text('Save')),
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
                  const SubmenuButton(menuChildren: [
                    MenuItemButton(child: Text('Completed')),
                    MenuItemButton(child: Text('Everything'))
                  ], child: Text('Remove tasks'))
                ], child: const Text('Tasks')),
                SubmenuButton(menuChildren: [
                  const MenuItemButton(child: Text('Day notes...')),
                  const MenuItemButton(child: Text('Report...')),
                  MenuItemButton(
                    child: const Text('Subjects...'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubjectsPage(
                              host: host!,
                            ),
                          ));
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
                          context: context,
                          applicationName: 'HomeworkPlanner',
                          applicationLegalese: '(C) Gabriel P. 2023');
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
}
