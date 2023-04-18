// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daynote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayNote _$DayNoteFromJson(Map<String, dynamic> json) => DayNote(
      Date: DateTime.parse(json['Date'] as String),
      Message: json['Message'] as String,
    )..Cancelled = json['Cancelled'] as bool;

Map<String, dynamic> _$DayNoteToJson(DayNote instance) => <String, dynamic>{
      'Date': instance.Date.toIso8601String(),
      'Message': instance.Message,
      'Cancelled': instance.Cancelled,
    };
