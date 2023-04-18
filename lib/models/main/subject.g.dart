// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      SubjectName: json['SubjectName'] as String? ?? "",
      SubjectID: json['SubjectID'] as int? ?? 0,
    )..SubjectColor = json['SubjectColor'] as int;

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'SubjectID': instance.SubjectID,
      'SubjectName': instance.SubjectName,
      'SubjectColor': instance.SubjectColor,
    };
