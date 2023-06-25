import 'package:flutter/material.dart';
import 'package:homeworkplanner/ui/main_page.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TaskHost host = TaskHost(saveFile: SaveFile());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(
          host: host,
        ));
  }
}
