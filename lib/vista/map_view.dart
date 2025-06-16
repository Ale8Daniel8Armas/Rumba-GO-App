import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//clases adicionales para enlace de botones del bottom navbar
import 'profile_view.dart';
import 'reviews_page.dart';
import 'contacts_page.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final mapBoxToken =
      'pk.eyJ1IjoiYWxlam84OCIsImEiOiJjbWJyeXEzanUwZ2Z5MmpvcHJncWVwcDd3In0.zNADJQTAz8e-ovsG03dv3w';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              //latitud espe -0.314708, -78.442473
              initialCenter: LatLng(-0.314708, -78.442473),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                additionalOptions: {
                  'accessToken': mapBoxToken,
                },
                userAgentPackageName: 'com.tuapp.nombre',
              ),
            ],
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
              children: [
                FilterChipWidget(label: 'Bares'),
                FilterChipWidget(label: 'Discotecas'),
                FilterChipWidget(label: 'Karaokes'),
              ],
            ),
          ),
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

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.purple[900],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewView()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo, color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: Colors.pinkAccent, size: 40),
              onPressed: () {
                // acción futura
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactsView()),
                );
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.person, color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
