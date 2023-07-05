import 'package:flutter/material.dart';
import 'package:homeworkplanner/global_settings.dart';
import 'package:homeworkplanner/ui/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

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
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
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
  }
}
