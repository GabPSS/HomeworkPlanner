import 'package:flutter/material.dart';
import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:homeworkplanner/models/main/subject.dart';
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
    List<Widget> weekDaysList = List.empty(growable: true);
    List<int> acceptableDays = List.empty(growable: true);
    weekDaysList.add(Center(child: Text('Schedules')));

    HelperFunctions.iterateThroughWeekFromDate(
      widget.host.saveFile.Schedules.DaysToDisplay.toDouble(),
      HelperFunctions.getThisSaturday(),
      (day) {
        weekDaysList.add(Center(child: Text(EnumConverters.weekdayToDayOfWeek(day.weekday).name)));
        acceptableDays.add(EnumConverters.weekdayToInt(day.weekday));
      },
    );

    List<TableRow> schedules = [TableRow(children: weekDaysList)].toList(growable: true);

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
        if (acceptableDays.contains(index)) {
          cols.add(DropdownButtonFormField(
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
          ));
        }
      }
      return TableRow(children: cols);
    }));

    return Table(
      columnWidths: {0: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: schedules,
    );
  }
}
