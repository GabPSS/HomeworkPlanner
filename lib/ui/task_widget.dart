import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:intl/intl.dart';

enum TaskStyle { normal, compact, display, selectable }
//Normal: noDragging: False, compact: false, selectable: false,
//Compact: noDragging: false, compact: true, selectable: false,
//Display: noDragging: true, compact: false, selectable: false,
//Selectable: noDragging: true, compact: false, selectable: true,

class TaskWidget extends StatefulWidget {
  final Function()? onTaskUpdate;
  final Function()? onDragStarted;
  final Function(bool? value)? onSelected;
  final bool useLongPressDraggable;
  final bool initialSelectedValue;
  final TaskStyle style;
  final TaskHost host;
  final Task task;

  bool get noDragging =>
      style == TaskStyle.display || style == TaskStyle.selectable;

  const TaskWidget({
    super.key,
    required this.host,
    required this.task,
    this.useLongPressDraggable = false,
    this.onDragStarted,
    this.onTaskUpdate,
    this.onSelected,
    this.style = TaskStyle.normal,
    this.initialSelectedValue = false,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    var listTile = _buildTaskWidget(
        widget.task, context, widget.style == TaskStyle.compact);
    return widget.noDragging
        ? listTile
        : _buildTaskDraggable(widget.task, listTile);
  }

  Widget _buildTaskWidget(Task task, BuildContext context,
      [bool compact = false]) {
    String taskTitle;
    String dueDateString = (task.dueDate != null
        ? "Due ${DateFormat.yMMMd().format(task.dueDate!)}"
        : "No due date");

    String subjectPrefix = (Subject.isIdValid(task.subjectID, widget.host)
        ? "${widget.host.getSubjectNameById(task.subjectID)} - "
        : "");

    taskTitle = subjectPrefix + task.toString();

    if (!compact) {
      String dueSuffix = task.dueDate != null
          ? " - Due ${DateFormat.yMMMd().format(task.dueDate!)}"
          : "";
      taskTitle += dueSuffix;
    }

    Color? tileColor =
        task.isCompleted ? const Color.fromRGBO(180, 180, 180, 1) : null;

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
      leading: widget.style == TaskStyle.selectable
          ? buildSelectionButton(task)
          : buildTaskIconButton(task),
      title: Text(
        taskTitle,
        style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null),
      ),
      subtitle:
          Text(task.description != "" ? task.description : "No description"),
      onTap: onTap,
    );
  }

  IconButton buildTaskIconButton(Task task) => IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        setState(() => task.isCompleted = !task.isCompleted);
        widget.onTaskUpdate?.call();
      },
      icon: task.getIcon());

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
                        task.isCompleted ? TextDecoration.lineThrough : null)),
            Text(dueDateString, style: TextStyle(color: tileColor))
          ],
        ),
      ),
    );
  }

  Widget buildTaskWidget(Task task, [bool compact = false]) {
    var listTile = _buildTaskWidget(task, context, compact);
    return widget.noDragging ? listTile : _buildTaskDraggable(task, listTile);
  }

  Draggable<Task> _buildTaskDraggable(Task task, Widget listTile) {
    return widget.useLongPressDraggable
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
    task.execDate = null;
    if (widget.onDragStarted != null) {
      widget.onDragStarted!();
    }
  }

  Checkbox buildSelectionButton(Task task) => Checkbox(
        value: widget.initialSelectedValue,
        onChanged: (value) => widget.onSelected?.call(value),
      );
}
