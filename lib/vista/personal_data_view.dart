import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'intereses_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({super.key});

  @override
  State<PersonalDataView> createState() => _PersonalDataView();
}

class _PersonalDataView extends State<PersonalDataView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = [
    'Masculino',
    'Femenino',
    'No binario',
    'Prefiero no decirlo',
    'Otro'
  ];

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: 'Selecciona tu fecha de nacimiento',
        locale: const Locale("es", "ES"),
      );

      if (picked != null) {
        setState(() {
          _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    } catch (e) {
      final manualController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ingresa tu fecha de nacimiento'),
          content: TextField(
            controller: manualController,
            decoration: const InputDecoration(
              hintText: 'Formato: yyyy-MM-dd',
              labelText: 'Fecha de nacimiento',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = manualController.text.trim();
                try {
                  final parsedDate =
                      DateFormat('yyyy-MM-dd').parseStrict(input);
                  setState(() {
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(parsedDate);
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Formato inválido. Usa yyyy-MM-dd')),
                  );
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() != true) return;

    final name = _namesController.text.trim();
    final birthdate = _dateController.text.trim();
    final gender = _selectedGender;
    final email = _emailController.text.trim();

    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un género')),
      );
      return;
    }

    print('Datos ingresados:');
    print('Nombre: $name');
    print('Fecha de nacimiento: $birthdate');
    print('Género: $gender');
    print('Email: $email');

    final uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference collRef =
        FirebaseFirestore.instance.collection('cliente');

    collRef.doc(uid).set({
      'name': _namesController.text.trim(),
      'date': _dateController.text.trim(),
      'gender': _selectedGender,
      'email': _emailController.text.trim(),
    }, SetOptions(merge: true));

    //Este es el boton para ir a la siguiente ruta
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InteresesView(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FFFF),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                '¡Hola!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete su perfil para obtener una mejor experiencia personalizada',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _namesController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecciona tu fecha de nacimiento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                items: _genders
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Género',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Correo no disponible';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E004F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
