// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'daynote.g.dart';

@JsonSerializable()
class DayNote {
  DateTime Date;
  String Message;
  bool Cancelled = false;

  DayNote({required this.Date, required this.Message});

  factory DayNote.fromJson(Map<String, dynamic> json) => _$DayNoteFromJson(json);

  Map<String, dynamic> toJson() => _$DayNoteToJson(this);
}
