
import 'package:flutter/material.dart';
import 'package:homeworkplanner/pages/plannerpage.dart';
import 'package:homeworkplanner/tasksystem/savefile.dart';
import 'package:homeworkplanner/tasksystem/taskhost.dart';

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
        home: PlannerPage(host: host,)
    );
  } 
}
