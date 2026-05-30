import 'package:geolocator/geolocator.dart'; 
 
class Loca onService { 
  // Call this once when app starts 
  sta c Future<bool> requestPermission() async { 
    bool serviceEnabled = await Geolocator.isLoca onServiceEnabled(); 
    if (!serviceEnabled) return false; 
 
    Loca onPermission permission = await Geolocator.checkPermission(); 
    if (permission == Loca onPermission.denied) { 
      permission = await Geolocator.requestPermission(); 
    } 
    return permission != Loca onPermission.denied && 
        permission != Loca onPermission.deniedForever; 
  } 
 
  // Get current GPS posi on once 
  sta c Future<Posi on?> getCurrentLoca on() async { 
    final hasPermission = await requestPermission(); 
    if (!hasPermission) return null; 
    return await Geolocator.getCurrentPosi on( 
      desiredAccuracy: Loca onAccuracy.high, 
    ); 
  } 
 
  // Stream of loca on updates (for live tracking) 
  sta c Stream<Posi on> getLoca onStream() { 
    return Geolocator.getPosi onStream( 
        loca onSe ngs: const Loca onSe ngs( 
        accuracy: Loca onAccuracy.high, 
        distanceFilter: 15, // update every 15 meters 
      ), 
    ); 
  } 
}