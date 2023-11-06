import 'dart:math';

import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  static const String defaultMissingSubjectText = "(No subject)";

  @JsonKey(name: 'SubjectID')
  int id;
  @JsonKey(name: 'SubjectName')
  String name;
  @JsonKey(name: 'SubjectColor')
  int color = 0xFFABABAB;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get colorValue => Color(color);
  set colorValue(Color value) {
    color = value.value;
  }

  static bool isIdValid(int? id, TaskHost host) => id == null
      ? false
      : host.getSubjectById(id) == null
          ? false
          : true;

  Subject({this.name = "", this.id = 0}) {
    setRandomColor();
  }

  Subject.editSubjectsTemplate({this.name = "(Edit subjects)", this.id = -123});

  Subject.noSubjectTemplate(
      {this.id = -1, this.name = defaultMissingSubjectText});

  @override
  String toString() {
    return name;
  }

  void setRandomColor() {
    double h, s, v;
    Random random = Random();
    h = random.nextInt(360).toDouble();
    s = random.nextInt(30) + 45;
    v = random.nextInt(35) + 55;
    s /= 100;
    v /= 100;
    colorValue = HSVColor.fromAHSV(1, h, s, v).toColor();
  }

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
