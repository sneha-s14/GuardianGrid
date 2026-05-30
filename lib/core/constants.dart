import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['https://lymrczkvynxugksfmuwx.supabase.co'] ?? '';
  static String get supabaseAnonKey => dotenv.env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bXJjemt2eW54dWdrc2ZtdXd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNjU0NzUsImV4cCI6MjA5NTY0MTQ3NX0.y0-jLAKPpekQ2_oQy7CRxQK6W-v_viYxNN-Ey-iz7ws'] ?? '';
  static String get pythonApiUrl => dotenv.env['http://10.0.2.2:8000'] ?? '';

  // Bangalore city center
  static const double defaultLat = 12.9716;
  static const double defaultLng = 77.5946;
}
