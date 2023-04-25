// ignore_for_file: non_constant_identifier_names
 
import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedulelist.g.dart';

@JsonSerializable()
class ScheduleList {
  var DaysToDisplay; //TODO: Implement DaysToDisplay
  List<Schedule> Items = List.empty(growable: true);

  ScheduleList({List<Schedule>? items}) {
    if (items != null) {
      Items = items;
    }
  }

  factory ScheduleList.fromJson(Map<String, dynamic> json) => _$ScheduleListFromJson(json);
  
  Map<String, dynamic> toJson() => _$ScheduleListToJson(this);
} 