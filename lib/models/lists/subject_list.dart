import 'package:homeworkplanner/models/main/subject.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject_list.g.dart';

@JsonSerializable()
class SubjectList {
  int LastIndex = -1;
  List<Subject> Items = List.empty(growable: true);

  int add(String subject) {
    return addSubject(Subject(SubjectName: subject));
  }

  int addSubject(Subject subject) {
    int subjectID = LastIndex + 1;
    subject.SubjectID = subjectID;
    Items.add(subject);
    LastIndex = subjectID;
    return subjectID;
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
