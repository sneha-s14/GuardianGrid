import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/location_service.dart';
 
class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}
 
class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool sending = false; 
  // Animation for pulsing effect
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
 
  @override 
  void initState() { 
    super.initState(); 
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  } 
 
  @override 
  void dispose() { 
    _animCtrl.dispose(); 
    super.dispose(); 
  } 
 
  Future<void> triggerSOS() async { 
    // Vibrate the phone to confirm SOS 
    HapticFeedback.heavyImpact(); 
    setState(() => sending = true); 
 
    try { 
      final position = await LocationService.getCurrentLocation(); 
      if (position == null) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          const SnackBar(content: Text('Cannot get location for SOS')), 
        ); 
        return; 
      } 
 
      final userId = Supabase.instance.client.auth.currentUser?.id; 
 
      // Save SOS event to Supabase 
      await Supabase.instance.client.from('sos_events').insert({ 
        'user_id': userId, 
        'latitude': position.latitude, 
        'longitude': position.longitude, 
        'status': 'active', 
      }); 
      // Also send a panic crowd signal for heatmap 
      await Supabase.instance.client.from('crowd_signals').insert({ 
        'latitude': position.latitude, 
        'longitude': position.longitude, 
        'signal_type': 'panic', 
        'intensity': 1.0, 
      }); 
 
      if (mounted) { 
        showDialog( 
          context: context, 
          builder: (_) => AlertDialog( 
            backgroundColor: const Color(0xFF1A1A2E), 
            title: const Text('SOS Activated', 
                style: TextStyle(color: Colors.red)), 
            content: const Text( 
              'Your loca on has been shared with trusted contacts ' 
              'and safety services. Help is on the way.', 
              style: TextStyle(color: Colors.white), 
            ), 
            actions: [ 
              TextButton( 
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
        ScaleTransition( 
          scale: _scaleAnim, 
          child: GestureDetector( 
            onLongPress: triggerSOS, 
            child: Container( 
              width: 80, height: 80, 
              decoration: BoxDecoration( 
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