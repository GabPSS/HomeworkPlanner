import 'package:homeworkplanner/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_settings.g.dart';

@JsonSerializable()
class SaveSettings {
  int FutureWeeks;
  int DaysToDisplay;
  bool DisplayPreviousTasks;
  @JsonKey(name: "SortMethod")
  SortMethod sortMethod;

  SaveSettings(
      {this.FutureWeeks = 2,
      this.DaysToDisplay = 62,
      this.DisplayPreviousTasks = false,
      this.sortMethod = SortMethod.DueDate});

  factory SaveSettings.fromJson(Map<String, dynamic> json) =>
      _$SaveSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSettingsToJson(this);
}
