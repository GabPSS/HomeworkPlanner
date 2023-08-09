// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleList _$ScheduleListFromJson(Map<String, dynamic> json) => ScheduleList()
  ..DaysToDisplay = json['DaysToDisplay'] as int
  ..Items = (json['Items'] as List<dynamic>)
      .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ScheduleListToJson(ScheduleList instance) =>
    <String, dynamic>{
      'DaysToDisplay': instance.DaysToDisplay,
      'Items': instance.Items,
    };
