import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/database/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase.instance.database;

  if (Env.supabaseEnabled) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
  }

  runApp(const CoutelyaApp());
}
