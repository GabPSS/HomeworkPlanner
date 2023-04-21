
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  //Class constants
  static const String UntitledTaskText = "Untitled Task";
  static DateTime minimumDateTime = DateTime(1,1,1);
  //TODO: Implement TaskStatus
  int TaskID = -1;
  int SubjectID = -1;
  String Name = UntitledTaskText;
  DateTime DueDate = minimumDateTime; //TODO: Datetime means minimum value or null
  List<String> Description = List.empty();
  DateTime? ExecDate;
  DateTime? DateCompleted;
  bool IsImportant = false;

  //TODO: Implement task logic and methods

  @override
  String toString() {
    return Name;
  }

  Task({required this.TaskID, required this.SubjectID, required this.Name, required this.Description});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}