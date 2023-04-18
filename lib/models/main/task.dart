import 'dart:ffi';

class Task {
  //Class constants
  static const String UntitledTaskText = "Untitled Task";
  static DateTime minimumDateTime = DateTime(1,1,1);
  //TODO: Implement TaskStatus
  int TaskID = -1;
  int SubjectID = -1;
  String Name = UntitledTaskText;
  DateTime DueDate = minimumDateTime; //TODO: Datetime means minimum value or null
  List<String> Description = List.empty();
  DateTime? ExecDate;
  DateTime? DateCompleted;
  bool IsImportant = false;

  //TODO: Implement task logic and methods

  @override
  String toString() {
    return Name;
  }
}