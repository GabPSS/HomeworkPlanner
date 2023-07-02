import 'package:flutter/material.dart';
import 'package:homeworkplanner/enums.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:homeworkplanner/ui/task_page.dart';

import '../models/main/task.dart';

class ReportsPage extends StatefulWidget {
  final TaskHost host;

  const ReportsPage({super.key, required this.host});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    Widget pageContents;

    List<Task> taskList = widget.host.saveFile.Tasks.Items.where((element) => element.IsCompleted).toList();
    if (taskList.isNotEmpty) {
      TaskHost.SortTasks(SortMethod.DateCompleted, taskList);

      pageContents = ListView.builder(
        itemBuilder: (context, index) {
          Task task = taskList[index];
          String? subject = widget.host.getSubjectNameById(task.SubjectID) ?? "";
          if (subject != "") {
            subject += " - ";
          }
          return ListTile(
            leading: task.GetIcon(true),
            title: Text("$subject${task.Name}"),
            subtitle: Text('Due: ${task.DueDate}, Completed: ${task.DateCompleted}'),
            onTap: () => TaskEditor.show(context: context, host: widget.host, task: task, onTaskUpdated: () => setState(() {})),
          );
        },
        itemCount: taskList.length,
      );
    } else {
      pageContents = const Center(
        child: Text('There are no tasks to display'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task report'),
      ),
      body: pageContents,
    );
  }
}
