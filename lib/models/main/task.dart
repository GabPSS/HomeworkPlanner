import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  //Class constants
  static const String UntitledTaskText = "Untitled Task";
  static DateTime minimumDateTime = DateTime(1);

  //TODO: Implement TaskStatus
  int TaskID = -1;
  int SubjectID = -1;
  String Name = "";
  DateTime? DueDate;
  String Description = "";
  DateTime? ExecDate;
  DateTime? DateCompleted;
  bool IsImportant = false;

  bool get IsCompleted => DateCompleted != null;
  set IsCompleted(bool value) {
    DateCompleted = DateCompleted == null
        ? value
            ? HelperFunctions.getToday()
            : null
        : !value
            ? null
            : DateCompleted; //TODO: Check if using DateTime.now() doesn't interfer with anything
  }

  bool get IsScheduled => ExecDate != null;
  bool get IsOverdue => !IsCompleted && (DueDate != null ? DueDate!.compareTo(HelperFunctions.getToday()) < 0 : false);

  @override
  String toString() {
    if (Name != "") {
      return Name;
    } else {
      return Task.UntitledTaskText;
    }
  }

  Task();

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

  Icon GetIcon() {
    IconData toReturn;
    if (IsCompleted) {
      toReturn = Icons.assignment_turned_in;
    } else {
      if (IsOverdue) {
        toReturn = Icons.assignment_return;
      } else {
        IsScheduled && IsImportant
            ? toReturn = Icons.assignment_late
            : IsImportant
                ? toReturn = Icons.assignment_late_outlined
                : (IsScheduled ? toReturn = Icons.assignment : toReturn = Icons.assignment_outlined);
      }
    }
    return Icon(toReturn, size: 32);
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
