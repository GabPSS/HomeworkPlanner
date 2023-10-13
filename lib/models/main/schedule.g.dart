// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
      startTime: json['StartTime'] as String,
      endTime: json['EndTime'] as String,
    )..subjects =
        (json['Subjects'] as List<dynamic>).map((e) => e as int?).toList();

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'StartTime': instance.startTime,
      'EndTime': instance.endTime,
      'Subjects': instance.subjects,
    };
