import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/helperfunctions.dart';
import 'package:homeworkplanner/main.dart';
import 'package:homeworkplanner/models/main/day_note.dart';
import 'package:homeworkplanner/models/main/subject.dart';
import 'package:homeworkplanner/models/main/task.dart';
import 'package:homeworkplanner/ui/note_dialog.dart';
import 'package:homeworkplanner/ui/reports_page.dart';
import 'package:homeworkplanner/ui/schedules_page.dart';
import 'package:homeworkplanner/ui/subjects_page.dart';
import 'package:homeworkplanner/ui/task_page.dart';
import 'package:homeworkplanner/models/tasksystem/save_file.dart';
import 'package:intl/intl.dart';

import '../models/tasksystem/task_host.dart';

class MainPage extends StatefulWidget {
  final TaskHost host;

  const MainPage({super.key, required this.host});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late TaskHost host;
  AppBar? appBar;
  BottomNavigationBar? bottomNav;
  int bottomNavSelectedIndex = 0;
  bool onMobile = false;
  bool onTablet = false;
  CarouselController mobileCarouselController = CarouselController();
  int mobileCarouselTodayPageOffset = 10000;
  bool _setCarouselPageToToday = false;
  late List<DateTime> mobileDaysDisplayedList;
  bool _displayDesktopLayout = false;

  bool get displayDesktopLayout => onTablet ? onTablet : _displayDesktopLayout;
  set displayDesktopLayout(bool value) => _displayDesktopLayout = value;

  @override
  void initState() {
    onMobile = widget.host.settings.mobileLayout;
    host = widget.host;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onTablet = !HelperFunctions.getIsPortrait(context);
    Widget currentPage;
    if (onMobile) {
      appBar = buildMobileAppBar();
    }
    if (onMobile && !onTablet) {
      bottomNav = buildAndroidBottomNav();
      switch (bottomNavSelectedIndex) {
        case 0:
          currentPage = buildPlannerViewPanel();
          break;
        case 1:
          currentPage = Expanded(child: buildAllTasksPanel());
          break;
        default:
          throw UnimplementedError('Page not implemented');
      }
    } else {
      bottomNav = null;
      currentPage = Expanded(
        child: Row(
          children: [
            buildPlannerViewPanel(),
            Expanded(
              flex: 1,
              child: buildAllTasksPanel(),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createTask();
        },
        child: const Icon(Icons.assignment_add),
      ),
      body: Column(
        children: [buildDesktopMenuBar(context), currentPage],
      ),
    );
  }

  Widget buildAllTasksPanel() {
    List<Task> tasks =
        TaskHost.sortTasks(host.saveFile.Settings.sortMethod, allTasks);

    List<Widget> widgets = List.empty(growable: true);
    widgets.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
          "All tasks (${tasks.where((element) => !element.IsCompleted).length})"),
    ));

    for (Task task in tasks) {
      widgets.add(buildTaskWidget(task));
    }

