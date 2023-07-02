import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import '../models/tasksystem/task_host.dart';

class TaskEditorPage extends StatefulWidget {
  final Task task;
  final TaskHost host;
  final bool isAdding;

  const TaskEditorPage({super.key, this.isAdding = false, required this.task, required this.host});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  @override
  Widget build(BuildContext context) {
    TaskEditor builder = TaskEditor(onTaskUpdated: () => setState(() {}), setState: setState, host: widget.host);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdding ? "Create task" : (widget.task.Name != "" ? "Edit '${widget.task.Name}'" : "Edit task")),
          actions: [
            IconButton(
                onPressed: () {
                  widget.host.saveFile.Tasks.Items.remove(widget.task);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                  ScaffoldMessenger.of(context).setState(() {});
                },
                icon: const Icon(Icons.delete))
          ],
        ),
        body: ListView(
          children: builder.build(context, widget.task),
        ));
  }
}

class TaskEditor {
  final Function() onTaskUpdated;
  final Function(Function()) setState;
  bool isAdding;
  TaskHost host;

  TaskEditor({this.isAdding = false, required this.onTaskUpdated, required this.setState, required this.host});

  List<Widget> build(BuildContext context, Task task) {
    Subject noSubject = Subject.noSubjectTemplate();
    Subject editSubjects = Subject.editSubjectsTemplate();
    Subject? selectedSubject = task.SubjectID == -1 ? noSubject : (host.getSubjectById(task.SubjectID) ?? noSubject);
    List<DropdownMenuItem<Subject>>? subjectWidgets = List.empty(growable: true);
    subjectWidgets.add(DropdownMenuItem(
      value: noSubject,
      child: Text(noSubject.SubjectName),
    ));
    subjectWidgets.add(DropdownMenuItem(
      value: editSubjects,
      child: Text(editSubjects.SubjectName),
    ));
    List<DropdownMenuItem<Subject>>? subjectWidgetsObtained = host.saveFile.Subjects.Items.map<DropdownMenuItem<Subject>>(
      (e) {
        return DropdownMenuItem<Subject>(
          value: e,
          child: Text(e.toString()),
        );
      },
    ).toList();
    subjectWidgets.addAll(subjectWidgetsObtained);

    var dateTimeFormField = DateTimeField(
      decoration: const InputDecoration(
        icon: Icon(Icons.date_range),
        border: OutlineInputBorder(),
        labelText: 'Due date',
      ),
      mode: DateTimeFieldPickerMode.date,
      selectedDate: task.DueDate,
      onDateSelected: (value) {
        setState(() {
          task.DueDate = value;
        });
        onTaskUpdated();
      },
    );
    var dropdownButtonFormField = DropdownButtonFormField(
      decoration:
          const InputDecoration(icon: Icon(Icons.assignment_ind_outlined), border: OutlineInputBorder(), labelText: 'Subject'),
      items: subjectWidgets,
      value: selectedSubject,
      onChanged: (value) {
        setState(
          () {
            if (value != null) {
              task.SubjectID = value.SubjectID;
              if (value.SubjectID == editSubjects.SubjectID) {
                task.SubjectID = noSubject.SubjectID;
              }
              selectedSubject = value;
            }
          },
        );
        if (value == editSubjects) {
          SubjectsPage.show(context, host, () => setState(() {}));
        }
        onTaskUpdated();
      },
    );
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
            onTaskUpdated();
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: dropdownButtonFormField,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: dateTimeFormField,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      task.DueDate = null;
                    });
                    onTaskUpdated();
                  },
                  child: const Text('CLEAR')),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: dateTimeFormField,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      task.DueDate = null;
                    });
                    onTaskUpdated();
                  },
                  child: const Text('CLEAR')),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextFormField(
          decoration: const InputDecoration(
              icon: Icon(Icons.description_outlined), border: OutlineInputBorder(), labelText: 'Description'),
          maxLines: Platform.isAndroid ? 15 : 5,
          keyboardType: TextInputType.multiline,
          initialValue: task.Description,
          onChanged: (value) {
            setState(
              () {
                task.Description = value.trim();
              },
            );
            onTaskUpdated();
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
        child: CheckboxListTile(
          value: task.IsCompleted,
          onChanged: (value) {
            if (value != null) {
              taskCompleted(task, value);
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
              taskMarkedImportant(task, value);
            }
          },
          title: const Text('Important'),
        ),
      )
    ];
  }

  static void show(
      {required BuildContext context,
      required TaskHost host,
      required Task task,
      required Function() onTaskUpdated,
      bool isAdding = false}) {
    if (Platform.isAndroid) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskEditorPage(
              task: task,
              host: host,
              isAdding: isAdding,
            ),
          ));
    } else {
      showEditorDialog(context: context, task: task, host: host, onTaskUpdated: onTaskUpdated, isAdding: isAdding);
    }
  }

  static Future<void> showEditorDialog({
    required BuildContext context,
    required Task task,
    required TaskHost host,
    required Function() onTaskUpdated,
    bool isAdding = false,
  }) async {
    switch (await showDialog(
      context: context,
      builder: ((context) {
        return StatefulBuilder(
          builder: (context, setState) {
            TaskEditor pageBuilder = TaskEditor(onTaskUpdated: onTaskUpdated, setState: setState, host: host);
            List<Widget> dialogWidgets = List.empty(growable: true);
            dialogWidgets.addAll(pageBuilder.build(context, task));
            dialogWidgets.add(Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        host.saveFile.Tasks.Items.remove(task);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                      },
                      icon: const Icon(Icons.delete)),
                  const Spacer(),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ));

            return SimpleDialog(title: Text(isAdding ? 'Create task' : 'Edit task'), children: dialogWidgets);
          },
        );
      }),
    )) {
      default:
        onTaskUpdated();
        break;
    }
  }

  void taskCompleted(Task task, bool value) {
    setState(() {
      task.IsCompleted = value;
    });
    onTaskUpdated();
  }

  void taskMarkedImportant(Task task, bool value) {
    setState(() {
      task.IsImportant = value;
    });
    onTaskUpdated();
  }
}
