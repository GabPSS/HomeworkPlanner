import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/day_note.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

class NoteDialog {
  TaskHost host;
  DayNote? note;
  bool _isAdding = false;
  Function()? onUpdate;

  NoteDialog(this.host, {this.note, this.onUpdate}) {
    if (note == null) {
      _isAdding = true;
    }
  }

  void show(BuildContext context) {
    if (_isAdding) {
      note = DayNote(Date: HelperFunctions.getToday(), Message: "");
    }
    showDialog(
      context: context,
      builder: (context) {
        var addButton = TextButton(
            onPressed: () {
              if (_isAdding) {
                host.saveFile.DayNotes.add(note!);
              }
              Navigator.pop(context);
              update();
            },
            child: const Text('Add'));
        var dialogButtons = [
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
              child: Text(_isAdding ? 'Cancel' : 'Close'))
        ].toList(growable: true);
        if (_isAdding) dialogButtons.add(addButton);

        return SimpleDialog(
          title: Text(_isAdding ? 'Add note' : 'Edit note'),
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
                            'Prevents tasks from being added to this day'),
                        onChanged: (value) => setState(() {
                          note!.Cancelled = value ?? false;
                          update();
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Row(
                        children: dialogButtons,
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

  void update() {
    if (onUpdate != null) {
      onUpdate!();
    }
  }
}
