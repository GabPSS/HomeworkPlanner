import 'package:json_annotation/json_annotation.dart';

part 'day_note.g.dart';

@JsonSerializable()
class DayNote {
  @JsonKey(name: 'Date')
  DateTime date;
  @JsonKey(name: 'Message')
  String message;
  @JsonKey(name: 'Cancelled')
  bool cancelled = false;
  bool noClass = false;

  DayNote(
      {required this.date,
      required this.message,
      this.cancelled = false,
      this.noClass = false});

  factory DayNote.fromJson(Map<String, dynamic> json) =>
      _$DayNoteFromJson(json);

  Map<String, dynamic> toJson() => _$DayNoteToJson(this);
}
