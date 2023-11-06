// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayNote _$DayNoteFromJson(Map<String, dynamic> json) => DayNote(
      date: DateTime.parse(json['Date'] as String),
      message: json['Message'] as String,
      cancelled: json['Cancelled'] as bool? ?? false,
      noClass: json['noClass'] as bool? ?? false,
    );

Map<String, dynamic> _$DayNoteToJson(DayNote instance) => <String, dynamic>{
      'Date': instance.date.toIso8601String(),
      'Message': instance.message,
      'Cancelled': instance.cancelled,
      'noClass': instance.noClass,
    };
