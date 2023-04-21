import 'dart:ffi';

import 'package:homeworkplanner/models/main/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  //Class constants
  static const String UntitledTaskText = "Untitled Task";
  static DateTime minimumDateTime = DateTime(1);

  //TODO: Implement TaskStatus
  int TaskID = -1;
  int SubjectID = -1;
  String Name = UntitledTaskText;
  DateTime DueDate =
      minimumDateTime; //TODO: Datetime means minimum value or null
  List<String> Description = List.empty();
  DateTime? ExecDate;
  DateTime? DateCompleted;
  bool IsImportant = false;

  bool get IsCompleted => DateCompleted != null;
  set IsCompleted(bool value) {
    DateCompleted = DateCompleted == null
        ? value
            ? DateTime.now()
            : null
        : !value
            ? null
            : DateCompleted; //TODO: Check if using DateTime.now() doesn't interfer with anything
  }

  bool get IsScheduled => ExecDate != null;
  bool get IsOverdue =>
      !IsCompleted &&
      (DueDate.compareTo(DateTime.now()) < 0) &&
      DueDate != minimumDateTime;

  @override
  String toString() {
    return Name;
  }

  Task(
      {required this.TaskID,
      required this.SubjectID,
      required this.Name,
      required this.Description});

  TaskStatus GetStatus() {
    int status = 0;
    if (IsOverdue) {
      status = -10;
    } else if (IsCompleted) {
      status = 70;
    } else {
      status = IsScheduled ? status + 10 : status;
      status = IsImportant ? status + 20 : status;
    }

    return EnumConverters.intToTaskStatus(status);
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}