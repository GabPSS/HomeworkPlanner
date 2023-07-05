// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
      StartTime: json['StartTime'] as String,
      EndTime: json['EndTime'] as String,
    )..Subjects =
        (json['Subjects'] as List<dynamic>).map((e) => e as int?).toList();

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'StartTime': instance.StartTime,
      'EndTime': instance.EndTime,
      'Subjects': instance.Subjects,
    };
