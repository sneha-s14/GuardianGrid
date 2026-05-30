import 'dart:convert'; 
import 'package:h p/h p.dart' as h p; 
import '../core/constants.dart'; 
 
class RiskApiService { 
  // Fetch all risk zones for heatmap 
  sta c Future<List<Map<String, dynamic>>> fetchRiskZones() async { 
    try { 
      final url = Uri.parse('${AppConstants.pythonApiUrl}/risk-zones'); 
      final response = await h p.get(url). meout( 
        const Dura on(seconds: 5), // don't wait forever 
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
 
  // Get risk score for a specific loca on 
  sta c Future<double> getRiskScore(double lat, double lng) async { 
    try { 
      final url = Uri.parse('${AppConstants.pythonApiUrl}/risk/predict'); 
      final response = await h p.post( 
        url, 
        headers: {'Content-Type': 'applica on/json'}, 
        body: jsonEncode({'la tude': lat, 'longitude': lng}), 
      ). meout(const Dura on(seconds: 5)); 
 
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