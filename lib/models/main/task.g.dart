// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task()
  ..id = json['TaskID'] as int
  ..subjectID = json['SubjectID'] as int
  ..name = json['Name'] as String
  ..dueDate =
      json['DueDate'] == null ? null : DateTime.parse(json['DueDate'] as String)
  ..description = json['Description'] as String
  ..execDate = json['ExecDate'] == null
      ? null
      : DateTime.parse(json['ExecDate'] as String)
  ..dateCompleted = json['DateCompleted'] == null
      ? null
      : DateTime.parse(json['DateCompleted'] as String)
  ..isImportant = json['IsImportant'] as bool;

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'TaskID': instance.id,
      'SubjectID': instance.subjectID,
      'Name': instance.name,
      'DueDate': instance.dueDate?.toIso8601String(),
      'Description': instance.description,
      'ExecDate': instance.execDate?.toIso8601String(),
      'DateCompleted': instance.dateCompleted?.toIso8601String(),
      'IsImportant': instance.isImportant,
    };
