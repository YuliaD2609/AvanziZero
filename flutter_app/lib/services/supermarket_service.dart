import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/app_state.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
}

class SupermarketService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<SupermarketModel>> getNearbySupermarkets({double radiusInMeters = 3000}) async {
    try {
      final position = await _determinePosition();
      
      final query = '''
      [out:json][timeout:25];
      (
        node["shop"="supermarket"](around:$radiusInMeters,${position.latitude},${position.longitude});
        way["shop"="supermarket"](around:$radiusInMeters,${position.latitude},${position.longitude});
      );
      out center;
      ''';

      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<SupermarketModel> supermarkets = [];

        for (var el in elements) {
          final tags = el['tags'] ?? {};
          final name = tags['name'] ?? 'Supermercato';
          
          final lat = el['lat'] ?? el['center']?['lat'];
          final lon = el['lon'] ?? el['center']?['lon'];
          
          if (lat == null || lon == null) continue;

          final distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            lat as double,
            lon as double,
          );

          String address = tags['addr:street'] != null 
            ? '${tags['addr:street']} ${tags['addr:housenumber'] ?? ''}' 
            : 'Indirizzo non disponibile';

          String formattedDistance = distanceInMeters < 1000 
            ? '${distanceInMeters.round()}m' 
            : '${(distanceInMeters / 1000).toStringAsFixed(1)}km';

          supermarkets.add(SupermarketModel(
            name: name,
            distance: formattedDistance,
            address: address.trim(),
          ));
        }

        // Sort by distance (since formattedDistance is a string, we sort by parsing or we can just sort by real distance if we store it. Let's sort manually here)
        // Since we didn't store raw distance in model, let's just parse it back or sort before formatting.
        // Wait, better to sort elements before formatting:
        // Re-implementing correctly:
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
