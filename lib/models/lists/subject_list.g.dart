// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectList _$SubjectListFromJson(Map<String, dynamic> json) => SubjectList()
  ..LastIndex = json['LastIndex'] as int
  ..Items = (json['Items'] as List<dynamic>).map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();

Map<String, dynamic> _$SubjectListToJson(SubjectList instance) => <String, dynamic>{
      'LastIndex': instance.LastIndex,
      'Items': instance.Items,
    };
