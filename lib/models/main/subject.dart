import 'package:flutter/material.dart';

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
}