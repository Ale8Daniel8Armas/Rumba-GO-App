import 'package:flutter/material.dart';
import 'personal_data_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameSetupView extends StatefulWidget {
  const UsernameSetupView({super.key});

  @override
  State<UsernameSetupView> createState() => _UsernameSetupViewState();
}

class _UsernameSetupViewState extends State<UsernameSetupView> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isValid = false;

  void _validateUsername(String value) {
    setState(() {
      _isValid = value.trim().length >= 6 && value.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      _validateUsername(_usernameController.text);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa un nombre de usuario')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference collRef =
        FirebaseFirestore.instance.collection('cliente');

    collRef.doc(uid).set({
      'user_name': _usernameController.text.trim(),
    }, SetOptions(merge: true));

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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('¡Comencemos!',
                        style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD824A6))),
                  ),
                  Center(
                    child: SizedBox(
                      width: 390,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          const Text(
                            'Dinos cómo te gustaría que te conozcan los demás usuarios. Este nombre es único por cada uno de ellos, incluso para ti ^^',
                            style: TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Ej. SebasRiv29013',
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                              ),
                              suffixIcon: Icon(
                                _isValid ? Icons.check_circle : Icons.cancel,
                                color: _isValid ? Colors.green : Colors.red,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: 390,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0036),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _onConfirm,
                  label: const Text(
                    'Siguiente',
                    style: TextStyle(
                      fontFamily: 'Exo',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
