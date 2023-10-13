import 'package:homeworkplanner/models/main/subject.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject_list.g.dart';

@JsonSerializable()
class SubjectList {
  @JsonKey(name: 'LastIndex')
  int lastIndex = -1;
  @JsonKey(name: 'Items')
  List<Subject> items = List.empty(growable: true);

  int add(String subject) {
    return addSubject(Subject(name: subject));
  }

  int addSubject(Subject subject) {
    int subjectID = lastIndex + 1;
    subject.id = subjectID;
    items.add(subject);
    lastIndex = subjectID;
    return subjectID;
  }

  SubjectList({int startLastIndex = -1, List<Subject>? startItems}) {
    lastIndex = startLastIndex;
    if (startItems != null) {
      items = startItems;
    }
  }
  factory SubjectList.fromJson(Map<String, dynamic> json) =>
      _$SubjectListFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectListToJson(this);
}
