import 'package:homeworkplanner/models/main/subject.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject_list.g.dart';

@JsonSerializable()
class SubjectList {
  int LastIndex = -1;
  List<Subject> Items = List.empty(growable: true);

  int add(String subject) {
    //TODO: Implement adding subjects
    throw UnimplementedError('SubjectList add() not implemented');
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