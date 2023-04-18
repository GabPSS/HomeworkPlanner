// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      TaskID: json['TaskID'] as int,
      SubjectID: json['SubjectID'] as int,
      Name: json['Name'] as String,
      Description: (json['Description'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )
      ..DueDate = DateTime.parse(json['DueDate'] as String)
      ..ExecDate = json['ExecDate'] == null
          ? null
          : DateTime.parse(json['ExecDate'] as String)
      ..DateCompleted = json['DateCompleted'] == null
          ? null
          : DateTime.parse(json['DateCompleted'] as String)
      ..IsImportant = json['IsImportant'] as bool;

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'TaskID': instance.TaskID,
      'SubjectID': instance.SubjectID,
      'Name': instance.Name,
      'DueDate': instance.DueDate.toIso8601String(),
      'Description': instance.Description,
      'ExecDate': instance.ExecDate?.toIso8601String(),
      'DateCompleted': instance.DateCompleted?.toIso8601String(),
      'IsImportant': instance.IsImportant,
    };
