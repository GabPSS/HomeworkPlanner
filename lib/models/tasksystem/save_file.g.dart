// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveFile _$SaveFileFromJson(Map<String, dynamic> json) => SaveFile()
  ..Tasks = TaskList.fromJson(json['Tasks'] as Map<String, dynamic>)
  ..Subjects = SubjectList.fromJson(json['Subjects'] as Map<String, dynamic>)
  ..Schedules = ScheduleList.fromJson(json['Schedules'] as Map<String, dynamic>)
  ..DayNotes = (json['DayNotes'] as List<dynamic>)
      .map((e) => DayNote.fromJson(e as Map<String, dynamic>))
      .toList()
  ..Settings = SaveSettings.fromJson(json['Settings'] as Map<String, dynamic>);

Map<String, dynamic> _$SaveFileToJson(SaveFile instance) => <String, dynamic>{
      'Tasks': instance.Tasks.toJson(),
      'Subjects': instance.Subjects.toJson(),
      'Schedules': instance.Schedules.toJson(),
      'DayNotes': instance.DayNotes.map((e) => e.toJson()).toList(),
      'Settings': instance.Settings.toJson(),
    };