    return ListView(children: widgets);
  }

  List<Task> get allTasks => host.saveFile.Tasks.Items
      .where((element) =>
          host.saveFile.Settings.DisplayPreviousTasks ||
          !(element.IsCompleted &&
              element.DateCompleted!.isBefore(HelperFunctions.getToday())))
      .toList();

  Widget _buildTaskWidget(Task task, [bool compact = false]) {
    String taskTitle;
    String dueDateString = (task.DueDate != null
        ? "Due ${DateFormat.yMMMd().format(task.DueDate!)}"
        : "No due date");

    String subjectPrefix = (Subject.isIdValid(task.SubjectID, host)
        ? "${host.getSubjectNameById(task.SubjectID)} - "
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
          context: context, host: host, task: task, onTaskUpdated: updateTasks);
    }

    if (compact) {
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
                      decoration: task.IsCompleted
                          ? TextDecoration.lineThrough
                          : null)),
              Text(dueDateString, style: TextStyle(color: tileColor))
            ],
          ),
        ),
      );
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
          icon: task.GetIcon()),
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

  Widget buildTaskWidget(Task task, [bool compact = false]) {
    var listTile = _buildTaskWidget(task, compact);
    return onMobile && !onTablet
        ? listTile
        : LongPressDraggable(
            data: task,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: task.GetIcon(),
            child: listTile,
            onDragStarted: () => setState(() {
              task.ExecDate = null;
              if (onMobile) {
                bottomNavSelectedIndex = 0;
              }
            }),
          );
  }

  Widget buildPlannerViewPanel() {
    if (!onMobile || displayDesktopLayout) {
      List<Widget> rows = List.empty(growable: true);
      List<Widget> days = List.empty(growable: true);
      List<DateTime> tmpDaysDisplayed;
      List<Widget> tmpDayWidgets;
      List<Widget> cols;
      mobileDaysDisplayedList = List.empty(growable: true);

      int rowCount = host.saveFile.Settings.FutureWeeks + 1;

      DateTime selectedDay = HelperFunctions.getThisSaturday();

      for (int row = 0; row < rowCount; row++) {
        cols = List.empty(growable: true);
        tmpDayWidgets = List.empty(growable: true);
        tmpDaysDisplayed = List.empty(growable: true);

        selectedDay = HelperFunctions.iterateThroughWeekFromDate(
          host.saveFile.Settings.DaysToDisplay.toDouble(),
          selectedDay,
          (date) {
            var dateWidget =
                buildTaskListForDate(date, !onMobile || displayDesktopLayout);
            cols.add(dateWidget);
            tmpDayWidgets.add(dateWidget);
            tmpDaysDisplayed.add(date);
          },
        ).add(const Duration(days: 14));

        cols = cols.reversed.cast<Widget>().toList(growable: true);
        days.addAll(tmpDayWidgets.reversed);
        mobileDaysDisplayedList.addAll(tmpDaysDisplayed.reversed);
        rows.add(Expanded(child: Row(children: cols)));
      }

      return Expanded(flex: 2, child: Column(children: rows));
    } else {
      mobileCarouselTodayPageOffset = 10000;
      var carousel = Expanded(
          child: CarouselSlider.builder(
              carouselController: mobileCarouselController,
              itemCount: 1,
              itemBuilder: (context, index, realIndex) {
                if (_setCarouselPageToToday) {
                  mobileCarouselTodayPageOffset = realIndex;
                  _setCarouselPageToToday = false;
                }
                return buildTaskListForDate(
                    HelperFunctions.getToday().add(Duration(
                        days: realIndex - mobileCarouselTodayPageOffset)),
                    !onMobile || displayDesktopLayout);
              },
              options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  viewportFraction: 1,
                  height: MediaQuery.of(context).size.height,
                  enableInfiniteScroll: true)));
      return carousel;
    }
  }

  Widget buildTaskListForDate(DateTime selectedDay, [bool expanded = true]) {
    List<DayNote> cancelledNotes = host.getNotesForDate(selectedDay, true);

    List<Task> tasksForDate = TaskHost.sortTasks(
        host.saveFile.Settings.sortMethod,
        host.getTasksPlannedForDate(selectedDay));
    Iterable<Task> tasksCompletedForDate =
        tasksForDate.where((element) => element.IsCompleted);

    Widget header = buildTaskListHeader(
        selectedDay,
        tasksCompletedForDate.length,
        tasksForDate.length,
        cancelledNotes.isNotEmpty);

    if (cancelledNotes.isNotEmpty) {
      var widgets = <Widget>[header].toList(growable: true);
      widgets
          .addAll(buildDayNoteWidgets(cancelledNotes, () => setState(() {})));
      var cancelWidget = Column(
        children: widgets,
      );
      return expanded ? Expanded(child: cancelWidget) : cancelWidget;
    }

    List<Widget> taskWidgets = List.empty(growable: true);

    taskWidgets.add(header);

    taskWidgets.addAll(tasksForDate
        .map<Widget>(
            (task) => buildTaskWidget(task, !onMobile || displayDesktopLayout))
        .toList());

    Widget taskListWidget = DragTarget(
      builder: (context, candidateData, rejectedData) {
        return ListView(
          children: taskWidgets,
        );
      },
      onAccept: (data) {
        setState(() {
          if (data is Task) {
            data.ExecDate = HelperFunctions.getDateFromDateTime(selectedDay);
          }
        });
      },
    );
    return expanded ? Expanded(child: taskListWidget) : taskListWidget;
  }

  Widget buildTaskListHeader(
      DateTime selectedDay, int completedTasksCount, int tasksCount,
      [bool isCancelled = false]) {
    bool isToday = selectedDay == HelperFunctions.getToday();
    FontWeight dayFontWeight = isToday ? FontWeight.bold : FontWeight.normal;

    String titleSuffix = isCancelled
        ? " - Cancelled"
        : isToday
            ? ' ($completedTasksCount/$tasksCount)'
            : '';

    String mobileTitleSuffix = isCancelled
        ? "Cancelled"
        : "$completedTasksCount/$tasksCount task${completedTasksCount != 1 ? "s" : ""} completed";

    double taskCompletionPercent = isCancelled
        ? 0
        : (tasksCount != 0 ? completedTasksCount / tasksCount : 0);

    List<DayNote> notesForDate = host.getNotesForDate(selectedDay);

    if (onMobile && !displayDesktopLayout) {
      var mobileHeaderChildren = <Widget>[
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(selectedDay.day.toString(),
                  style: TextStyle(fontSize: 42, fontWeight: dayFontWeight)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM').format(selectedDay),
                  style: TextStyle(fontWeight: dayFontWeight),
                ),
                Text(
                  DateFormat('yyyy').format(selectedDay),
                  style: TextStyle(fontWeight: dayFontWeight),
                ),
              ],
            ),
            const Spacer(),
            taskCompletionPercent == 1
                ? const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.done_all,
                      color: Colors.white,
                    ),
                  )
                : taskCompletionPercent == 0
                    ? const Icon(null)
                    : CircularProgressIndicator(
                        color: Colors.green,
                        value: taskCompletionPercent,
                      ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(mobileTitleSuffix),
            ),
          ],
        ),
      ].toList(growable: true);

      if (notesForDate.isNotEmpty) {
        mobileHeaderChildren
            .addAll(buildDayNoteWidgets(notesForDate, () => setState(() {})));
      }

      mobileHeaderChildren.add(const Divider(height: 1));
      return Column(
        children: mobileHeaderChildren,
      );
    } else {
      TextButton notesButton = TextButton(
          onPressed: () => showDesktopNotesDialog(notesForDate),
          child: Text(
              "${notesForDate.length} ${notesForDate.length == 1 ? 'note' : 'notes'}"));

      List<Widget> headerRowChildren = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${selectedDay.day}/${selectedDay.month}$titleSuffix",
            style: TextStyle(fontWeight: dayFontWeight),
          ),
        ),
      ].toList(growable: true);

      if (notesForDate.isNotEmpty) {
        headerRowChildren.add(notesButton);
      }

      return Row(
        children: headerRowChildren,
      );
    }
  }

  Iterable<Widget> buildDayNoteWidgets(List<DayNote> notesForDate,
          [Function()? onUpdate]) =>
      notesForDate.map((note) => buildDayNoteListTile(note, onUpdate));

  Widget buildDayNoteListTile(DayNote note, [Function()? onUpdate]) {
    return ListTile(
      leading: Icon(note.Cancelled ? Icons.error_outline : Icons.lightbulb),
      title: Text(note.Message),
      onTap: () {
        var dialog = NoteDialog(
          host,
          note: note,
          onUpdate: onUpdate,
        );
        dialog.show(context);
      },
    );
  }

  AppBar buildMobileAppBar() {
    var saveButton = IconButton(
        onPressed: () => host.save(context), icon: const Icon(Icons.save));
    List<Widget> plannerActions = <Widget>[saveButton].toList(growable: true);

    var taskListActions = <Widget>[saveButton].toList(growable: true);

    if (onMobile) {
      var shareButton = IconButton(
          onPressed: () => host.share(context), icon: const Icon(Icons.share));
      plannerActions.add(shareButton);
      taskListActions.add(shareButton);
    }

    if (!onTablet) {
      plannerActions.add(IconButton(
          onPressed: () => setState(() {
                _setCarouselPageToToday = true;
                // mobileCarouselController.jumpToPage(1);
              }),
          icon: const Icon(Icons.today)));
      plannerActions.add(IconButton(
          onPressed: () =>
              setState(() => displayDesktopLayout = !displayDesktopLayout),
          icon: Icon(displayDesktopLayout
              ? Icons.calendar_view_day
              : Icons.calendar_view_month)));
    }

    var popupMenuButton = PopupMenuButton(
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'note',
          child: Text('Add note'),
        ),
        PopupMenuItem(
          value: 'subjects',
          child: Text('Subjects'),
        ),
        PopupMenuItem(
          value: 'schedules',
          child: Text('Schedules'),
        ),
        PopupMenuItem(
          value: 'report',
          child: Text('Task report'),
        ),
        PopupMenuItem(
          value: 'about',
          child: Text('About'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'note':
            addNote();
            break;
          case 'subjects':
            SubjectsPage.show(context, host, () => setState(() {}));
            break;
          case 'schedules':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SchedulesPage(host: host)));
            break;
          case 'report':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportsPage(host: host)));
            break;
          case 'about':
            showAbout(context);
            break;
          default:
        }
      },
    );

    plannerActions.add(popupMenuButton);
    taskListActions.add(popupMenuButton);

    List<Widget>? actionButtons;
    switch (bottomNavSelectedIndex) {
      case 0:
        actionButtons = plannerActions;
        break;
      case 1:
        actionButtons = taskListActions;
        break;
      default:
        actionButtons = null;
        break;
    }

    return AppBar(
      title: Text(HelperFunctions.getFileNameFromPath(
          host.saveFilePath ?? "Untitled plan")),
      actions: actionButtons,
    );
  }

  BottomNavigationBar buildAndroidBottomNav() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: "Planner"),
        BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined), label: 'Tasks')
      ],
      currentIndex: bottomNavSelectedIndex,
      onTap: (value) {
        setState(() {
          bottomNavSelectedIndex = value;
        });
      },
    );
  }

  Row buildDesktopMenuBar(BuildContext context) {
    if (onMobile) {
      return const Row();
    } else {
      List<MenuItemButton> recentFilesList = host.settings.recentFiles
          .map((e) => MenuItemButton(
                child: Text(HelperFunctions.getFileNameFromPath(e)),
                onPressed: () => TaskHost.openFile(context, host.settings,
                    (newHost) => setState(() => host = newHost), e),
              ))
          .toList()
          .reversed
          .toList();
      return Row(
        children: [
          Expanded(
            child: MenuBar(
              children: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: createSaveFile,
                      child: const Text('New'),
                    ),
                    MenuItemButton(
                      onPressed: openFile,
                      child: const Text('Open...'),
                    ),
                    const MenuItemButton(
                      child: Text('Import...'),
                    ),
                    SubmenuButton(
                        menuChildren: recentFilesList,
                        child: const Text('Recent files')),
                    MenuItemButton(
                        onPressed: () => setState(() => host.save(context)),
                        child: const Text('Save')),
                    MenuItemButton(
                        onPressed: () => setState(() => host.saveAs(context)),
                        child: const Text('Save as...')),
                    MenuItemButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context)),
                    const MenuItemButton(child: Text('Exit'))
                  ],
                  child: const Text('File'),
                ),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                    onPressed: createTask,
                    child: const Text('New...'),
                  ),
                  const MenuItemButton(child: Text('Import...')),
                  MenuItemButton(
                    child: const Text('Unschedule all'),
                    onPressed: () => unscheduleAll(context),
                  ),
                  SubmenuButton(menuChildren: [
                    MenuItemButton(
                      child: const Text('Completed'),
                      onPressed: () => removeCompleted(context),
                    ),
                    MenuItemButton(
                      child: const Text('Everything'),
                      onPressed: () => removeAllTasks(context),
                    )
                  ], child: const Text('Remove tasks'))
                ], child: const Text('Tasks')),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                    child: const Text('Add note...'),
                    onPressed: () => addNote(),
                  )
                ], child: const Text('Notes')),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                      child: const Text('Report...'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportsPage(host: host),
                          ))),
                  MenuItemButton(
                    child: const Text('Subjects...'),
                    onPressed: () {
                      SubjectsPage.show(context, host, updateTasks);
                    },
                  ),
                  MenuItemButton(
                    child: const Text('Clean up...'),
                    onPressed: () => cleanUp(context),
                  ),
                  MenuItemButton(
                      child: const Text('Class schedules...'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SchedulesPage(host: host))))
                ], child: const Text('Tools')),
                SubmenuButton(menuChildren: [
                  MenuItemButton(
                    child: const Text('Get help...'),
                    onPressed: () => MainApp.getHelp(),
                  ),
                  MenuItemButton(
                      child: const Text('About...'),
                      onPressed: () => showAbout(context))
                ], child: const Text('About'))
              ],
            ),
          ),
        ],
      );
    }
  }

  void showAbout(BuildContext context) {
    return showAboutDialog(
        context: context,
        applicationName: 'HomeworkPlanner',
        applicationLegalese: '(C) Gabriel P. 2023');
  }

  void createTask() {
    Task task = Task();
    setState(() {
      host.saveFile.Tasks.Add(task);
    });
    TaskEditor.show(
        context: context,
        task: task,
        host: host,
        onTaskUpdated: updateTasks,
        isAdding: true);
  }

  void createSaveFile() => setState(
      () => host = TaskHost(settings: host.settings, saveFile: SaveFile()));

  void openFile() => TaskHost.openFile(
      context, host.settings, (newHost) => setState(() => host = newHost));

  void updateTasks({bool showMessage = false}) {
    setState(() {});
    if (showMessage) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Updated tasks')));
    }
  }

  void unscheduleAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unschedule all tasks?'),
        content: const Text(
            "This will clear all of your task schedules, so you can replan everything. \n\nNOTE: This will NOT delete any tasks."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => host.unscheduleAllTasks());
              },
              child: const Text('Unschedule')),
        ],
      ),
    );
  }

  void removeAllTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all tasks?'),
        content: const Text(
            "This will clear all of your tasks, but keep everything else. \n\nWARNING: This PERMANENTLY DELETE all tasks scheduled."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => host.removeAllTasks());
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  void removeCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all completed tasks?'),
        content: const Text(
            "This will clear all of your completed tasks, but keep everything else. \n\nWARNING: This PERMANENTLY DELETE all matching tasks."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => host.removeCompletedTasks());
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  void cleanUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perform cleanup?'),
        content: const Text(
            "This action will clean up the save file internally, in order to make it easier to manually modify if necessary.\n\nThis does not visually affect any tasks or schedules."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => host.cleanUp());
              },
              child: const Text('Clean up')),
        ],
      ),
    );
  }

  void addNote() {
    NoteDialog(host, onUpdate: () => setState(() {})).show(context);
  }

  void showDesktopNotesDialog(List<DayNote> notes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notes.length.toString() +
              (notes.length == 1 ? ' note' : ' notes')),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                  children: buildDayNoteWidgets(notes, () => setState(() {}))
                      .toList());
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Close'))
          ],
        );
      },
    );
  }
}
