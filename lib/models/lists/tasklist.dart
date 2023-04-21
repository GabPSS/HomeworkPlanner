// ignore_for_file: non_constant_identifier_names

import 'package:homeworkplanner/models/main/task.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tasklist.g.dart';

@JsonSerializable()
class TaskList {
  int LastIndex = -1;
  List<Task> Items = List.empty();

  void Add(Task item) {
    //TODO: Implement task addition
    throw UnimplementedError('TaskList Add() not implemented');
  }

  TaskList({int lastIndex = -1, List<Task>? items}) {
    LastIndex = lastIndex;
    if (items != null) {
      Items = items;
    }
  }

  factory TaskList.fromJson(Map<String, dynamic> json) => _$TaskListFromJson(json);

  Map<String, dynamic> toJson() => _$TaskListToJson(this);

}