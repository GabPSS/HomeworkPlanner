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
      note = DayNote(Date: HelperFunctions.getToday(), Message: "");
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
                            note!.Date = value;
                          });
                          update();
                        },
                        mode: DateTimeFieldPickerMode.date,
                        selectedDate: note!.Date),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            icon: Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                            labelText: 'Description'),
                        initialValue: note!.Message,
                        maxLines: 3,
                        onChanged: (value) {
                          note!.Message = value;
                          update();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 0, 0),
                      child: CheckboxListTile(
                        value: note!.Cancelled,
                        title: const Text('Cancel day'),
                        subtitle: const Text(
                            'Prevents tasks from being added to this day in planning'),
                        onChanged: (value) => setState(() {
                          note!.Cancelled = value ?? false;
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
                        onChanged: (value) => setState(() {
                          if (value ?? false) {
                            List<Task> tasksByDueDate = host
                                .getTasksByDueDate(note!.Date)
                                .where((element) => !element.IsCompleted)
                                .toList();
                            if (tasksByDueDate.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  var dialogContentWidgets = <Widget>[
                                    const Text(
                                        'Cancelling this day will affect the following tasks\' due dates:\n(Select all that apply)')
                                  ];
                                  dialogContentWidgets.addAll(
                                      tasksByDueDate.map((e) => TaskWidget(
                                          host: host,
                                          task: e))); //TODO: Stopped here
                                  return AlertDialog(
                                    title: const Text(
                                        'Select tasks to reschedule'),
                                    content:
                                        Column(children: dialogContentWidgets),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK')),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                          note!.noClass = value ?? false;
                          update();
                        }),
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

  List<Widget> buildBottomRowButtons(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            host.saveFile.DayNotes.remove(note);
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
            host.saveFile.DayNotes.add(note!);
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
