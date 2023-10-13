// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveFile _$SaveFileFromJson(Map<String, dynamic> json) => SaveFile()
  ..tasks = TaskList.fromJson(json['Tasks'] as Map<String, dynamic>)
  ..subjects = SubjectList.fromJson(json['Subjects'] as Map<String, dynamic>)
  ..schedules = ScheduleList.fromJson(json['Schedules'] as Map<String, dynamic>)
  ..dayNotes = (json['DayNotes'] as List<dynamic>)
      .map((e) => DayNote.fromJson(e as Map<String, dynamic>))
      .toList()
  ..settings = SaveSettings.fromJson(json['Settings'] as Map<String, dynamic>);

Map<String, dynamic> _$SaveFileToJson(SaveFile instance) => <String, dynamic>{
      'Tasks': instance.tasks.toJson(),
      'Subjects': instance.subjects.toJson(),
      'Schedules': instance.schedules.toJson(),
      'DayNotes': instance.dayNotes.map((e) => e.toJson()).toList(),
      'Settings': instance.settings.toJson(),
    };
