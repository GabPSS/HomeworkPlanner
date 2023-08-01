import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:homeworkplanner/global_settings.dart';
import 'package:homeworkplanner/ui/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static getHelp() {
    launchUrl(Uri.parse("https://github.com/GabPSS/HomeworkPlanner"));
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GlobalSettings settings = GlobalSettings();
  late Future<void> settingsInitFuture;

  @override
  void initState() {
    settingsInitFuture = settings.initSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
            theme: ThemeData(colorScheme: lightDynamic),
            darkTheme: ThemeData(colorScheme: darkDynamic),
            home: FutureBuilder(
                future: settingsInitFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return HomePage(settings: settings);
                  } else {
                    return const Scaffold(
                        body: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [CircularProgressIndicator()]));
                  }
                }));
      },
    );
  }
}
