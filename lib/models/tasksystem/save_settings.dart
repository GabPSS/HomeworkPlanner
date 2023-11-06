import 'package:homeworkplanner/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_settings.g.dart';

@JsonSerializable()
class SaveSettings {
  @JsonKey(name: 'FutureWeeks')
  int futureWeeks;
  @JsonKey(name: 'DaysToDisplay')
  int daysToDisplay;
  @JsonKey(name: 'DisplayPreviousTasks')
  bool displayPreviousTasks;
  @JsonKey(name: "SortMethod")
  SortMethod sortMethod;

  SaveSettings(
      {this.futureWeeks = 2,
      this.daysToDisplay = 62,
      this.displayPreviousTasks = false,
      this.sortMethod = SortMethod.DueDate});

  factory SaveSettings.fromJson(Map<String, dynamic> json) =>
      _$SaveSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSettingsToJson(this);
}
