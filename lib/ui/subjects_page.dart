import 'package:flutter/material.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';

class SubjectsPage extends StatefulWidget {
  TaskHost host;

  SubjectsPage({super.key, required this.host});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState(host: host);
}

class _SubjectsPageState extends State<SubjectsPage> {
  TaskHost host;

  _SubjectsPageState({required this.host});

  @override
  Widget build(BuildContext context) {
    List<Widget> subjectWidgets = List<Widget>.empty(growable: true);

    for (var i = 0; i < host.saveFile.Subjects.Items.length; i++) {
      subjectWidgets.add(Text(host.saveFile.Subjects.Items[i].SubjectName));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit subjects')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var subject = host.saveFile.Subjects.Items[index];
          return ListTile(
            leading: const Icon(Icons.assignment_ind),
            title: Text(subject.SubjectName),
            onTap: () {
              showSubjectEditorDialog(context, subject);
            },
          );
        },
        itemCount: host.saveFile.Subjects.Items.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Subject newSubject = Subject();
          showSubjectEditorDialog(context, newSubject, true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> showSubjectEditorDialog(BuildContext context, Subject subject, [bool isAdding = false]) {
    return showDialog(
      context: context,
      builder: (context) {
        List<Widget> dialogButtons = List.empty(growable: true);

        dialogButtons.add(Spacer());
        if (isAdding) {
          dialogButtons.add(TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel')));
        }
        dialogButtons.add(TextButton(
            onPressed: () {
              setState(() {
                if (isAdding) {
                  host.saveFile.Subjects.addSubject(subject);
                }
              });
              Navigator.pop(context);
            },
            child: Text('OK')));

        return SimpleDialog(
          title: Text(isAdding ? 'Add subject' : 'Edit subject'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                initialValue: subject.SubjectName,
                onChanged: (value) {
                  subject.SubjectName = value;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.assignment_ind),
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            Row(
              children: dialogButtons,
            )
          ],
        );
      },
    );
  }
}
