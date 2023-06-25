// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSettings _$SaveSettingsFromJson(Map<String, dynamic> json) => SaveSettings(
      FutureWeeks: json['FutureWeeks'] as int? ?? 2,
      DaysToDisplay: json['DaysToDisplay'] as int? ?? 62,
      DisplayPreviousTasks: json['DisplayPreviousTasks'] as bool? ?? false,
      SortMethod: json['SortMethod'],
    );

Map<String, dynamic> _$SaveSettingsToJson(SaveSettings instance) => <String, dynamic>{
      'FutureWeeks': instance.FutureWeeks,
      'DaysToDisplay': instance.DaysToDisplay,
      'DisplayPreviousTasks': instance.DisplayPreviousTasks,
      'SortMethod': instance.SortMethod,
    };
