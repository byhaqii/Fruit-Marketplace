import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBL Semester5',
      theme: AppTheme.light(),
      initialRoute: Routes.initial,
      routes: Routes.routes,
    );
  }
}
