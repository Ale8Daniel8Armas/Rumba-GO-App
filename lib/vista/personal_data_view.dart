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
    final rol = "cliente";

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
    print('Rol: $rol');

    final uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference collRef =
        FirebaseFirestore.instance.collection('cliente');

    collRef.doc(uid).set({
      'name': _namesController.text.trim(),
      'date': _dateController.text.trim(),
      'gender': _selectedGender,
      'email': _emailController.text.trim(),
      'rol': rol,
    }, SetOptions(merge: true));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InteresesView(),
      ),
    );
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('cliente').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _namesController.text = data['name'] ?? '';
          _dateController.text = data['date'] ?? '';
          _selectedGender = data['gender'];
          _emailController.text =
              data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                '¡Hola!',
                style: TextStyle(
                    fontFamily: 'Exo',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD824A6)),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Complete su perfil para obtener una mejor experiencia personalizada',
                  style: TextStyle(
                    fontFamily: 'Exo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        controller: _namesController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: const Icon(Icons.person),
                          border: const UnderlineInputBorder(),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.2),
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontWeight: FontWeight.w100,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre completo';
                          }
                          if (value.trim().length < 3 ||
                              !value.trim().contains(' ')) {
                            return 'Ingresa al menos un nombre y un apellido';
                          }
                          final regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s']+$");
                          if (!regex.hasMatch(value!)) {
                            return 'Solo se permiten letras y espacios';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const UnderlineInputBorder(),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.2),
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontWeight: FontWeight.w100,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Selecciona tu fecha de nacimiento';
                          }

                          try {
                            final birthDate =
                                DateFormat('yyyy-MM-dd').parseStrict(value);
                            final today = DateTime.now();
                            final age = today.year -
                                birthDate.year -
                                ((today.month < birthDate.month ||
                                        (today.month == birthDate.month &&
                                            today.day < birthDate.day))
                                    ? 1
                                    : 0);
                            if (age < 18) {
                              return 'Debes tener al menos 18 años';
                            }
                          } catch (e) {
                            return 'Fecha inválida';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      style: TextStyle(
                        fontFamily: 'Exo',
                        fontWeight: FontWeight.w100,
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'Género',
                        prefixIcon: const Icon(Icons.wc),
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email),
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.2),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Exo',
                        fontWeight: FontWeight.w100,
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
              style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
