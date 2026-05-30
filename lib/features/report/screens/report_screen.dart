import 'package:flu er/material.dart'; 
import 'package:supabase_flu er/supabase_flu er.dart'; 
import '../../../services/loca on_service.dart'; 
 
class ReportScreen extends StatefulWidget { 
  const ReportScreen({super.key}); 
  @override 
  State<ReportScreen> createState() => _ReportScreenState(); 
} 
 
class _ReportScreenState extends State<ReportScreen> { 
  String _selectedType = 'harassment'; 
  final _descCtrl = TextEdi ngController(); 
  bool _anonymous = true; 
  bool _submi ng = false; 
 
  // All incident types users can choose from 
  final _types = { 
    'harassment': ' Harassment', 
    'the ': ' The /Robbery', 
    'poor_ligh ng': ' Poor Ligh ng', 
    'unsafe_crowd': ' Unsafe Crowd', 
    'suspicious_ac vity': ' Suspicious Ac vity', 
    'other': ' Other', 
  }; 
 
  Future<void> _submitReport() async { 
    setState(() => _submi ng = true); 
    try { 
      final posi on = await Loca onService.getCurrentLoca on(); 
      if (posi on == null) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text('Could not get loca on')), 
        ); 
        return; 
      } 
 
      final userId = _anonymous 
          ? null 
          : Supabase.instance.client.auth.currentUser?.id; 
 
      await Supabase.instance.client.from('incidents').insert({ 
        'user_id': userId, 
        'la tude': posi on.la tude, 
        'longitude': posi on.longitude, 
        'incident_type': _selectedType, 
        'descrip on': _descCtrl.text.isEmpty ? null : _descCtrl.text, 
        'anonymous': _anonymous, 
      }); 
 
      if (mounted) { 
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar( 
            content: Text(' Report submi ed. Helping keep the city safer!'), 
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
      setState(() => _submi ng = false); 
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( tle: const Text('Report Incident')), 
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
                        horizontal: 12, ver cal: 8), 
                    decora on: BoxDecora on( 
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
            const Text('Addi onal Details (op onal)', 
                style: TextStyle(fontWeight: FontWeight.w500)), 
            const SizedBox(height: 8), 
            TextField( 
              controller: _descCtrl, 
              maxLines: 3, 
              style: const TextStyle(color: Colors.white), 
              decora on: const InputDecora on( 
                hintText: 'Describe what happened...', 
              ), 
            ), 
            const SizedBox(height: 16), 
            Container( 
              decora on: BoxDecora on( 
                color: const Color(0xFF1A1A2E), 
                borderRadius: BorderRadius.circular(12), 
              ), 
              child: SwitchListTile( 
                tle: const Text('Submit Anonymously'), 
                sub tle: const Text('Your iden ty will not be shared', 
                    style: TextStyle(fontSize: 12, color: Colors.grey)), 
                value: _anonymous, 
                ac veColor: const Color(0xFF6C63FF), 
                onChanged: (v) => setState(() => _anonymous = v), 
              ), 
            ), 
            const SizedBox(height: 24), 
            SizedBox( 
              width: double.infinity, 
              child: ElevatedBu on.icon( 
                onPressed: _submi ng ? null : _submitReport, 
                icon: _submi ng 
                    ? const SizedBox(width: 20, height: 20, 
                        child: CircularProgressIndicator( 
                            color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.send), 
                label: Text(_submi ng ? 'Submi ng...' : 'Submit Report'), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
}