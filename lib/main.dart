import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'pages/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainShell(),
    );
  }
}
