import 'package:homeworkplanner/models/main/task.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_list.g.dart';

@JsonSerializable()
class TaskList {
  int LastIndex = -1;
  List<Task> Items = List.empty(growable: true);

  void Add(Task item) {
    int newIndex = LastIndex + 1;
    item.TaskID = newIndex;
    Items.add(item);
    LastIndex = newIndex;
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
