import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/app_state.dart';

class SupermarketsService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  static Future<List<SupermarketModel>?> fetchNearby(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      
      try {
        position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 7),
        );
      } catch (e) {
        print("Timeout o errore GPS: $e");
      }

      if (position == null) {
        return null;
      }

      // Overpass API Query
      final query = '''
      [out:json][timeout:25];
      (
        node["shop"="supermarket"](around:5000,${position.latitude},${position.longitude});
        way["shop"="supermarket"](around:5000,${position.latitude},${position.longitude});
      );
      out center;
      ''';

      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {
          'User-Agent': 'AvanziZeroApp/1.0',
          'Accept': '*/*',
        },
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<Map<String, dynamic>> tempSupermarkets = [];

        for (var el in elements) {
          final tags = el['tags'] ?? {};
          final name = tags['name'];
          
          if (name == null || name.toString().trim().isEmpty) continue;
          
          final lat = el['lat'] ?? el['center']?['lat'];
          final lon = el['lon'] ?? el['center']?['lon'];
          
          if (lat == null || lon == null) continue;

          final distanceInMeters = Geolocator.distanceBetween(
            position.latitude, position.longitude, lat as double, lon as double
          );

          String address = tags['addr:street'] != null 
            ? '${tags['addr:street']} ${tags['addr:housenumber'] ?? ''}' 
            : 'Indirizzo non disponibile';

          tempSupermarkets.add({
            'name': name,
            'distance': distanceInMeters,
            'address': address.trim(),
          });
        }

        // Ordina per distanza crescente
        tempSupermarkets.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        if (tempSupermarkets.length > 20) {
          tempSupermarkets = tempSupermarkets.sublist(0, 20);
        }

        return tempSupermarkets.map((data) {
          final dist = data['distance'] as double;
          String formattedDistance = dist < 1000 
            ? '${dist.round()}m' 
            : '${(dist / 1000).toStringAsFixed(1)}km';
            
          return SupermarketModel(
            name: data['name'],
            distance: formattedDistance,
            address: data['address'],
          );
        }).toList();

      } else {
        _showError(context, "Errore nella ricerca dei supermercati: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _showError(context, "Errore durante il recupero della posizione o dei dati.");
      return null;
    }
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
