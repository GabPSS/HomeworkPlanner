import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  late SharedPreferences _preferences;

  List<String> get recentFiles {
    if (enableRecentFiles) {
      return _preferences.getStringList('recents') ?? List.empty();
    } else {
      return List.empty();
    }
  }

  set recentFiles(value) {
    _preferences.setStringList('recents', value);
  }

  bool get enableRecentFiles =>
      _preferences.getBool('enableRecentFiles') ?? true;
  set enableRecentFiles(value) {
    _preferences.setBool('enableRecentFiles', value);
  }

  bool mobileLayout = Platform.isAndroid || Platform.isIOS;

  Future<void> initSettings() async {
    _preferences = await SharedPreferences.getInstance();
  }

  void addRecentFile(String fileName) => _updateRecentFiles(fileName, false);

  void removeRecentFile(String fileName) => _updateRecentFiles(fileName, true);

  void _updateRecentFiles(String fileName, bool remove) {
    if (enableRecentFiles) {
      List<String> recents = recentFiles.cast<String>().toList(growable: true);
      if (recents.contains(fileName)) {
        recents.remove(fileName);
      }
      if (!remove) {
        recents.add(fileName);
      }
      recentFiles = recents;
    }
  }
}
