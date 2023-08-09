// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSettings _$SaveSettingsFromJson(Map<String, dynamic> json) => SaveSettings(
      FutureWeeks: json['FutureWeeks'] as int? ?? 2,
      DaysToDisplay: json['DaysToDisplay'] as int? ?? 62,
      DisplayPreviousTasks: json['DisplayPreviousTasks'] as bool? ?? false,
      sortMethod:
          $enumDecodeNullable(_$SortMethodEnumMap, json['SortMethod']) ??
              SortMethod.DueDate,
    );

Map<String, dynamic> _$SaveSettingsToJson(SaveSettings instance) =>
    <String, dynamic>{
      'FutureWeeks': instance.FutureWeeks,
      'DaysToDisplay': instance.DaysToDisplay,
      'DisplayPreviousTasks': instance.DisplayPreviousTasks,
      'SortMethod': _$SortMethodEnumMap[instance.sortMethod]!,
    };

const _$SortMethodEnumMap = {
  SortMethod.None: 'None',
  SortMethod.DueDate: 'DueDate',
  SortMethod.ID: 'ID',
  SortMethod.Alphabetically: 'Alphabetically',
  SortMethod.Status: 'Status',
  SortMethod.Subject: 'Subject',
  SortMethod.ExecDate: 'ExecDate',
  SortMethod.DateCompleted: 'DateCompleted',
};
