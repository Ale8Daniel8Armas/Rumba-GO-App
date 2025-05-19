import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.camera_alt_outlined,
                  size: 40, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              '@SebasRiv29013',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Soy una persona muy extrovertida',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(FontAwesomeIcons.facebook, size: 24),
                SizedBox(width: 20),
                Icon(FontAwesomeIcons.instagram, size: 24),
                SizedBox(width: 20),
                Icon(FontAwesomeIcons.twitter, size: 24),
              ],
            ),
            const SizedBox(height: 30),
            _ListTileProfile(
              icon: Icons.edit,
              text: 'Editar',
              color: Colors.blue,
              onTap: () {},
            ),
            _ListTileProfile(
              icon: Icons.star,
              text: 'Apariencia',
              color: Colors.blueAccent,
              onTap: () {},
            ),
            _ListTileProfile(
              icon: Icons.logout,
              text: 'Salir',
              color: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileProfile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ListTileProfile({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          onTap: onTap,
        ),
        const Divider(thickness: 1),
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.emoji_emotions_outlined, color: Colors.white),
            Icon(Icons.photo, color: Colors.white),
            Icon(Icons.add_circle, color: Colors.pinkAccent, size: 40),
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
