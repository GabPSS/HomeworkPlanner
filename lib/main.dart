import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/lists/ScheduleList.dart';
import 'package:homeworkplanner/models/lists/subjectlist.dart';
import 'package:homeworkplanner/models/lists/tasklist.dart';
import 'package:homeworkplanner/tasksystem/savefile.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  String GetJSON() {
    SaveFile sfile = SaveFile();
    return jsonEncode(sfile.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text(GetJSON()),
          ]
        ),
      ),
    );
  }
}
