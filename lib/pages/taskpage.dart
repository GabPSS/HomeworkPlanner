import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homeworkplanner/models/main/task.dart';

class TaskPage extends StatefulWidget {
  Task task;

  TaskPage({super.key, required this.task});

  @override
  State<TaskPage> createState() => _TaskPageState(task: task);
}

class _TaskPageState extends State<TaskPage> {
  Task task;

  _TaskPageState({required this.task});

  @override
  Widget build(BuildContext context) {
    String desc = "";
    for (var i = 0; i < task.Description.length; i++) {
      desc += task.Description[i];
      if (i != task.Description.length - 1) {
        desc += "\n";
      }
    }

    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Editing \"${task.Name}\""),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.assignment_outlined),
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
              initialValue: task.Name,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                  icon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  labelText: 'Description'),
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              initialValue: desc,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
            child: CheckboxListTile(
              value: task.IsCompleted,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    task.IsCompleted = value;
                  });
                }
              },
              title: Text('Completed'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
            child: CheckboxListTile(
              value: task.IsImportant,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    task.IsImportant = value;
                  });
                }
              },
              title: Text('Important'),
            ),
          )
        ]),
      );
    } else {
      throw new UnimplementedError(
          "The Windows or desktop platform dialog has not been implemented yet");
    }
  }
}
