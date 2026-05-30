import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class RiskApiService {
  // Fetch all risk zones for heatmap
  static Future<List<Map<String, dynamic>>> fetchRiskZones() async {
    try {
      final url = Uri.parse('${AppConstants.pythonApiUrl}/risk-zones');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5), // don't wait forever
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('RiskApiService error: $e');
    }
    // Return empty list if API not reachable
    return [];
  }

  // Get risk score for a specific location
  static Future<double> getRiskScore(double lat, double lng) async {
    try {
      final url = Uri.parse('${AppConstants.pythonApiUrl}/risk/predict');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'latitude': lat, 'longitude': lng}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['risk_score'] as num).toDouble();
      }
    } catch (e) {
      print('Risk score error: $e');
    }
    return 0.0; // default to safe if API fails
  }
}
 