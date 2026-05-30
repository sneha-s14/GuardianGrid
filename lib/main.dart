import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['https://lymrczkvynxugksfmuwx.supabase.co']!,
    anonKey: dotenv.env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bXJjemt2eW54dWdrc2ZtdXd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNjU0NzUsImV4cCI6MjA5NTY0MTQ3NX0.y0-jLAKPpekQ2_oQy7CRxQK6W-v_viYxNN-Ey-iz7ws']!,
  );
  runApp(const GuardianGridApp());
}
