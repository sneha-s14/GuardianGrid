import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/location_service.dart';
import '../../../services/risk_api_service.dart';
import '../../../core/constants.dart';
import '../../sos/widgets/sos_button.dart';
import '../../report/screens/report_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Heatmap data points: each WeightedLatLng has a location + intensity
  List<WeightedLatLng> _heatmapPoints = [];
  double _currentRisk = 0.0;
  bool _loadingRisk = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
    _startLocationTracking();
    _subscribeToRealTimeUpdates();
  }

  // Load existing risk zones from Python API
  Future<void> _loadHeatmapData() async {
    final zones = await RiskApiService.fetchRiskZones();

    if (zones.isEmpty) {
      // Demo data around Bangalore for hackathon presentation
      setState(() {
        _heatmapPoints = [
          WeightedLatLng(const LatLng(12.9716, 77.5946), 0.9),
          WeightedLatLng(const LatLng(12.9352, 77.6101), 0.7),
          WeightedLatLng(const LatLng(12.9762, 77.5667), 0.6),
          WeightedLatLng(const LatLng(12.9900, 77.6201), 0.8),
          WeightedLatLng(const LatLng(12.9500, 77.5800), 0.5),
          WeightedLatLng(const LatLng(12.9610, 77.6490), 0.75),
          WeightedLatLng(const LatLng(12.9279, 77.6271), 0.65),
          WeightedLatLng(const LatLng(13.0100, 77.5500), 0.4),
        ];
      });
      return;
    }

    setState(() {
      _heatmapPoints = zones.map((zone) {
        return WeightedLatLng(
          LatLng(zone['latitude'], zone['longitude']),
          zone['risk_score'].toDouble(),
        );
      }).toList();
    });
  }

  // Listen for new incidents added in real time via Supabase
  void _subscribeToRealTimeUpdates() {
    Supabase.instance.client
        .from('incidents')
        .stream(primaryKey: ['id'])
        .listen((data) {
      if (data.isNotEmpty) {
        final newPoints = data.map((row) {
          return WeightedLatLng(
            LatLng(row['latitude'], row['longitude']),
            0.7,
          );
        }).toList();
        setState(() => _heatmapPoints = newPoints);
      }
    });
  }

  // Track user movement and update risk score
  void _startLocationTracking() {
    LocationService.getLocationStream().listen((position) async {
      if (_loadingRisk) return;
      setState(() => _loadingRisk = true);
      final score = await RiskApiService.getRiskScore(
          position.latitude, position.longitude);
      setState(() {
        _currentRisk = score;
        _loadingRisk = false;
      });
    });
  }

  Color get _riskColor {
    if (_currentRisk > 0.7) return const Color(0xFFFF4757);
    if (_currentRisk > 0.4) return const Color(0xFFFFB142);
    return const Color(0xFF2ED573);
  }

  String get _riskLabel {
    if (_currentRisk > 0.7) return 'HIGH RISK AREA';
    if (_currentRisk > 0.4) return 'MODERATE RISK';
    return 'SAFE AREA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── THE MAP ──────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(
                AppConstants.defaultLat,
                AppConstants.defaultLng,
              ),
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [

              // Base map tiles from OpenStreetMap — free, no token
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.guardian.grid',
                // Dark-looking tile style (free alternative)
                additionalOptions: const {},
              ),

              // Heatmap layer on top of the base map
              if (_heatmapPoints.isNotEmpty)
                HeatMapLayer(
                  heatMapDataSource:
                      InMemoryHeatMapDataSource(data: _heatmapPoints),
                  heatMapOptions: HeatMapOptions(
                    radius: 60,
                    layerOpacity: 0.7,
                    gradient: const {
                      0.2: Colors.green,
                      0.5: Colors.yellow,
                      0.7: Colors.orange,
                      1.0: Colors.red,
                    },
                  ),
                ),
            ],
          ),

          // ── TOP STATUS BAR ────────────────────────────────────
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // App title bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield, color: Color(0xFF6C63FF)),
                      SizedBox(width: 8),
                      Text('GuardianGrid',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16)),
                      Spacer(),
                      Text('LIVE',
                          style: TextStyle(
                              color: Color(0xFF2ED573),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFF2ED573)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Risk level pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _riskColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location,
                          color: _riskColor, size: 14),
                      const SizedBox(width: 6),
                      Text(_riskLabel,
                          style: TextStyle(
                              color: _riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                          '${(_currentRisk * 100).toInt()}% risk',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── LEGEND ────────────────────────────────────────────
          Positioned(
            top: 180,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Risk Level',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  _LegendDot(color: Color(0xFFFF4757), label: 'High'),
                  _LegendDot(color: Color(0xFFFFB142), label: 'Medium'),
                  _LegendDot(color: Color(0xFF2ED573), label: 'Low'),
                ],
              ),
            ),
          ),

          // ── REPORT BUTTON ─────────────────────────────────────
          Positioned(
            bottom: 160,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ReportScreen()),
              ),
              backgroundColor: const Color(0xFF6C63FF),
              icon: const Icon(Icons.report_outlined,
                  color: Colors.white),
              label: const Text('Report',
                  style: TextStyle(color: Colors.white)),
            ),
          ),

          // ── SOS BUTTON ────────────────────────────────────────
          const Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(child: SOSButton()),
          ),
        ],
      ),
    );
  }
}

// Small colored dot for legend
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
