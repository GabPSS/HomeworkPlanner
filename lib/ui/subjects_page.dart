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
          return ListTile(
            leading: const Icon(Icons.assignment_ind),
            title: Text(host.saveFile.Subjects.Items[index].SubjectName),
          );
        },
        itemCount: host.saveFile.Subjects.Items.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            //TODO: Swap this out when add function is implemented
            // host.saveFile.Subjects.add("Hello!");
            host.saveFile.Subjects.Items.add(Subject(SubjectName: "Hello", SubjectID: 5));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
