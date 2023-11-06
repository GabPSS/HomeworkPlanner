import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

class AutoplanDialog {
  static void show(TaskHost host, BuildContext context,
      [Function()? onUpdate]) {
    showDialog(
      context: context,
      builder: (context) {
        int tasksValue = 3;
        bool replanAll = false;
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(title: const Text('Select options'), children: [
            SwitchListTile(
              value: replanAll,
              onChanged: (value) => setState(() => replanAll = value),
              title: const Text('Replan everything'),
              subtitle: const Text('Unschedules all tasks before replanning'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Minimum tasks per day:',
                style: Theme.of(context).primaryTextTheme.titleMedium,
              ),
            ),
            Slider(
              label: tasksValue.toString(),
              value: tasksValue.toDouble(),
              onChanged: (value) => setState(() => tasksValue = value.toInt()),
              min: 0,
              max: 10,
              divisions: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        host.autoplan(
                            replanAll: replanAll, minTasksPerDay: tasksValue);
                        onUpdate?.call();
                      },
                      child: const Text('Replan'))
                ],
              ),
            )
          ]);
        });
      },
    );
  }
}
