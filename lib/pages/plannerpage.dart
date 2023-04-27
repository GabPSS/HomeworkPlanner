import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/task.dart';
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

  //TODO: Remove placeholder method and corresponding UI artifacts
  Widget getFileStatistics() {
    if (host != null) {
      List<Widget> items = List.empty(growable: true);
      items.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
            // "File statistics\nTasks: ${host!.saveFile.Tasks.Items.length}\nLast index: ${host!.saveFile.Tasks.LastIndex}\nSubjects: ${host!.saveFile.Subjects.Items.length}"),
            "All tasks"),
      ));

      List<Task> filteredTasks =
          TaskHost.filterRemainingTasks(host!.saveFile.Tasks.Items);

      for (var i = 0; i < filteredTasks.length; i++) {
        var item = filteredTasks[i];
        items.add(ListTile(
          leading: item.GetIcon(),
          title:
              Text(host!.getSubject(item.SubjectID) + " - " + item.toString()),
          subtitle: Text("Due: " + item.DueDate.toString()),
          onTap: () {
            showTaskPageOrDialog(item);
          },
        ));
      }

      return ListView(
        children: items,
      );
    } else {
      return Text("Select a file!");
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
                setState: setState);
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
                              SnackBar(content: Text('Task deleted')));
                        }
                      },
                      icon: Icon(Icons.delete)),
                  Spacer(),
                  OutlinedButton(
                    child: Row(
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
                title: Text('Editing task'), children: dialogWidgets);
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
    if (Platform.isAndroid) {
      appBar = buildAndroidAppBar();
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createTask();
        },
        child: Icon(Icons.assignment_add),
      ),
      body: Column(
        children: [
          buildMenuBar(context),
          // Expanded(child: getFileStatistics()),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: getPlannerViewWidget(),
                ),
                Expanded(
                  child: getFileStatistics(),
                  flex: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column getPlannerViewWidget() {
    if (host != null) {
      List<Widget> Rows = List.empty(growable: true);
      List<Widget> Cols;

      int colCount = HelperFunctions.getDayCount(host!.saveFile.Settings.DaysToDisplay);
      int rowCount = host!.saveFile.Settings.FutureWeeks + 1;

      DateTime selectedDay = HelperFunctions.getSunday(DateTime.now()).add(Duration(days: 6));
      for (int row = 0; row < rowCount; row++) {
        Cols = List.empty(growable: true);

        int col = colCount - 1;
        double DaysToDisplayData = host!.saveFile.Settings.DaysToDisplay.toDouble();

        for (double i = 64; i >= 1; i /= 2) {
          if (DaysToDisplayData - i >= 0) {
            // PlanningDayPanel control = new PlanningDayPanel(selectedDay, TaskHost);
            // control.ControlMouseDown += TaskControl_MouseDown;
            // control.ControlMouseUp += TaskControl_MouseUp;
            // control.ControlMouseMove += TaskControl_MouseMove;
            // control.CancelledDayClick += PlanningDay_CancelledDayClick;
            // PlanningPanel.Controls.Add(control, col, row);
            Cols.add(Expanded(child: Text(selectedDay.day.toString())));
            DaysToDisplayData -= i;
            col--;
          }
          selectedDay = selectedDay.add(Duration(days: -1));
          // selectedDay = selectedDay.Subtract(TimeSpan.FromDays(1));
        }
        Cols = Cols.reversed.cast<Widget>().toList(growable: true);
        Rows.add(Expanded(child: Row(children: Cols)));
        selectedDay = selectedDay.add(Duration(days: 14));
      }

      return Column(
        children: Rows
      );
    } else {
      throw new UnimplementedError('Case not analysed yet');
    }
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
      title: Text('HomeworkPlanner'),
      actions: [
        IconButton(onPressed: openFile, icon: Icon(Icons.file_open)),
        IconButton(onPressed: saveSavefile, icon: Icon(Icons.save)),
        IconButton(onPressed: updateEverything, icon: Icon(Icons.refresh))
      ],
    );
  }

  void updateEverything({bool showMessage = false}) {
    setState(() {});
    if (showMessage) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Updated tasks')));
    }
  }

  Row buildMenuBar(BuildContext context) {
    if (Platform.isAndroid) {
      return Row();
    } else {
      return Row(
        children: [
          Expanded(
            child: MenuBar(
              children: [
                SubmenuButton(
                  child: Text('File'),
                  menuChildren: [
                    MenuItemButton(
                      child: Text('New'),
                      onPressed: createSaveFile,
                    ),
                    MenuItemButton(
                      child: Text('Open...'),
                      onPressed: openFile,
                    ),
                    MenuItemButton(
                      child: Text('Import...'),
                    ),
                    SubmenuButton(
                        menuChildren: [], child: Text('Recent files')),
                    MenuItemButton(
                        child: Text('Save'), onPressed: saveSavefile),
                    MenuItemButton(
                      child: Text('Save as...'),
                      onPressed: saveAs,
                    ),
                    MenuItemButton(child: Text('Exit'))
                  ],
                ),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                    child: Text('New...'),
                    onPressed: createTask,
                  ),
                  MenuItemButton(child: Text('Import...')),
                  SubmenuButton(menuChildren: [
                    MenuItemButton(child: Text('Remaining only')),
                    MenuItemButton(child: Text('Everything')),
                  ], child: Text('Unschedule tasks')),
                  SubmenuButton(menuChildren: [
                    MenuItemButton(child: Text('Completed')),
                    MenuItemButton(child: Text('Everything'))
                  ], child: Text('Remove tasks'))
                ], child: Text('Tasks')),
                SubmenuButton(menuChildren: [
                  MenuItemButton(child: Text('Day notes...')),
                  MenuItemButton(child: Text('Report...')),
                  MenuItemButton(child: Text('Subjects...')),
                  MenuItemButton(child: Text('Clean up...')),
                  MenuItemButton(child: Text('Manage schedules...')),
                ], child: Text('Tools')),
                SubmenuButton(menuChildren: [
                  MenuItemButton(child: Text('Get help...')),
                  MenuItemButton(
                    child: Text('About...'),
                    onPressed: () {
                      showAboutDialog(
                          context: context,
                          applicationName: 'HomeworkPlanner',
                          applicationLegalese: '(C) Gabriel P. 2023');
                    },
                  )
                ], child: Text('About'))
              ],
            ),
          ),
        ],
      );
    }
  }
}
