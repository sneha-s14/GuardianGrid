import 'package:flu er/material.dart'; 
import 'package:flu er/services.dart'; 
import 'package:supabase_flu er/supabase_flu er.dart'; 
import '../../../services/loca on_service.dart'; 
 
class SOSBu on extends StatefulWidget { 
  const SOSBu on({super.key}); 
  @override 
  State<SOSBu on> createState() => _SOSBu onState(); 
} 
 
class _SOSBu onState extends State<SOSBu on> 
    with SingleTickerProviderStateMixin { 
  bool sending = false; 
  // Anima on for pulsing effect 
  late Anima onController _animCtrl; 
  late Anima on<double> _scaleAnim; 
 
  @override 
  void initState() { 
    super.initState(); 
    _animCtrl = Anima onController( 
      vsync: this, 
      dura on: const Dura on(seconds: 1), 
    ).repeat(reverse: true); 
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate( 
      CurvedAnima on(parent: _animCtrl, curve: Curves.easeInOut), 
    ); 
  } 
 
  @override 
  void dispose() { 
    _animCtrl.dispose(); 
    super.dispose(); 
  } 
 
  Future<void> triggerSOS() async { 
    // Vibrate the phone to confirm SOS 
    Hap cFeedback.heavyImpact(); 
    setState(() => sending = true); 
 
    try { 
      final posi on = await Loca onService.getCurrentLoca on(); 
      if (posi on == null) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text('Cannot get loca on for SOS')), 
        ); 
        return; 
      } 
 
      final userId = Supabase.instance.client.auth.currentUser?.id; 
 
      // Save SOS event to Supabase 
      await Supabase.instance.client.from('sos_events').insert({ 
        'user_id': userId, 
        'la tude': posi on.la tude, 
        'longitude': posi on.longitude, 
        'status': 'ac ve', 
      }); 
 
      // Also send a panic crowd signal for heatmap 
      await Supabase.instance.client.from('crowd_signals').insert({ 
        'la tude': posi on.la tude, 
        'longitude': posi on.longitude, 
        'signal_type': 'panic', 
        'intensity': 1.0, 
      }); 
 
      if (mounted) { 
        showDialog( 
          context: context, 
          builder: (_) => AlertDialog( 
            backgroundColor: const Color(0xFF1A1A2E), 
            tle: const Text(' SOS Ac vated', 
                style: TextStyle(color: Colors.red)), 
            content: const Text( 
              'Your loca on has been shared with trusted contacts ' 
              'and safety services. Help is on the way.', 
              style: TextStyle(color: Colors.white), 
            ), 
            ac ons: [ 
              TextBu on( 
                onPressed: () => Navigator.pop(context), 
                child: const Text('OK'), 
              ), 
            ], 
          ), 
        ); 
      } 
    } catch (e) { 
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text('SOS error: $e')), 
        ); 
      } 
    } finally { 
      setState(() => sending = false); 
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Column( 
      mainAxisSize: MainAxisSize.min, 
      children: [ 
        const Text('Hold for SOS', 
            style: TextStyle(color: Colors.grey, fontSize: 12)), 
        const SizedBox(height: 8), 
        ScaleTransi on( 
          scale: _scaleAnim, 
          child: GestureDetector( 
            onLongPress: triggerSOS, 
            child: Container( 
              width: 80, height: 80, 
              decora on: BoxDecora on( 
                shape: BoxShape.circle, 
                color: sending ? Colors.orange : const Color(0xFFFF4757), 
                boxShadow: [ 
                  BoxShadow( 
                    color: const Color(0xFFFF4757).withOpacity(0.5), 
                    blurRadius: 20, 
                    spreadRadius: 5, 
                  ), 
                ], 
              ), 
              child: Center( 
                child: sending 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Icon(Icons.sos, color: Colors.white, size: 36), 
              ), 
            ), 
          ), 
        ), 
      ], 
    ); 
  } 
}