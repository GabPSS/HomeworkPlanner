import 'package:homeworkplanner/helperfunctions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  @JsonKey(name: 'StartTime')
  String startTime;
  @JsonKey(name: 'EndTime')
  String endTime;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Duration get startTimeValue => HelperFunctions.stringToDuration(startTime);
  set startTimeValue(value) =>
      startTime = HelperFunctions.durationToString(value);
  @JsonKey(includeFromJson: false, includeToJson: false)
  Duration get endTimeValue => HelperFunctions.stringToDuration(endTime);
  set endTimeValue(value) => endTime = HelperFunctions.durationToString(value);

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get shortStartTime =>
      HelperFunctions.durationToString(startTimeValue, true);
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get shortEndTime =>
      HelperFunctions.durationToString(endTimeValue, true);

  @JsonKey(name: 'Subjects')
  List<int?> subjects = List.filled(7, null);

  Schedule({required this.startTime, required this.endTime});

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
