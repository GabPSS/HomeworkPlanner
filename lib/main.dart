import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  String textContent = "Null";

  String getJSON(String contents) {
    //TODO: Remove JSON tests
    TaskHost newHost =
        TaskHost(saveFile: SaveFile.fromJson(jsonDecode(contents)));
    return newHost.saveFile.Tasks.Items.length.toString();
  }

  void getSaveFile() {
    //TODO: Remove this savefile opening function

    FilePicker.platform.pickFiles(type: FileType.any).then((result) {
      if (result != null && result.files.single.path != null) {
        File(result.files.single.path!).readAsString().then((value) {
          var returning = getJSON(value);
          setState(() {
            textContent = returning;
          });
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue), home: Scaffold(
      body: Column(children: [
        Text(textContent), //TODO: Remove JSON test
        ElevatedButton(onPressed: getSaveFile, child: const Text('Buscar arquivo')),
      ]),
    ));
  } 
}
