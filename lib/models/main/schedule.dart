// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  var StartTime; //TODO: Find an alternative for TimeSpan
  var EndTime;
  List<int?> Subjects = List.filled(7, null);

  Schedule({required this.StartTime, required this.EndTime});

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
