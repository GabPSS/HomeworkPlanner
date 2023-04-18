import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  static const String DefaultMissingSubjectText = "(No subject)";

  int SubjectID;
  String SubjectName;
  int SubjectColor = 0; //TODO: See if changing this to an actual color object is possible

  //TODO: Implement autoincrementing logic and remove default values
  Subject({this.SubjectName = "", this.SubjectID = 0});

  @override
  String toString() {
    return SubjectName;
  }

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);
  
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}