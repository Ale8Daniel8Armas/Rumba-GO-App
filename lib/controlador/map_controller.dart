import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../modelo/LocalModel.dart';

class Map_Controller {
  final String _mapboxAccessToken =
      'pk.eyJ1IjoiYWxlam84OCIsImEiOiJjbWJyeXEzanUwZ2Z5MmpvcHJncWVwcDd3In0.zNADJQTAz8e-ovsG03dv3w';

  Future<List<LocalModel>> fetchLocales() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locales').get();
    return snapshot.docs.map((doc) => LocalModel.fromMap(doc.data())).toList();
  }

  /// Obtiene la ubicación actual del usuario, manejando permisos.
  Future<LatLng> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados.');
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  /// Encuentra el local más cercano a una ubicación dada.
  LocalModel? findNearestLocal(LatLng userLocation, List<LocalModel> locales) {
    if (locales.isEmpty) return null;
    const Distance distance = Distance();
    LocalModel? nearest;
    double minDist = double.infinity;

    for (var local in locales) {
      final dist =
          distance(userLocation, LatLng(local.latitud, local.longitud));
      if (dist < minDist) {
        minDist = dist;
        nearest = local;
      }
    }
    return nearest;
  }

  /// Obtiene la ruta de manejo entre dos puntos usando la API de Mapbox.
  Future<List<LatLng>> getRouteUsingMapbox(LatLng start, LatLng end) async {
    String profile = 'driving-traffic';
    String url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&access_token=$_mapboxAccessToken';

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      } else {
        // Devuelve un error más específico para que la UI pueda reaccionar
        throw Exception(
            'Error al obtener la ruta desde Mapbox: ${response.body}');
      }
    } catch (e) {
      throw Exception('Excepción al contactar la API de Mapbox: $e');
    }
  }
}
