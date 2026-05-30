class IncidentModel { 
  final String id; 
  final double latitude; 
  final double longitude; 
  final String incidentType; 
  final String? description; 
  final bool anonymous; 
  final DateTime createdAt; 
 
  IncidentModel({ 
    required this.id, 
    required this.latitude, 
    required this.longitude, 
    required this.incidentType, 
    this.description, 
    required this.anonymous, 
    required this.createdAt, 
  }); 
 
  // Convert from Supabase JSON to Dart object 
  factory IncidentModel.fromJson(Map<String, dynamic> json) { 
    return IncidentModel( 
      id: json['id'], 
      latitude: (json['latitude'] as num).toDouble(), 
      longitude: json['longitude'], 
      incidentType: json['incident_type'], 
      description: json['description'] as String?, 
      anonymous: json['anonymous'] ?? true, 
      createdAt: DateTime.parse(json['created_at']), 
    ); 
  } 
}