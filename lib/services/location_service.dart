import 'package:geolocator/geolocator.dart'; 
 
class LocationService { 
  // Call this once when app starts 
  static Future<bool> requestPermission() async { 
    final serviceEnabled = await Geolocator.isLocationServiceEnabled(); 
    if (!serviceEnabled) return false; 
 
    LocationPermission permission = await Geolocator.checkPermission(); 
    if (permission == LocationPermission.denied) { 
      permission = await Geolocator.requestPermission(); 
    } 
    return permission != LocationPermission.denied && 
        permission != LocationPermission.deniedForever; 
  } 
 
  // Get current GPS posi on once 
  static Future<Position?> getCurrentLocation() async { 
    final hasPermission = await requestPermission(); 
    if (!hasPermission) return null; 
    return await Geolocator.getCurrentPosition( 
      desiredAccuracy: LocationAccuracy.high, 
    ); 
  } 
 
  // Stream of loca on updates (for live tracking) 
  static Stream<Position> getLocationStream() { 
    return Geolocator.getPositionStream( 
        locationSettings: const LocationSettings( 
        accuracy: LocationAccuracy.high, 
        distanceFilter: 15, // update every 15 meters 
      ), 
    ); 
  } 
}