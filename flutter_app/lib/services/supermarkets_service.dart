import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/app_state.dart';

class SupermarketsService {
  /// Ottiene la posizione corrente e cerca i supermercati nel raggio di 10km tramite Overpass API.
  static Future<List<SupermarketModel>?> fetchNearby(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se i servizi di localizzazione sono attivi
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError(context, "I servizi di localizzazione sono disabilitati. Attivali nelle impostazioni.");
      return null;
    }

    // 2. Verifica i permessi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError(context, "Permesso di localizzazione negato. Non possiamo cercare i supermercati.");
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showError(context, "I permessi di localizzazione sono negati permanentemente. Cambia le impostazioni del telefono.");
      return null;
    }

    try {
      // 3. Ottieni la posizione attuale
      // Su emulatore può bloccarsi all'infinito se la posizione non è mockata, quindi usiamo un timeout e un fallback
      Position? position = await Geolocator.getLastKnownPosition();
      
      try {
        position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 7),
        );
      } catch (e) {
        print("Timeout o errore GPS: \$e");
      }

      if (position == null) {
        _showError(context, "Impossibile ottenere la posizione. Attiva il GPS (o imposta la posizione sull'emulatore) e riprova.");
        return null;
      }

      // --- GOOGLE PLACES API CONFIGURATION ---
      // Inserisci qui la tua API Key di Google Cloud (deve avere abilitata l'API "Places API")
      const String googleApiKey = "INSERISCI_QUI_LA_TUA_API_KEY_MAPS";
      
      if (googleApiKey == "INSERISCI_QUI_LA_TUA_API_KEY_MAPS") {
        _showError(context, "API Key di Google Maps mancante! Aggiungila in supermarkets_service.dart");
        return null;
      }

      // 4. Esegui la richiesta a Google Places API (Nearby Search) nel raggio di 10km (10000 metri)
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=\${position.latitude},\${position.longitude}'
        '&radius=10000'
        '&type=supermarket'
        '&key=\$googleApiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        List<SupermarketModel> supermarkets = [];

        for (var place in results) {
          final name = place['name'] ?? "Supermercato sconosciuto";
          final address = place['vicinity'] ?? "Indirizzo non disponibile";
          
          final lat = place['geometry']['location']['lat'];
          final lon = place['geometry']['location']['lng'];

          // Calcola la distanza esatta usando Geolocator
          final distanceMeters = Geolocator.distanceBetween(
            position.latitude, position.longitude, lat, lon
          );
          
          String distanceText;
          if (distanceMeters < 1000) {
            distanceText = "\${distanceMeters.toStringAsFixed(0)}m";
          } else {
            distanceText = "\${(distanceMeters / 1000).toStringAsFixed(1)}km";
          }

          supermarkets.add(SupermarketModel(
            name: name,
            distance: distanceText,
            address: address,
          ));
        }

        // 5. Ordina dal più vicino al più lontano
        supermarkets.sort((a, b) {
          double distA = _parseDistance(a.distance);
          double distB = _parseDistance(b.distance);
          return distA.compareTo(distB);
        });

        // Limitiamo a max 20 risultati
        if (supermarkets.length > 20) {
          supermarkets = supermarkets.sublist(0, 20);
        }

        return supermarkets;
      } else {
        _showError(context, "Errore nella ricerca dei supermercati: \${response.statusCode}");
        return null;
      }
    } catch (e) {
      _showError(context, "Errore durante il recupero della posizione o dei dati.");
      return null;
    }
  }

  static double _parseDistance(String dist) {
    if (dist.endsWith('km')) {
      return double.parse(dist.replaceAll('km', '')) * 1000;
    } else if (dist.endsWith('m')) {
      return double.parse(dist.replaceAll('m', ''));
    }
    return 0.0;
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
