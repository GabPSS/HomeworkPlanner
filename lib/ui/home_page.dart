import 'package:flutter/material.dart';
import 'package:homeworkplanner/global_settings.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/main.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:homeworkplanner/models/tasksystem/task_host.dart';
import 'package:homeworkplanner/ui/main_page.dart';

class HomePage extends StatefulWidget {
  final GlobalSettings settings;

  const HomePage({super.key, required this.settings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    bool isMobile =
        HelperFunctions.getIsPortrait(context) && widget.settings.mobileLayout;

    List<IconButton>? appBarMobileActions = isMobile
        ? [
            IconButton(
                onPressed: () => TaskHost.openFile(
                    context, widget.settings, (host) => openApp(context, host)),
                icon: const Icon(Icons.folder_open))
          ]
        : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeworkPlanner'),
        actions: appBarMobileActions,
      ),
      body: isMobile ? buildRecentFilesWidget() : buildDesktopLayout(context),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => openApp(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Row buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: buildRecentFilesWidget()),
        Expanded(child: buildDesktopActionsColumn(context))
      ],
    );
  }

  Column buildDesktopActionsColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('Quick actions'),
        ),
        ListTile(
          leading: const Icon(Icons.note_add),
          title: const Text('Create new plan...'),
          onTap: () => openApp(context),
        ),
        ListTile(
          leading: const Icon(Icons.file_open),
          title: const Text('Open file...'),
          onTap: () {
            TaskHost.openFile(
              context,
              widget.settings,
              (host) => openApp(context, host),
            );
          },
        ),
        const ListTile(
          leading: Icon(Icons.cloud),
          title: Text('Open remote file...'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('Get help'),
        ),
        ListTile(
          leading: const Icon(Icons.web),
          title: const Text('HomeworkPlanner website...'),
          onTap: () => MainApp.getHelp(),
        ),
      ],
    );
  }

  Future<dynamic> openApp(BuildContext context, [TaskHost? host]) {
    host ??= TaskHost(settings: widget.settings, saveFile: SaveFile());

    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(host: host!),
        ));
  }

  Widget buildRecentFilesWidget() {
    Widget recentFilesWidget;

    List<String> recentFiles = widget.settings.recentFiles;
    if (recentFiles.isNotEmpty) {
      List<Widget> recentFilesWidgets = List.empty(growable: true);

      recentFilesWidgets.add(const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Recent files'),
      ));
      recentFilesWidgets.addAll(recentFiles
          .map((e) => ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(HelperFunctions.getFileNameFromPath(e)),
                subtitle: Text(e),
                onTap: () => TaskHost.openFile(context, widget.settings,
                    (host) => openApp(context, host), e),
              ))
          .toList()
          .reversed);

      recentFilesWidget = ListView(
        children: recentFilesWidgets,
      );
    } else {
      recentFilesWidget = const Center(child: Text('No recent files'));
    }

    return recentFilesWidget;
  }
}
