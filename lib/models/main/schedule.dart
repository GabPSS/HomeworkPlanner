class Schedule {
  DateTime StartTime; //TODO: Find an alternative for TimeSpan
  DateTime EndTime;
  List<int?> Subjects = List.filled(7, null);

  Schedule({required this.StartTime, required this.EndTime});
}