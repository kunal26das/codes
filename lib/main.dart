import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const AlgoScopeApp());

class AlgoScopeApp extends StatefulWidget {
  const AlgoScopeApp({super.key});

  @override
  State<AlgoScopeApp> createState() => _AlgoScopeAppState();
}

class _AlgoScopeAppState extends State<AlgoScopeApp> {
  // Follow the OS appearance by default; the app-bar button lets the user
  // override to an explicit Light or Dark and back to System.
  ThemeMode _mode = ThemeMode.system;

  void _cycleTheme() {
    setState(() {
      _mode = switch (_mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlgoScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: HomeScreen(
        themeMode: _mode,
        onCycleTheme: _cycleTheme,
      ),
    );
  }
}
