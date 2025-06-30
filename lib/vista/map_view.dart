import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controlador/map_controller.dart';
import '../modelo/LocalModel.dart';
import 'profile_view.dart';
import 'reviews_page.dart';
import 'contacts_page.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final self_controller = Map_Controller();

  List<LocalModel> _locales = [];
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  bool _isLoadingRoute = false;

  LatLng _mapCenter = LatLng(-0.314708, -78.442473);

  final mapBoxToken =
      'pk.eyJ1IjoiYWxlam84OCIsImEiOiJjbWJyeXEzanUwZ2Z5MmpvcHJncWVwcDd3In0.zNADJQTAz8e-ovsG03dv3w';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      final userLocationFuture = self_controller.getUserLocation();
      final localesFuture = self_controller.fetchLocales();

      _userLocation = await userLocationFuture;
      _locales = await localesFuture;

      final nearestLocal =
          self_controller.findNearestLocal(_userLocation!, _locales);

      if (nearestLocal != null) {
        // Calcula la ruta inicial hacia el local más cercano
        await _getRouteAndDraw(nearestLocal);
      }

      // Mueve la cámara a la ubicación del usuario
      _mapCenter = _userLocation!;
      _mapController.move(_mapCenter, 14.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getRouteAndDraw(LocalModel targetLocal) async {
    if (_userLocation == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final route = await self_controller.getRouteUsingMapbox(
          _userLocation!, LatLng(targetLocal.latitud, targetLocal.longitud));

      if (mounted) {
        setState(() {
          _routePoints = route;
          // Centrar y ajustar el zoom para que se vea toda la ruta
          _mapController.fitCamera(CameraFit.coordinates(
            coordinates: [
              _userLocation!,
              LatLng(targetLocal.latitud, targetLocal.longitud)
            ],
            padding: const EdgeInsets.all(50.0),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No se pudo calcular la ruta: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  void _showLocalInfo(LocalModel local) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(local.nombre,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(local.descripcion,
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            local.fotosUrls.isNotEmpty
                ? Image.network(local.fotosUrls.first,
                    height: 150, fit: BoxFit.cover)
                : Image.asset('assets/img/local_placeholder.png', height: 150),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _getRouteAndDraw(local);
              },
              icon: const Icon(Icons.directions),
              label: const Text("Ver ruta"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB1FBFF),
                foregroundColor: Colors.purple[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                additionalOptions: {'accessToken': mapBoxToken},
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.purpleAccent,
                    ),
                  ],
                ),
              // Dibuja los marcadores si ya se cargó la ubicación
              if (!_isLoading)
                MarkerLayer(markers: [
                  Marker(
                    point: _userLocation!,
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 45),
                  ),
                  // Mapea los locales a marcadores
                  ..._locales.map((local) => Marker(
                        point: LatLng(local.latitud, local.longitud),
                        child: GestureDetector(
                          onTap: () => _showLocalInfo(local),
                          child: const Icon(Icons.location_on,
                              color: Colors.pink, size: 40),
                        ),
                      )),
                ]),
            ],
          ),

          // --- Indicadores de Carga ---
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_isLoadingRoute)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar lugares cercanos',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.purple[900]),
                  suffixIcon: Icon(Icons.send, color: Colors.purple[900]),
                ),
              ),
            ),
          ),
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                FilterChipWidget(label: 'Bares'),
                FilterChipWidget(label: 'Discotecas'),
                FilterChipWidget(label: 'Karaokes'),
              ],
            ),
          ),
          /*Positioned(
            bottom: 140,
            right: 15,
            child: ZoomControl(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
          ),*/
        ],
      ),
      bottomNavigationBar: _CustomBottomNavBar(),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  const FilterChipWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.pink[100],
      label: Text(label, style: TextStyle(color: Colors.purple[900])),
    );
  }
}

class ZoomControl extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomControl(
      {super.key, required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: "zoom_in",
          mini: true,
          backgroundColor: Colors.purple[900],
          onPressed: onZoomIn,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: "zoom_out",
          mini: true,
          backgroundColor: Colors.purple[900],
          onPressed: onZoomOut,
          child: const Icon(Icons.remove, color: Colors.white),
        ),
      ],
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.purple[900],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ReviewView())),
            ),
            IconButton(
              icon: const Icon(Icons.photo, color: Color(0xFFB1FBFF), size: 50),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const MapView())),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFD824A6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ContactsView())),
            ),
            IconButton(
              padding: const EdgeInsets.only(top: 4),
              icon:
                  const Icon(Icons.person, color: Color(0xFFB1FBFF), size: 55),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PerfilView())),
            ),
          ],
        ),
      ),
    );
  }
}
