import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:intl/intl.dart';

class TaskWidget extends StatefulWidget {
  final TaskHost host;
  final Function()? onTaskUpdate;
  final bool onMobile;
  final bool denyDragging;
  final bool compact;
  final Task task;
  final Function()? onDragStarted;

  const TaskWidget(
      {super.key,
      required this.host,
      required this.task,
      this.compact = false,
      this.onTaskUpdate,
      this.onMobile = false,
      this.denyDragging = false,
      this.onDragStarted});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    var listTile = _buildTaskWidget(widget.task, context, widget.compact);
    return widget.denyDragging
        ? listTile
        : _buildTaskDraggable(widget.task, listTile);
  }

  Widget _buildTaskWidget(Task task, BuildContext context,
      [bool compact = false]) {
    String taskTitle;
    String dueDateString = (task.DueDate != null
        ? "Due ${DateFormat.yMMMd().format(task.DueDate!)}"
        : "No due date");

    String subjectPrefix = (Subject.isIdValid(task.SubjectID, widget.host)
        ? "${widget.host.getSubjectNameById(task.SubjectID)} - "
        : "");

    taskTitle = subjectPrefix + task.toString();

    if (!compact) {
      String dueSuffix = task.DueDate != null
          ? " - Due ${DateFormat.yMMMd().format(task.DueDate!)}"
          : "";
      taskTitle += dueSuffix;
    }

    Color? tileColor =
        task.IsCompleted ? const Color.fromRGBO(180, 180, 180, 1) : null;

    onTap() {
      TaskEditor.show(
          context: context,
          host: widget.host,
          task: task,
          onTaskUpdated: widget.onTaskUpdate ?? () {});
    }

    if (compact) {
      return buildCompactTaskWidget(
          onTap, taskTitle, tileColor, task, dueDateString);
    }

    return ListTile(
      iconColor: tileColor,
      textColor: tileColor,
      leading: IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            setState(() {
              task.IsCompleted = !task.IsCompleted;
            });
          },
          icon: task.getIcon()),
      title: Text(
        taskTitle,
        style: TextStyle(
            decoration: task.IsCompleted ? TextDecoration.lineThrough : null),
      ),
      subtitle:
          Text(task.Description != "" ? task.Description : "No description"),
      onTap: onTap,
    );
  }

  Widget buildCompactTaskWidget(Function() onTap, String taskTitle,
      Color? tileColor, Task task, String dueDateString) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(taskTitle,
                style: TextStyle(
                    color: tileColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration:
                        task.IsCompleted ? TextDecoration.lineThrough : null)),
            Text(dueDateString, style: TextStyle(color: tileColor))
          ],
        ),
      ),
    );
  }

  Widget buildTaskWidget(Task task, [bool compact = false]) {
    var listTile = _buildTaskWidget(task, context, compact);
    return widget.denyDragging ? listTile : _buildTaskDraggable(task, listTile);
  }

  Draggable<Task> _buildTaskDraggable(Task task, Widget listTile) {
    return widget.onMobile
        ? LongPressDraggable(
            data: task,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: task.getIcon(),
            child: listTile,
            onDragStarted: () => dragStarted(task),
          )
        : Draggable(
            data: task,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: task.getIcon(),
            child: listTile,
            onDragStarted: () => dragStarted(task),
          );
  }

  void dragStarted(Task task) {
    widget.onTaskUpdate?.call();
    task.ExecDate = null;
    if (widget.onDragStarted != null) {
      widget.onDragStarted!();
    }
  }
}
