import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'map_view.dart';
import 'reviews_page.dart';
import 'profile_view.dart';
import 'mini_formulario.dart';
import 'nuevo_local_view.dart';
import 'review_form_view.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(),
      body: const Center(
        child: Text(
          'Aquí irá el contenido de contactos',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

//barra de navegacion inferior
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
            GestureDetector(
              onTap: () {
                MiniFormulario.mostrar(
                  context: context,
                  onResenaPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewFormView()),
                    );
                  },
                  onLocalPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NuevoLocalView()),
                    );
                  },
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFD824A6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
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
              padding: const EdgeInsets.only(top: 4),
              icon: const Icon(
                Icons.person,
                color: Color(0xFFB1FBFF),
                size: 55,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
