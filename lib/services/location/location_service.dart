import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permissions are denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  /// Get formatted address from coordinates
  /// Returns a formatted string like "Malappuram, Kerala"
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string with city and state
        List<String> addressParts = [];
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        if (addressParts.isEmpty) {
          // Fallback to country if no other info available
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }
        }

        return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
      }

      return 'Unknown Location';
    } catch (e) {
      throw Exception('Failed to get address: ${e.toString()}');
    }
  }

  /// Get current location with formatted address
  /// Returns a Map with position and formatted address
  Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      final Position position = await getCurrentPosition();
      final String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'position': position,
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      throw Exception('Failed to get current location: ${e.toString()}');
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

