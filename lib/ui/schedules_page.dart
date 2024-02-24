import 'package:flutter/material.dart';
import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

class SchedulesPage extends StatefulWidget {
  final TaskHost host;

  const SchedulesPage({super.key, required this.host});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage schedules'),
        ),
        body: ListView(
          children: [
            buildPanel(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add schedule'),
              onTap: () {
                setState(() {
                  widget.host.saveFile.schedules.items.add(
                      Schedule(startTime: "00:00:00", endTime: "00:00:00"));
                });
              },
            )
          ],
        ));
  }

  Widget buildPanel() {
    List<Widget> header = List.empty(growable: true);
    List<int> daysToDisplay = List.empty(growable: true);

    header.add(const Center(
        child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Schedules'),
    )));

    List<Widget> daysOfWeekWidgets = List.empty(growable: true);
    HelperFunctions.iterateThroughWeekFromDate(
      widget.host.saveFile.schedules.daysToDisplay.toDouble(),
      HelperFunctions.getThisSaturday(),
      (day) {
        daysOfWeekWidgets.add(Center(
            child: Text(EnumConverters.weekdayToDayOfWeek(day.weekday).name)));
        daysToDisplay.add(EnumConverters.weekdayToInt(day.weekday));
      },
    );

    header.addAll(daysOfWeekWidgets.reversed.toList());

    header.add(IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                    builder: (context, setState) {
                      return SimpleDialog(
                          title: const Text('Select days of week'),
                          children: getDaysOfWeek(setState));
                    },
                  ));
        },
        icon: const Icon(Icons.date_range)));

    List<TableRow> schedules =
        [TableRow(children: header)].toList(growable: true);

    var noSubject = Subject.noSubjectTemplate();

    List<Subject> subjects = List.empty(growable: true);
    subjects.add(noSubject);
    subjects.addAll(widget.host.saveFile.subjects.items);

    schedules.addAll(widget.host.saveFile.schedules.items.map((schedule) {
      List<Widget> cols = List.empty(growable: true);
      var formKey = GlobalKey<FormState>();
      cols.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.end,
                  initialValue: schedule.shortStartTime,
                  validator: (value) =>
                      HelperFunctions.tryDurationShortStringValidation(value)
                          ? null
                          : "Incorrect time format",
                  onChanged: (value) {
                    if (formKey.currentState!.validate()) {
                      schedule.startTimeValue =
                          HelperFunctions.stringToDuration(value);
                    }
                  },
                  onEditingComplete: () => setState(() {}),
                  onTapOutside: (event) => setState(() {}),
                ),
              ),
              const Text('-'),
              Expanded(
                child: TextFormField(
                  initialValue: schedule.shortEndTime,
                  validator: (value) =>
                      HelperFunctions.tryDurationShortStringValidation(value)
                          ? null
                          : "Incorrect time format",
                  onChanged: (value) {
                    if (formKey.currentState!.validate()) {
                      schedule.endTimeValue =
                          HelperFunctions.stringToDuration(value);
                    }
                  },
                  onEditingComplete: () => setState(() {}),
                  onTapOutside: (event) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ));
      for (int index = 0; index < schedule.subjects.length; index++) {
        if (daysToDisplay.contains(index)) {
          cols.add(Padding(
            padding: const EdgeInsets.all(4.0),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.host
                    .getSubjectById(schedule.subjects[index])
                    ?.colorValue,
              ),
              items: subjects
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name),
                      ))
                  .toList(),
              value: widget.host.getSubjectById(schedule.subjects[index]) ??
                  noSubject,
              onChanged: (value) {
                setState(() {
                  schedule.subjects[index] = value?.id;
                });
              },
            ),
          ));
        }
      }
      cols.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
            onPressed: () {
              setState(() {
                widget.host.saveFile.schedules.items.remove(schedule);
              });
            },
            icon: const Icon(Icons.delete)),
      ));
      return TableRow(children: cols);
    }));

    return Table(
      columnWidths: {
        0: const IntrinsicColumnWidth(),
        header.length - 1: const IntrinsicColumnWidth()
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: schedules,
    );
  }

  List<CheckboxListTile> getDaysOfWeek(Function(void Function()) setState) {
    List<CheckboxListTile> checkboxes = List.empty(growable: true);
    var scheduleDaysOfWeek = widget.host.getValidDaysOfWeek();

    for (var i = 0; i < scheduleDaysOfWeek.length; i++) {
      checkboxes.add(CheckboxListTile(
        value: scheduleDaysOfWeek.values.elementAt(i),
        title: Text(scheduleDaysOfWeek.keys.elementAt(i)),
        onChanged: (value) {
          setState(() {});
          if (value != null && value) {
            //Get days to display, convert value to DaysToInclude, add

            widget.host.saveFile.schedules.daysToDisplay +=
                EnumConverters.daysToIncludeToInt(
                    EnumConverters.dayOfWeekToDaysToInclude(
                        EnumConverters.intToDayOfWeek(i)));
          } else {
            widget.host.saveFile.schedules.daysToDisplay -=
                EnumConverters.daysToIncludeToInt(
                    EnumConverters.dayOfWeekToDaysToInclude(
                        EnumConverters.intToDayOfWeek(i)));
          }
        },
      ));
    }

    scheduleDaysOfWeek.forEach((key, value) {});
    return checkboxes;
  }
}
