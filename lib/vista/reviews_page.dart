import 'package:flutter/material.dart';

class ReviewView extends StatefulWidget {
  const ReviewView({super.key});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: const Center(
        child: Text(
          'Aquí irá el contenido de reseñas',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
