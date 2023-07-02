import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  static const String defaultMissingSubjectText = "(No subject)";

  int SubjectID;
  String SubjectName;
  int SubjectColor = 0xFFABABAB;

  Color get SubjectColorValue => Color(SubjectColor);
  set SubjectColorValue(Color value) {
    SubjectColor = value.value;
  }

  //TODO: Implement autoincrementing logic and remove default values
  Subject({this.SubjectName = "", this.SubjectID = 0});

  Subject.editSubjectsTemplate({this.SubjectName = "(Edit subjects)", this.SubjectID = -123});

  Subject.noSubjectTemplate({this.SubjectID: -1, this.SubjectName: defaultMissingSubjectText});

  @override
  String toString() {
    return SubjectName;
  }

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
