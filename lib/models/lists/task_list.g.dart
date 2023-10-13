// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList()
  ..lastIndex = json['LastIndex'] as int
  ..items = (json['Items'] as List<dynamic>)
      .map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$TaskListToJson(TaskList instance) => <String, dynamic>{
      'LastIndex': instance.lastIndex,
      'Items': instance.items,
    };
