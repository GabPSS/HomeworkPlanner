// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'savesettings.g.dart';

@JsonSerializable()
class SaveSettings {
  int FutureWeeks;
  var DaysToDisplay; // TODO: Implement DaysToInclude
  bool DisplayPreviousTasks;
  var SortMethod; //TODO: Implement SortMethod enum

  SaveSettings({this.FutureWeeks = 2, this.DaysToDisplay, this.DisplayPreviousTasks = false, this.SortMethod});

  factory SaveSettings.fromJson(Map<String, dynamic> json) => _$SaveSettingsFromJson(json);
  
  Map<String, dynamic> toJson() => _$SaveSettingsToJson(this);
}