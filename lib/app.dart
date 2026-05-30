import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/map/screens/mapscreen.dart';

class GuardianGridApp extends StatelessWidget {
  const GuardianGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: 'GuardianGrid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: session != null ? const MapScreen() : const LoginScreen(),
    );
  }
}
