import 'package:flutter/material.dart';
import 'personal_data_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameSetupView extends StatefulWidget {
  const UsernameSetupView({super.key});

  @override
  State<UsernameSetupView> createState() => _UsernameSetupViewState();
}

class _UsernameSetupViewState extends State<UsernameSetupView> {
  final TextEditingController _usernameController = TextEditingController();

  void _onConfirm() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa un nombre de usuario')),
      );
      return;
    }

    CollectionReference collRef =
        FirebaseFirestore.instance.collection('cliente');

    collRef.add({
      'user_name': _usernameController,
    });

    print('Nombre de usuario confirmado: $username');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalDataView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Comencemos!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dinos cómo te gustaría que te conozcan los demás usuarios. Este nombre es único por cada uno de ellos, incluso para ti ^^',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Ej. SebasRiv29013',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E004F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
