import 'package:homeworkplanner/models/main/subject.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subjectlist.g.dart';

@JsonSerializable()
class SubjectList {
  int LastIndex = -1;
  List<Subject> Items = List.empty();

  int Add(String subject) {
    //TODO: Implement adding subjects
    throw UnimplementedError('SubjectList Add() not implemented');
  }

  SubjectList({int lastIndex = -1, List<Subject>? items}) {
    LastIndex = lastIndex;
    if (items != null) {
      Items = items;
    }
  }
  factory SubjectList.fromJson(Map<String, dynamic> json) => _$SubjectListFromJson(json);
  
  Map<String, dynamic> toJson() => _$SubjectListToJson(this);
}