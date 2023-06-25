import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import '../models/tasksystem/taskhost.dart';

class TaskEditorPage extends StatefulWidget {
  Task task;
  TaskHost host;

  TaskEditorPage({super.key, required this.task, required this.host});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState(task: task, host: host);
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  Task task;
  TaskHost host;

  _TaskEditorPageState({required this.task, required this.host});

  @override
  Widget build(BuildContext context) {
    TaskEditor builder = TaskEditor(onTaskCompleted: taskCompleted, onTaskMarkedImportant: taskMarkedImportant, setState: setState, host: host);

    return Scaffold(
        appBar: AppBar(
          title: Text("Editing \"${task.toString()}\""),
          actions: [
            IconButton(
                onPressed: () {
                  host.saveFile.Tasks.Items.remove(task);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                  ScaffoldMessenger.of(context).setState(() {});
                },
                icon: const Icon(Icons.delete))
          ],
        ),
        body: ListView(
          children: builder.build(task),
        ));
  }

  void taskCompleted(Task task, bool value, Function(Function()) setState) {
    setState(() {
      task.IsCompleted = value;
    });
  }

  void taskMarkedImportant(Task task, bool value, Function(Function()) setState) {
    setState(() {
      task.IsImportant = value;
    });
  }
}

class TaskEditor {
  final Function(Task, bool, Function(Function())) onTaskCompleted;
  final Function(Task, bool, Function(Function())) onTaskMarkedImportant;
  final Function(Function()) setState;
  TaskHost? host;

  TaskEditor({required this.onTaskCompleted, required this.onTaskMarkedImportant, required this.setState, required this.host});

  List<Widget> build(Task task) {
    Subject noSubject = Subject.getNoSubject();
    Subject? selectedSubject = task.SubjectID == -1 ? noSubject : host!.getSubjectById(task.SubjectID);
    List<DropdownMenuItem<Subject>>? subjectWidgets = List.empty(growable: true);
    subjectWidgets.add(DropdownMenuItem(
      child: Text(noSubject.SubjectName),
      value: noSubject,
    ));
    List<DropdownMenuItem<Subject>>? subjectWidgetsObtained = host?.saveFile.Subjects.Items.map<DropdownMenuItem<Subject>>(
      (e) {
        return DropdownMenuItem<Subject>(
          value: e,
          child: Text(e.toString()),
        );
      },
    ).toList();
    if (subjectWidgetsObtained != null) {
      subjectWidgets.addAll(subjectWidgetsObtained);
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.assignment_outlined),
            border: OutlineInputBorder(),
            labelText: 'Name',
          ),
          initialValue: task.Name,
          onChanged: (value) {
            setState(() {
              task.Name = value.trim();
            });
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: DropdownButtonFormField(
          decoration: const InputDecoration(icon: Icon(Icons.assignment_ind_outlined), border: OutlineInputBorder(), labelText: 'Subject'),
          items: subjectWidgets,
          value: selectedSubject,
          onChanged: (value) {
            setState(
              () {
                if (value != null) {
                  task.SubjectID = value.SubjectID;
                  selectedSubject = value;
                }
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          decoration: const InputDecoration(icon: Icon(Icons.description_outlined), border: OutlineInputBorder(), labelText: 'Description'),
          maxLines: Platform.isAndroid ? 15 : 5,
          keyboardType: TextInputType.multiline,
          initialValue: task.Description,
          onChanged: (value) {
            setState(
              () {
                task.Description = value.trim();
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
        child: CheckboxListTile(
          value: task.IsCompleted,
          onChanged: (value) {
            if (value != null) {
              onTaskCompleted(task, value, setState);
            }
          },
          title: const Text('Completed'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
        child: CheckboxListTile(
          value: task.IsImportant,
          onChanged: (value) {
            if (value != null) {
              onTaskMarkedImportant(task, value, setState);
            }
          },
          title: const Text('Important'),
        ),
      )
    ];
  }
}
