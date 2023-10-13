// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectList _$SubjectListFromJson(Map<String, dynamic> json) => SubjectList()
  ..lastIndex = json['LastIndex'] as int
  ..items = (json['Items'] as List<dynamic>)
      .map((e) => Subject.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$SubjectListToJson(SubjectList instance) =>
    <String, dynamic>{
      'LastIndex': instance.lastIndex,
      'Items': instance.items,
    };
