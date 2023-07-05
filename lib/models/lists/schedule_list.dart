import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_list.g.dart';

@JsonSerializable()
class ScheduleList {
  int DaysToDisplay = 62;
  List<Schedule> Items = List.empty(growable: true);

  ScheduleList({List<Schedule>? items}) {
    if (items != null) {
      Items = items;
    }
  }

  factory ScheduleList.fromJson(Map<String, dynamic> json) => _$ScheduleListFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleListToJson(this);
}
