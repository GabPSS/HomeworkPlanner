import 'package:homeworkplanner/helperfunctions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  String StartTime;
  String EndTime;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Duration get startTime => HelperFunctions.stringToDuration(StartTime);
  set startTime(value) => StartTime = HelperFunctions.durationToString(value);
  @JsonKey(includeFromJson: false, includeToJson: false)
  Duration get endTime => HelperFunctions.stringToDuration(EndTime);
  set endTime(value) => EndTime = HelperFunctions.durationToString(value);

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get shortStartTime => HelperFunctions.durationToString(startTime, true);
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get shortEndTime => HelperFunctions.durationToString(endTime, true);

  List<int?> Subjects = List.filled(7, null);

  Schedule({required this.StartTime, required this.EndTime});

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
