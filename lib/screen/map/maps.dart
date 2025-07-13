import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:dio/dio.dart';
import 'package:web_flutter/widget/loader/model/gps_itineraire.dart';

class Maps extends StatefulWidget {
  static String routeName = "/maps";
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  String location = "";
  Position? position;
  List<LatLng>? itineraireList;
  LatLng pointArrivee = LatLng(5.3862285, -3.9827405);
  LatLng? current;

  @override
  void dispose() {
    super.dispose();
  }

  // Exemple de fonction pour décoder
  List<LatLng> decodePolyline(String encoded) {
    final PolylinePoints polylinePoints = PolylinePoints();
    final List<PointLatLng> result = polylinePoints.decodePolyline(encoded);
    return result.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }

  Future<void> _getPosition() async {
    deboger("Chargement");
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => location = "Service de localisation désactivé.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => location = "Permission refusée.");

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => location = "Permission refusée définitivement.");
        return;
      }

      position = await Geolocator.getCurrentPosition();
      setState(() {
        location =
            "Latitude: ${position!.latitude}, Longitude: ${position!.longitude}";
        current = LatLng(position!.latitude, position!.longitude);
        getItineraire(current!, pointArrivee).then((value) {
          itineraireList = value;
          setState(() {});
        });
      });
    } catch (e) {
      setState(() => location = "Erreur : $e");
    }
  }

  Future<List<LatLng>> getItineraire(LatLng start, LatLng end) async {
    const apiKey = "5b3ce3597851110001cf624842782ffa3bdf4ca5bf52e00106e060a0";
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey';

    final body = {
      "coordinates": [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    };
    try {
      final response = await Dio().post(url, data: json.encode(body));
      // deboger([response.data, response.extra, response.statusCode]);
      if (response.statusCode == 200) {
        final data = GpsResponse.fromJson(response.data);
        deboger(data);

        return decodePolyline(data.routes![0].geometry!);
      } else {
        throw Exception("Échec du chargement de l'itinéraire");
      }
    } catch (e) {
      deboger(e);
      throw Exception("Échec du chargement de l'itinéraire");
    }
  }

  @override
  void initState() {
    super.initState();
    _getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          position == null
              ? Center(child: CircularProgress())
              : FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    position!.latitude,
                    position!.longitude,
                  ), // Center the map over London
                  initialZoom: 18,
                ),
                children: [
                  TileLayer(
                    // Bring your own tiles
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
                    userAgentPackageName:
                        'com.example.app', // Add your app identifier
                    // And many more recommended properties!
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(position!.latitude, position!.longitude),
                        child: CircleIcon(image: Icons.location_pin),
                      ),
                      Marker(
                        point: pointArrivee,
                        width: 80,
                        height: 80,
                        child: Icon(Icons.location_pin, color: Colors.red),
                      ),
                    ],
                  ),
                  if (itineraireList != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points:
                              itineraireList!, // Liste de LatLng depuis getItineraire()
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                ],
              ),
    );
  }
}
