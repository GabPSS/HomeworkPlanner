// ignore_for_file: non_constant_identifier_names

import 'package:homeworkplanner/models/lists/schedulelist.dart';
import 'package:homeworkplanner/models/lists/subjectlist.dart';
import 'package:homeworkplanner/models/lists/tasklist.dart';
import 'package:homeworkplanner/models/main/daynote.dart';
import 'package:homeworkplanner/tasksystem/savesettings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'savefile.g.dart';

@JsonSerializable(explicitToJson: true)
class SaveFile {
  TaskList Tasks = TaskList();
  SubjectList Subjects = SubjectList();
  ScheduleList Schedules = ScheduleList();
  // DayNoteList DayNotes;
  List<DayNote> DayNotes = List.empty();
  SaveSettings Settings = SaveSettings();

  factory SaveFile.fromJson(Map<String, dynamic> json) => _$SaveFileFromJson(json);

  Map<String, dynamic> toJson() => _$SaveFileToJson(this);
  
  SaveFile();
}