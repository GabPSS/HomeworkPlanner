import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/day_note.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:homeworkplanner/ui/task_widget.dart';

class NoteDialog {
  TaskHost host;
  DayNote? note;
  bool _isNoteBeingAdded = false;
  Function()? onUpdate;

  NoteDialog(this.host, {this.note, this.onUpdate}) {
    if (note == null) {
      _isNoteBeingAdded = true;
    }
  }

  void show(BuildContext context) {
    if (_isNoteBeingAdded) {
      note = DayNote(date: HelperFunctions.getToday(), message: "");
    }
    showDialog(
      context: context,
      builder: (context) {
        TextButton addButton = buildAddButton(context);
        List<Widget> bottomDialogButtons =
            buildBottomRowButtons(context).toList(growable: true);
        if (_isNoteBeingAdded) bottomDialogButtons.add(addButton);

        return SimpleDialog(
          title: Text(_isNoteBeingAdded ? 'Add note' : 'Edit note'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: StatefulBuilder(
                builder: (context, setState) {
                  var content = [
                    DateTimeField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date',
                            icon: Icon(Icons.date_range)),
                        onDateSelected: (value) {
                          setState(() {
                            note!.date = value;
                          });
                          update();
                        },
                        mode: DateTimeFieldPickerMode.date,
                        selectedDate: note!.date),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            icon: Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                            labelText: 'Description'),
                        initialValue: note!.message,
                        maxLines: 3,
                        onChanged: (value) {
                          note!.message = value;
                          update();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 0, 0),
                      child: CheckboxListTile(
                        value: note!.cancelled,
                        title: const Text('Cancel day'),
                        subtitle: const Text(
                            'Prevents tasks from being added to this day in planning'),
                        onChanged: (value) => setState(() {
                          note!.cancelled = value ?? false;
                          update();
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                      child: CheckboxListTile(
                        value: note!.noClass,
                        title: const Text('Class canceled'),
                        subtitle: const Text(
                            'Prevents due dates from being set to this day'),
                        onChanged: (value) async {
                          if (value ?? false) {
                            List<Task> tasksByDueDate = host
                                .getTasksByDueDate(note!.date)
                                .where((element) => !element.isCompleted)
                                .toList();

                            if (tasksByDueDate.isNotEmpty) {
                              List<Task>? result = await showCancellingDialog(
                                  context, tasksByDueDate);
                              if (result != null) {
                                for (int i = 0; i < result.length; i++) {
                                  host.rescheduleDueDates(result);
                                }
                                note!.noClass = value ?? false;
                                setState(() {});
                                update();
                              }
                              return;
                            }
                          }
                          note!.noClass = value ?? false;
                          update();
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Row(
                        children: bottomDialogButtons,
                      ),
                    )
                  ];
                  return Column(children: content);
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<List<Task>?> showCancellingDialog(
      BuildContext context, List<Task> tasksByDueDate) {
    return showDialog<List<Task>>(
      context: context,
      builder: (context) {
        List<Task> selectedTasks = List.empty(growable: true);
        return StatefulBuilder(builder: (context, setState) {
          List<Widget> dialogContentWidgets = <Widget>[
            const Text(
                'Cancelling this day will affect the following tasks\' due dates:\n(Select all that apply)')
          ];

          dialogContentWidgets.addAll(
            tasksByDueDate.map(
              (task) => TaskWidget(
                selectionStyle: true,
                denyDragging: true,
                isSelected: selectedTasks.contains(task),
                onSelected: (value) {
                  return setState(
                    () {
                      if (value ?? false) {
                        selectedTasks.add(task);
                      } else {
                        selectedTasks.remove(task);
                      }
                    },
                  );
                },
                host: host,
                task: task,
              ),
            ),
          );

          return AlertDialog(
              title: const Text('Select tasks to reschedule'),
              content: Column(children: dialogContentWidgets),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, selectedTasks),
                    child: const Text('OK'))
              ]);
        });
      },
    );
  }

  List<Widget> buildBottomRowButtons(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            host.saveFile.dayNotes.remove(note);
            Navigator.pop(context);
            update();
          },
          icon: const Icon(Icons.delete)),
      const Spacer(),
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(_isNoteBeingAdded ? 'Cancel' : 'Close'))
    ];
  }

  TextButton buildAddButton(BuildContext context) {
    return TextButton(
        onPressed: () {
          if (_isNoteBeingAdded) {
            host.saveFile.dayNotes.add(note!);
          }
          Navigator.pop(context);
          update();
        },
        child: const Text('Add'));
  }

  void update() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }
}
