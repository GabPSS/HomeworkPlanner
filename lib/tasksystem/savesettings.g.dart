// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savesettings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSettings _$SaveSettingsFromJson(Map<String, dynamic> json) => SaveSettings(
      FutureWeeks: json['FutureWeeks'] as int? ?? 2,
      DaysToDisplay: json['DaysToDisplay'] ?? null,
      DisplayPreviousTasks: json['DisplayPreviousTasks'] as bool? ?? false,
      SortMethod: json['SortMethod'] ?? null,
    );

Map<String, dynamic> _$SaveSettingsToJson(SaveSettings instance) =>
    <String, dynamic>{
      'FutureWeeks': instance.FutureWeeks,
      'DaysToDisplay': instance.DaysToDisplay,
      'DisplayPreviousTasks': instance.DisplayPreviousTasks,
      'SortMethod': instance.SortMethod,
    };
