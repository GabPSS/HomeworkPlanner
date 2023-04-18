import 'package:homeworkplanner/models/lists/ScheduleList.dart';
import 'package:homeworkplanner/models/lists/subjectlist.dart';
import 'package:homeworkplanner/models/lists/tasklist.dart';
import 'package:homeworkplanner/models/main/daynote.dart';
import 'package:homeworkplanner/tasksystem/savesettings.dart';

class SaveFile {
  late TaskList Tasks = TaskList();
  late SubjectList Subjects = SubjectList();
  late ScheduleList Schedules = ScheduleList();
  // DayNoteList DayNotes;
  late List<DayNote> DayNotes = List.empty();
  late SaveSettings Settings = SaveSettings();

  //TODO: Implement JSON logic
}