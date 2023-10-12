// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      name: json['SubjectName'] as String? ?? "",
      id: json['SubjectID'] as int? ?? 0,
    )..color = json['SubjectColor'] as int;

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'SubjectID': instance.id,
      'SubjectName': instance.name,
      'SubjectColor': instance.color,
    };
