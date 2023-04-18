import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ScheduleList.g.dart';

@JsonSerializable()
class ScheduleList {
  var DaysToDisplay; //TODO: Implement DaysToDisplay
  List<Schedule> Items = List.empty();

  ScheduleList({List<Schedule>? items}) {
    if (items != null) {
      Items = items;
    }
  }

  factory ScheduleList.fromJson(Map<String, dynamic> json) => _$ScheduleListFromJson(json);
  
  Map<String, dynamic> toJson() => _$ScheduleListToJson(this);
}