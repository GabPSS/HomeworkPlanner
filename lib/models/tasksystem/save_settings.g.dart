// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSettings _$SaveSettingsFromJson(Map<String, dynamic> json) => SaveSettings(
      futureWeeks: json['FutureWeeks'] as int? ?? 2,
      daysToDisplay: json['DaysToDisplay'] as int? ?? 62,
      displayPreviousTasks: json['DisplayPreviousTasks'] as bool? ?? false,
      sortMethod:
          $enumDecodeNullable(_$SortMethodEnumMap, json['SortMethod']) ??
              SortMethod.DueDate,
    );

Map<String, dynamic> _$SaveSettingsToJson(SaveSettings instance) =>
    <String, dynamic>{
      'FutureWeeks': instance.futureWeeks,
      'DaysToDisplay': instance.daysToDisplay,
      'DisplayPreviousTasks': instance.displayPreviousTasks,
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
