import 'package:flutter/material.dart';
import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

class SchedulesPage extends StatefulWidget {
  TaskHost host;

  SchedulesPage({super.key, required this.host});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Manage schedules'),
        ),
        body: ListView(
          children: [
            buildPanel(),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add schedule'),
              onTap: () {
                setState(() {
                  widget.host.saveFile.Schedules.Items.add(Schedule(StartTime: "00:00:00", EndTime: "00:00:00"));
                });
              },
            )
          ],
        ));
  }

  Widget buildPanel() {
    List<Widget> header = List.empty(growable: true);
    List<int> daysToDisplay = List.empty(growable: true);

    header.add(Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Schedules'),
    )));

    List<Widget> daysOfWeekWidgets = List.empty(growable: true);
    HelperFunctions.iterateThroughWeekFromDate(
      widget.host.saveFile.Schedules.DaysToDisplay.toDouble(),
      HelperFunctions.getThisSaturday(),
      (day) {
        daysOfWeekWidgets.add(Center(child: Text(EnumConverters.weekdayToDayOfWeek(day.weekday).name)));
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
                      return SimpleDialog(title: Text('Select days of week'), children: getDaysOfWeek(setState));
                    },
                  ));
        },
        icon: Icon(Icons.date_range)));

    List<TableRow> schedules = [TableRow(children: header)].toList(growable: true);

    var noSubject = Subject.noSubjectTemplate();

    List<Subject> subjects = List.empty(growable: true);
    subjects.add(noSubject);
    subjects.addAll(widget.host.saveFile.Subjects.Items);

    schedules.addAll(widget.host.saveFile.Schedules.Items.map((schedule) {
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
                      HelperFunctions.tryDurationShortStringValidation(value) ? null : "Incorrect time format",
                  onChanged: (value) {
                    if (formKey.currentState!.validate()) {
                      schedule.startTime = HelperFunctions.stringToDuration(value);
                    }
                  },
                  onEditingComplete: () => setState(() {}),
                  onTapOutside: (event) => setState(() {}),
                ),
              ),
              Text('-'),
              Expanded(
                child: TextFormField(
                  initialValue: schedule.shortEndTime,
                  validator: (value) =>
                      HelperFunctions.tryDurationShortStringValidation(value) ? null : "Incorrect time format",
                  onChanged: (value) {
                    if (formKey.currentState!.validate()) {
                      schedule.endTime = HelperFunctions.stringToDuration(value);
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
      for (int index = 0; index < schedule.Subjects.length; index++) {
        if (daysToDisplay.contains(index)) {
          cols.add(Padding(
            padding: const EdgeInsets.all(4.0),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.host.getSubjectById(schedule.Subjects[index])?.SubjectColorValue,
              ),
              items: subjects
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject.SubjectName),
                      ))
                  .toList(),
              value: widget.host.getSubjectById(schedule.Subjects[index]) ?? noSubject,
              onChanged: (value) {
                setState(() {
                  schedule.Subjects[index] = value?.SubjectID;
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
                widget.host.saveFile.Schedules.Items.remove(schedule);
              });
            },
            icon: Icon(Icons.delete)),
      ));
      return TableRow(children: cols);
    }));

    return Table(
      columnWidths: {0: IntrinsicColumnWidth(), header.length - 1: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: schedules,
    );
  }

  List<CheckboxListTile> getDaysOfWeek(Function(void Function()) setState) {
    List<CheckboxListTile> checkboxes = List.empty(growable: true);
    var scheduleDaysOfWeek = widget.host.getScheduleDaysOfWeek();

    for (var i = 0; i < scheduleDaysOfWeek.length; i++) {
      checkboxes.add(CheckboxListTile(
        value: scheduleDaysOfWeek.values.elementAt(i),
        title: Text(scheduleDaysOfWeek.keys.elementAt(i)),
        onChanged: (value) {
          setState(() {});
          if (value != null && value) {
            //Get days to display, convert value to DaysToInclude, add

            widget.host.saveFile.Schedules.DaysToDisplay +=
                EnumConverters.daysToIncludeToInt(EnumConverters.dayOfWeekToDaysToInclude(EnumConverters.intToDayOfWeek(i)));
          } else {
            widget.host.saveFile.Schedules.DaysToDisplay -=
                EnumConverters.daysToIncludeToInt(EnumConverters.dayOfWeekToDaysToInclude(EnumConverters.intToDayOfWeek(i)));
          }
        },
      ));
    }

    scheduleDaysOfWeek.forEach((key, value) {});
    return checkboxes;
  }
}