import 'dart:math';

import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  static const String defaultMissingSubjectText = "(No subject)";

  int SubjectID;
  String SubjectName;
  int SubjectColor = 0xFFABABAB;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get SubjectColorValue => Color(SubjectColor);
  set SubjectColorValue(Color value) {
    SubjectColor = value.value;
  }

  static bool isIdValid(int? id, TaskHost host) => id == null
      ? false
      : host.getSubjectById(id) == null
          ? false
          : true;

  //TODO: Implement autoincrementing logic and remove default values
  Subject({this.SubjectName = "", this.SubjectID = 0}) {
    setRandomColor();
  }

  Subject.editSubjectsTemplate({this.SubjectName = "(Edit subjects)", this.SubjectID = -123});

  Subject.noSubjectTemplate({this.SubjectID = -1, this.SubjectName = defaultMissingSubjectText});

  @override
  String toString() {
    return SubjectName;
  }

  void setRandomColor() {
    double h, s, v;
    Random random = Random();
    h = random.nextInt(360).toDouble();
    s = random.nextInt(30) + 45;
    v = random.nextInt(35) + 55;
    s /= 100;
    v /= 100;
    SubjectColorValue = HSVColor.fromAHSV(1, h, s, v).toColor();
  }

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
