import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/tasksystem/savefile.dart';

import '../tasksystem/taskhost.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  TaskHost? host;
  AppBar? appBar;

  void openFile() {
    FilePicker.platform
        .pickFiles(dialogTitle: 'Select a homeworkplanner plan...')
        .then((value) {
      if (value != null && value.files.single.path != null) {
        File(value.files.single.path!).readAsString().then((jsonvalue) {
          setState(() {
            host = TaskHost(saveFile: SaveFile.fromJson(jsonDecode(jsonvalue)));
            host!.saveFilePath = value.files.single.name;
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
        child: Text("File statistics\nTasks: ${host!.saveFile.Tasks.Items.length}\nLast index: ${host!.saveFile.Tasks.LastIndex}\nSubjects: ${host!.saveFile.Subjects.Items.length}"),
      ));
      List<Task> filteredTasks = TaskHost.filterRemainingTasks(host!.saveFile.Tasks.Items);
      for (var i = 0; i < filteredTasks.length; i++) {
        var item = filteredTasks[i];
        items.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(host!.getSubject(item.SubjectID) + " - " + item.Name + " - " + item.DueDate.toString()),
        ));
      }
      return ListView(
        children: items,
      );
    } else {
      return Text("Select a file!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      appBar = AppBar(
        title: Text('HomeworkPlanner'),
        actions: [
          IconButton(onPressed: openFile, icon: Icon(Icons.file_open))
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          createMenuBar(context),
          Expanded(child: getFileStatistics()),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Table(
          //         border: TableBorder.all(),
          //         defaultColumnWidth: IntrinsicColumnWidth(),
          //         children: [
          //           TableRow(children: [
          //             Text('Monday'),
          //             Text('Tuesday'),
          //             Text('Wednesday'),
          //             Text('Thursday'),
          //             Text('Friday')
          //           ])
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Row createMenuBar(BuildContext context) {
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
                    MenuItemButton(child: Text('Save')),
                    MenuItemButton(child: Text('Save as...')),
                    MenuItemButton(child: Text('Exit'))
                  ],
                ),
                SubmenuButton(menuChildren: [
                  MenuItemButton(child: Text('New...')),
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
