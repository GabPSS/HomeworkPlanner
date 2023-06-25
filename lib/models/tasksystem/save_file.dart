import 'package:homeworkplanner/models/lists/schedule_list.dart';
import 'package:homeworkplanner/models/lists/subject_list.dart';
import 'package:homeworkplanner/models/lists/task_list.dart';
import 'package:homeworkplanner/models/main/day_note.dart';
import 'package:homeworkplanner/models/tasksystem/save_settings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_file.g.dart';

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
