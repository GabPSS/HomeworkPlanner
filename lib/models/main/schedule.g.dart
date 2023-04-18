// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
      StartTime: DateTime.parse(json['StartTime'] as String),
      EndTime: DateTime.parse(json['EndTime'] as String),
    )..Subjects =
        (json['Subjects'] as List<dynamic>).map((e) => e as int?).toList();

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'StartTime': instance.StartTime.toIso8601String(),
      'EndTime': instance.EndTime.toIso8601String(),
      'Subjects': instance.Subjects,
    };
