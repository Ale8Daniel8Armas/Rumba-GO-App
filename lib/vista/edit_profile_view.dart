import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'profile_view.dart';
import 'map_view.dart';
import 'reviews_page.dart';
import 'contacts_page.dart';
import 'nuevo_local_view.dart';
import 'locales_usuario_view.dart';
import 'mini_formulario.dart';
import 'review_form_view.dart';

class PerfilEditableView extends StatefulWidget {
  const PerfilEditableView({super.key});

  @override
  State<PerfilEditableView> createState() => _PerfilEditableViewState();
}

class _PerfilEditableViewState extends State<PerfilEditableView> {
  bool isEditing = false;
  bool _esPropietario = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('cliente')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nombreController.text = data['name'] ?? '';
          _fechaController.text = data['date'] ?? '';
          _generoController.text = data['gender'] ?? '';
          _correoController.text = user.email ?? '';
          _descripcionController.text = data['description'] ?? '';
          _facebookController.text = data['facebook'] ?? '';
          _instagramController.text = data['instagram'] ?? '';
          _twitterController.text = data['twitter'] ?? '';
          _esPropietario = data['rol'] == 'propietario';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('cliente')
          .doc(user.uid)
          .update({
        'name': _nombreController.text.trim(),
        'date': _fechaController.text.trim(),
        'gender': _generoController.text.trim(),
        'description': _descripcionController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'twitter': _twitterController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente.')),
      );

      setState(() {
        isEditing = false;
      });
    }
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool editable = true}) {
    const TextStyle fieldTextStyle = TextStyle(
      fontFamily: 'Exo',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD824A6),
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            isEditing && editable
                ? TextFormField(
                    controller: controller,
                    maxLines: label == 'Descripción personal' ? 3 : 1,
                    style: fieldTextStyle,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      controller.text.isNotEmpty ? controller.text : ' ',
                      style: fieldTextStyle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    const TextStyle fieldTextStyle = TextStyle(
      fontFamily: 'Exo',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fecha de Nacimiento',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD824A6),
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            isEditing
                ? TextFormField(
                    controller: _fechaController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: fieldTextStyle,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _fechaController.text.isNotEmpty
                          ? _fechaController.text
                          : ' ',
                      style: fieldTextStyle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    const TextStyle fieldTextStyle = TextStyle(
      fontFamily: 'Exo',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Género',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD824A6),
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            isEditing
                ? DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _generoController.text.isEmpty
                        ? null
                        : _generoController.text,
                    style: fieldTextStyle,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(bottom: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    items: [
                      'Masculino',
                      'Femenino',
                      'No binario',
                      'Prefiero no decirlo',
                      'Otro'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _generoController.text = value ?? '';
                      });
                    },
                  )
                : Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _generoController.text.isNotEmpty
                          ? _generoController.text
                          : ' ',
                      style: fieldTextStyle,
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Datos Personales',
            style: TextStyle(
              color: Color(0xFFD824A6),
              fontFamily: 'Exo',
              fontSize: 28,
              fontWeight: FontWeight.w800,
            )),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilView(),
                ),
              );
            }),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField('Nombre y Apellidos', _nombreController),
              _buildDateField(),
              _buildGenderField(),
              _buildEditableField('Correo', _correoController, editable: false),
              _buildEditableField(
                  'Descripción personal', _descripcionController),
              _buildEditableField('Facebook', _facebookController),
              _buildEditableField('Instagram', _instagramController),
              _buildEditableField('Twitter', _twitterController),
              if (isEditing)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 150,
                    decoration: BoxDecoration(
                      color: Color(0xFFD824A6),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '¿Eres un propietario o tienes tu local?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              //Botón de registro del negocio o local de entretenimiento
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0036),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NuevoLocalView()),
                    );
                  },
                  icon: const Icon(Icons.store_mall_directory_rounded,
                      color: Colors.white),
                  label: const Text(
                    'Registra tu negocio',
                    style: TextStyle(
                      fontFamily: 'Exo',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              //Botón de revisión de los negocios del propietario
              const SizedBox(height: 14),
              if (_esPropietario)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 213, 231, 229),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 203, 233, 30)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LocalesUsuarioView()),
                          );
                        },
                        icon: const Icon(Icons.local_mall_rounded,
                            color: Color.fromARGB(255, 109, 175, 230)),
                        label: const Text(
                          'Gestiona tus locales',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 2, 230, 247),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: const Color.fromARGB(255, 54, 52, 52),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _fechaController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_fechaController.text)
            : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: 'Selecciona tu fecha de nacimiento',
        locale: const Locale("es", "ES"),
      );

      if (picked != null) {
        setState(() {
          _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = manualController.text.trim();
                try {
                  final parsedDate =
                      DateFormat('yyyy-MM-dd').parseStrict(input);
                  setState(() {
                    _fechaController.text =
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
