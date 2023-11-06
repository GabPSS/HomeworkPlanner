import 'package:homeworkplanner/models/lists/schedule_list.dart';
import 'package:homeworkplanner/models/lists/subject_list.dart';
import 'package:homeworkplanner/models/lists/task_list.dart';
import 'package:homeworkplanner/models/main/day_note.dart';
import 'package:homeworkplanner/models/tasksystem/save_settings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_file.g.dart';

@JsonSerializable(explicitToJson: true)
class SaveFile {
  @JsonKey(name: 'Tasks')
  TaskList tasks = TaskList();
  @JsonKey(name: 'Subjects')
  SubjectList subjects = SubjectList();
  @JsonKey(name: 'Schedules')
  ScheduleList schedules = ScheduleList();
  @JsonKey(name: 'DayNotes')
  List<DayNote> dayNotes = List.empty(growable: true);
  @JsonKey(name: 'Settings')
  SaveSettings settings = SaveSettings();

  factory SaveFile.fromJson(Map<String, dynamic> json) =>
      _$SaveFileFromJson(json);

  Map<String, dynamic> toJson() => _$SaveFileToJson(this);

  SaveFile();
}
