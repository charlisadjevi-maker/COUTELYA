import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/auth_screens.dart';

class CoutelyaApp extends StatelessWidget {
  const CoutelyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COUTELYA',
      theme: CoutelyaTheme.light,
      home: const SplashScreen(),
    );
  }
}
