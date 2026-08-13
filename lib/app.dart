import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';

class CoutelyaApp extends StatelessWidget {
  const CoutelyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COUTELYA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}
