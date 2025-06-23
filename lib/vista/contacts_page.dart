import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text(
          'Aquí irá el contenido de contactos',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
