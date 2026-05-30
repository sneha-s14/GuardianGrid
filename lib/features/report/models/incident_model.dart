class IncidentModel { 
  final String id; 
  final double la tude; 
  final double longitude; 
  final String incidentType; 
  final String? descrip on; 
  final bool anonymous; 
  final DateTime createdAt; 
 
  IncidentModel({ 
    required this.id, 
    required this.la tude, 
    required this.longitude, 
    required this.incidentType, 
    this.descrip on, 
    required this.anonymous, 
    required this.createdAt, 
  }); 
 
  // Convert from Supabase JSON to Dart object 
  factory IncidentModel.fromJson(Map<String, dynamic> json) { 
    return IncidentModel( 
      id: json['id'], 
      la tude: json['la tude'], 
      longitude: json['longitude'], 
      incidentType: json['incident_type'], 
      descrip on: json['descrip on'], 
      anonymous: json['anonymous'] ?? true, 
      createdAt: DateTime.parse(json['created_at']), 
    ); 
  } 
}