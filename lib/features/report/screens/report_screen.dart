import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/location_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedType = 'harassment';
  final _descCtrl = TextEditingController();
  bool _anonymous = true;
  bool _submitting = false;

  // All incident types users can choose from
  final _types = {
    'harassment': 'Harassment',
    'theft': 'Theft/Robbery',
    'poor_lighting': 'Poor Lighting',
    'unsafe_crowd': 'Unsafe Crowd',
    'suspicious_activity': 'Suspicious Activity',
    'other': 'Other',
  }; 
 
  Future<void> _submitReport() async {
    setState(() => _submitting = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
        return;
      }

      final userId = _anonymous
          ? null
          : Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client.from('incidents').insert({
        'user_id': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'incident_type': _selectedType,
        'description': _descCtrl.text.isEmpty ? null : _descCtrl.text,
        'anonymous': _anonymous,
      }); 
 
      if (mounted) { 
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar( 
            content: Text('Report submitted. Helping keep the city safer!'), 
            backgroundColor: Color(0xFF2ED573), 
          ), 
        ); 
      } 
    } catch (e) { 
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red), 
        ); 
      } 
    } finally { 
      setState(() => _submitting = false); 
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Report Incident')), 
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            const Text('What happened?', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 12), 
            Wrap( 
              spacing: 8, 
              runSpacing: 8, 
              children: _types.entries.map((entry) { 
                final isSelected = _selectedType == entry.key; 
                return GestureDetector( 
                  onTap: () => setState(() => _selectedType = entry.key), 
                  child: Container( 
                    padding: const EdgeInsets.symmetric( 
                        horizontal: 12, vertical: 8), 
                    decoration: BoxDecoration( 
                      color: isSelected 
                          ? const Color(0xFF6C63FF) 
                          : const Color(0xFF1A1A2E), 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all( 
                        color: isSelected 
                            ? const Color(0xFF6C63FF) 
                            : Colors.grey.withOpacity(0.3), 
                      ), 
                    ), 
                    child: Text(entry.value, 
                        style: TextStyle( 
                          color: isSelected ? Colors.white : Colors.grey, 
                        )), 
                  ), 
                ); 
              }).toList(), 
            ), 
            const SizedBox(height: 24), 
            const Text('Additional Details (optional)', 
                style: TextStyle(fontWeight: FontWeight.w500)), 
            const SizedBox(height: 8), 
            TextField( 
              controller: _descCtrl, 
              maxLines: 3, 
              style: const TextStyle(color: Colors.white), 
              decoration: const InputDecoration( 
                hintText: 'Describe what happened...', 
              ), 
            ), 
            const SizedBox(height: 16), 
            Container( 
              decoration: BoxDecoration( 
                color: const Color(0xFF1A1A2E), 
                borderRadius: BorderRadius.circular(12), 
              ), 
              child: SwitchListTile( 
                title: const Text('Submit Anonymously'), 
                subtitle: const Text('Your identity will not be shared', 
                    style: TextStyle(fontSize: 12, color: Colors.grey)), 
                value: _anonymous, 
                activeColor: const Color(0xFF6C63FF), 
                onChanged: (v) => setState(() => _anonymous = v), 
              ), 
            ), 
            const SizedBox(height: 24), 
            SizedBox( 
              width: double.infinity, 
              child: ElevatedButton.icon( 
                onPressed: _submitting ? null : _submitReport, 
                icon: _submitting 
                    ? const SizedBox(width: 20, height: 20, 
                        child: CircularProgressIndicator( 
                            color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.send), 
                label: Text(_submitting ? 'Submitting...' : 'Submit Report'), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
}