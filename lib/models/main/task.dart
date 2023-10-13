import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  //Class constants
  static const String untitledTaskText = "Untitled Task";
  static DateTime minimumDateTime = DateTime(1);

  @JsonKey(name: 'TaskID')
  int id = -1;
  @JsonKey(name: 'SubjectID')
  int subjectID = -1;
  @JsonKey(name: 'Name')
  String name = "";
  @JsonKey(name: 'DueDate')
  DateTime? dueDate;
  @JsonKey(name: 'Description')
  String description = "";
  @JsonKey(name: 'ExecDate')
  DateTime? execDate;
  @JsonKey(name: 'DateCompleted')
  DateTime? dateCompleted;
  @JsonKey(name: 'IsImportant')
  bool isImportant = false;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isCompleted => dateCompleted != null;
  set isCompleted(bool value) {
    dateCompleted = dateCompleted == null
        ? value
            ? HelperFunctions.getToday()
            : null
        : !value
            ? null
            : dateCompleted;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isScheduled => execDate != null;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isOverdue =>
      !isCompleted &&
      (dueDate != null
          ? dueDate!.compareTo(HelperFunctions.getToday()) < 0
          : false);

  @override
  String toString() {
    if (name != "") {
      return name;
    } else {
      return Task.untitledTaskText;
    }
  }

  Task();

  TaskStatus getStatus() {
    int status = 0;
    if (isOverdue) {
      status = -10;
    } else if (isCompleted) {
      status = 70;
    } else {
      status = isScheduled ? status + 10 : status;
      status = isImportant ? status + 20 : status;
    }

    return EnumConverters.intToTaskStatus(status);
  }

  Icon getIcon([bool ignoreCompletedOrOverdue = false]) {
    IconData toReturn;
    toReturn = isCompleted && !ignoreCompletedOrOverdue
        ? Icons.assignment_turned_in
        : isOverdue && !ignoreCompletedOrOverdue
            ? Icons.assignment_late
            : isScheduled && isImportant
                ? Icons.label_important
                : isImportant
                    ? Icons.label_important_outline
                    : isScheduled
                        ? Icons.assignment
                        : Icons.assignment_outlined;
    return Icon(toReturn, size: 32);
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
