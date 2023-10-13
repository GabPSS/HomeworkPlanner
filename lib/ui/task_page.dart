// ignore_for_file: unused_import

import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/schedules_page.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import '../models/tasksystem/task_host.dart';

class TaskEditorPage extends StatefulWidget {
  final Task task;
  final TaskHost host;
  final bool isAdding;
  final Function()? onTaskUpdated;

  const TaskEditorPage(
      {super.key,
      this.isAdding = false,
      required this.task,
      required this.host,
      this.onTaskUpdated});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  @override
  Widget build(BuildContext context) {
    TaskEditor builder = TaskEditor(
        onTaskUpdated: widget.onTaskUpdated ?? () => setState(() {}),
        setState: setState,
        host: widget.host);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdding
              ? "Create task"
              : (widget.task.name != ""
                  ? "Edit '${widget.task.name}'"
                  : "Edit task")),
          actions: [
            IconButton(
                onPressed: () {
                  widget.host.saveFile.tasks.items.remove(widget.task);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task deleted')));
                  ScaffoldMessenger.of(context).setState(() {});
                  if (widget.onTaskUpdated != null) {
                    widget.onTaskUpdated!();
                  }
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

  TaskEditor(
      {this.isAdding = false,
      required this.onTaskUpdated,
      required this.setState,
      required this.host});

  List<Widget> build(BuildContext context, Task task) {
    Subject noSubject = Subject.noSubjectTemplate();
    Subject editSubjects = Subject.editSubjectsTemplate();

    List<DropdownMenuItem<Subject>>? subjectItems =
        getSubjectItems(noSubject, editSubjects);

    DropdownButtonFormField<Subject> subjectsDropdownWidget =
        buildSubjectsDropdown(
            subjectItems, task, editSubjects, noSubject, context);

    List<Widget> dueDateRowWidgets = buildDueDateRowWidgets(task, context);

    List<Widget> mainWidgets =
        buildMainWidgets(task, subjectsDropdownWidget, dueDateRowWidgets);
    return mainWidgets;
  }

  List<Widget> buildMainWidgets(
      Task task,
      DropdownButtonFormField<Subject> subjectsDropdownWidget,
      List<Widget> dueDateRowWidgets) {
    List<Widget> mainWidgets = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: buildNameWidget(task),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: subjectsDropdownWidget,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: dueDateRowWidgets,
        ),
      ),
    ].toList(growable: true);

    if (host.settings.mobileLayout) {
      mainWidgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: buildScheduleDateRowWidgets(task),
        ),
      ));
    }

    mainWidgets.addAll(<Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: buildDescriptionWidget(task),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
        child: buildCompletedCheckbox(task),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
        child: buildImportantCheckbox(task),
      )
    ]);
    return mainWidgets;
  }

  CheckboxListTile buildImportantCheckbox(Task task) {
    return CheckboxListTile(
      value: task.isImportant,
      onChanged: (value) {
        if (value != null) {
          taskMarkedImportant(task, value);
        }
      },
      title: const Text('Important'),
    );
  }

  CheckboxListTile buildCompletedCheckbox(Task task) {
    return CheckboxListTile(
      value: task.isCompleted,
      onChanged: (value) {
        if (value != null) {
          taskCompleted(task, value);
        }
      },
      title: const Text('Completed'),
    );
  }

  TextFormField buildDescriptionWidget(Task task) {
    return TextFormField(
      decoration: const InputDecoration(
          icon: Icon(Icons.description_outlined),
          border: OutlineInputBorder(),
          labelText: 'Description'),
      maxLines: host.settings.mobileLayout ? 15 : 5,
      keyboardType: TextInputType.multiline,
      initialValue: task.description,
      onChanged: (value) {
        setState(
          () {
            task.description = value.trim();
          },
        );
        onTaskUpdated();
      },
    );
  }

  List<Widget> buildScheduleDateRowWidgets(Task task) {
    List<Widget> scheduleDateRowWidgets = <Widget>[
      Expanded(
        child: DateTimeField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Schedule date',
              icon: Icon(Icons.schedule)),
          mode: DateTimeFieldPickerMode.date,
          selectedDate: task.execDate,
          onDateSelected: (value) {
            setState(() {
              task.execDate = value;
            });
            onTaskUpdated();
          },
        ),
      ),
    ].toList(growable: true);
    if (task.isScheduled) {
      scheduleDateRowWidgets.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
            onPressed: () {
              setState(() {
                task.execDate = null;
              });
              onTaskUpdated();
            },
            child: const Text('CLEAR')),
      ));
    }
    return scheduleDateRowWidgets;
  }

  TextFormField buildNameWidget(Task task) {
    return TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.assignment_outlined),
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
      initialValue: task.name,
      onChanged: (value) {
        setState(() {
          task.name = value.trim();
        });
        onTaskUpdated();
      },
    );
  }

  List<Widget> buildDueDateRowWidgets(Task task, BuildContext context) {
    List<Widget> dueDateRowWidgets = <Widget>[
      Expanded(
        child: buildDueDateWidget(task, context),
      ),
    ].toList(growable: true);
    if (task.subjectID != -1 && task.subjectID != -123) {
      dueDateRowWidgets.add(buildNextDateButton(task, context));
    }
    if (task.dueDate != null) {
      dueDateRowWidgets.add(buildClearDateButton(task));
    }
    return dueDateRowWidgets;
  }

  Padding buildClearDateButton(Task task) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextButton(
          onPressed: () {
            setState(() {
              task.dueDate = null;
            });
            onTaskUpdated();
          },
          child: const Text('CLEAR')),
    );
  }

  Padding buildNextDateButton(Task task, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextButton(
          onPressed: () {
            assert(task.subjectID != -1 && task.subjectID != -123);
            setState(() {
              DateTime? nextDate = host.getNextScheduledDateForSubject(
                  task.subjectID, task.dueDate ?? HelperFunctions.getToday());
              if (nextDate != null) {
                task.dueDate = nextDate;
              } else {
                showSubjectNotScheduledDialog(context);
              }
            });
            onTaskUpdated();
          },
          child: const Text('NEXT')),
    );
  }

  Future<dynamic> showSubjectNotScheduledDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subject not scheduled'),
        content: const Text(
            "Couldn't find the selected subject in the list of schedules. Try adding it, then try again."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchedulesPage(host: host),
                    ));
              },
              child: const Text('View schedules')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'))
        ],
      ),
    );
  }

  DropdownButtonFormField<Subject> buildSubjectsDropdown(
      List<DropdownMenuItem<Subject>> subjectWidgets,
      Task task,
      Subject editSubjects,
      Subject noSubject,
      BuildContext context) {
    Subject? selectedSubject = task.subjectID == -1
        ? noSubject
        : (host.getSubjectById(task.subjectID) ?? noSubject);

    return DropdownButtonFormField(
      decoration: const InputDecoration(
          icon: Icon(Icons.assignment_ind_outlined),
          border: OutlineInputBorder(),
          labelText: 'Subject'),
      items: subjectWidgets,
      value: selectedSubject,
      onChanged: (value) {
        setState(
          () {
            if (value != null) {
              task.subjectID = value.id;
              if (value.id == editSubjects.id) {
                task.subjectID = noSubject.id;
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
  }

  DateTimeField buildDueDateWidget(Task task, BuildContext context) {
    return DateTimeField(
      decoration: const InputDecoration(
        icon: Icon(Icons.date_range),
        border: OutlineInputBorder(),
        labelText: 'Due date',
      ),
      mode: DateTimeFieldPickerMode.date,
      selectedDate: task.dueDate,
      onDateSelected: (value) {
        if (host.isClassCancelled(value)) {
          showClassCancelledDialog(context, task, value);
        } else {
          setState(() {
            task.dueDate = value;
          });
        }
        onTaskUpdated();
      },
    );
  }

  Future<dynamic> showClassCancelledDialog(
      BuildContext context, Task task, DateTime value) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proceed with cancelled class date?'),
          content: const Text(
              'Class is cancelled for this date, are you sure you want to set it anyway?\nIgnore if homework is to be sent via online platforms'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    task.dueDate = value;
                  });
                },
                child: const Text('Proceed'))
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<Subject>> getSubjectItems(
      Subject noSubject, Subject editSubjects) {
    List<DropdownMenuItem<Subject>> subjectWidgets = List.empty(growable: true);

    subjectWidgets.add(DropdownMenuItem(
      value: noSubject,
      child: Text(noSubject.name),
    ));
    subjectWidgets.add(DropdownMenuItem(
      value: editSubjects,
      child: Text(editSubjects.name),
    ));
    List<DropdownMenuItem<Subject>>? subjectWidgetsObtained =
        host.saveFile.subjects.items.map<DropdownMenuItem<Subject>>(
      (e) {
        return DropdownMenuItem<Subject>(
          value: e,
          child: Text(e.toString()),
        );
      },
    ).toList();
    subjectWidgets.addAll(subjectWidgetsObtained);

    return subjectWidgets;
  }

  static void show(
      {required BuildContext context,
      required TaskHost host,
      required Task task,
      required Function() onTaskUpdated,
      bool isAdding = false}) {
    if (host.settings.mobileLayout) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskEditorPage(
              task: task,
              host: host,
              isAdding: isAdding,
              onTaskUpdated: onTaskUpdated,
            ),
          ));
    } else {
      showEditorDialog(
          context: context,
          task: task,
          host: host,
          onTaskUpdated: onTaskUpdated,
          isAdding: isAdding);
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
            TaskEditor pageBuilder = TaskEditor(
                onTaskUpdated: onTaskUpdated, setState: setState, host: host);
            List<Widget> dialogWidgets = List.empty(growable: true);
            dialogWidgets.addAll(pageBuilder.build(context, task));
            dialogWidgets.add(Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        host.saveFile.tasks.items.remove(task);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted')));
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

            return SimpleDialog(
                title: Text(isAdding ? 'Create task' : 'Edit task'),
                children: dialogWidgets);
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
      task.isCompleted = value;
    });
    onTaskUpdated();
  }

  void taskMarkedImportant(Task task, bool value) {
    setState(() {
      task.isImportant = value;
    });
    onTaskUpdated();
  }
}
