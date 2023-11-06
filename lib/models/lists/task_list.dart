import 'package:homeworkplanner/models/main/task.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_list.g.dart';

@JsonSerializable()
class TaskList {
  @JsonKey(name: 'LastIndex')
  int lastIndex = -1;
  @JsonKey(name: 'Items')
  List<Task> items = List.empty(growable: true);

  void add(Task item) {
    int newIndex = lastIndex + 1;
    item.id = newIndex;
    items.add(item);
    lastIndex = newIndex;
  }

  TaskList({int startLastIndex = -1, List<Task>? startItems}) {
    lastIndex = startLastIndex;
    if (startItems != null) {
      items = startItems;
    }
  }

  factory TaskList.fromJson(Map<String, dynamic> json) =>
      _$TaskListFromJson(json);

  Map<String, dynamic> toJson() => _$TaskListToJson(this);
}
