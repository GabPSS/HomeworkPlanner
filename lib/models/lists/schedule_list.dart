import 'package:homeworkplanner/models/main/schedule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_list.g.dart';

@JsonSerializable()
class ScheduleList {
  @JsonKey(name: 'DaysToDisplay')
  int daysToDisplay = 62;
  @JsonKey(name: 'Items')
  List<Schedule> items = List.empty(growable: true);

  ScheduleList({List<Schedule>? scheduleItems}) {
    if (scheduleItems != null) {
      items = scheduleItems;
    }
  }

  factory ScheduleList.fromJson(Map<String, dynamic> json) =>
      _$ScheduleListFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleListToJson(this);
}
