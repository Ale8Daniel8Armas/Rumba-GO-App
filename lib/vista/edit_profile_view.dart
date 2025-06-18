import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_view.dart';
import 'map_view.dart';
import 'reviews_page.dart';
import 'contacts_page.dart';

class PerfilEditableView extends StatefulWidget {
  const PerfilEditableView({super.key});

  @override
  State<PerfilEditableView> createState() => _PerfilEditableViewState();
}

class _PerfilEditableViewState extends State<PerfilEditableView> {
  bool isEditing = false;

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
          _descripcionController.text = data['descripcion'] ?? '';
          _facebookController.text = data['facebook'] ?? '';
          _instagramController.text = data['instagram'] ?? '';
          _twitterController.text = data['twitter'] ?? '';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 4),
        isEditing && editable
            ? TextFormField(
                controller: controller,
                maxLines: label == 'Descripción personal' ? 5 : 1,
                maxLength: label == 'Descripción personal' ? null : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: label == 'Descripción personal'
                    ? (value) {
                        final wordCount =
                            value.trim().split(RegExp(r'\s+')).length;
                        if (wordCount > 100) {
                          final trimmed = value
                              .trim()
                              .split(RegExp(r'\s+'))
                              .sublist(0, 100)
                              .join(' ');
                          controller.text = trimmed;
                          controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: trimmed.length));
                        }
                      }
                    : null,
              )
            : Text(
                controller.text,
                style: const TextStyle(color: Colors.black87),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('         Datos Personales',
            style: TextStyle(color: Colors.purple)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.purple),
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
            icon: Icon(isEditing ? Icons.close : Icons.edit,
                color: Colors.purple),
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
              _buildEditableField('Fecha de Nacimiento', _fechaController),
              _buildEditableField('Género', _generoController),
              _buildEditableField('Correo', _correoController, editable: false),
              _buildEditableField(
                  'Descripción personal', _descripcionController),
              _buildEditableField('Facebook', _facebookController),
              _buildEditableField('Instagram', _instagramController),
              _buildEditableField('Twitter', _twitterController),
              if (isEditing)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                '¿Eres un propietario o tienes tu local?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Exo',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: Container(
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
                      // Acción al presionar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Funcionalidad próximamente disponible.')),
                      );
                    },
                    icon: const Icon(Icons.store_mall_directory_rounded,
                        color: Colors.white),
                    label: const Text(
                      'Registra tu negocio',
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
                // Acción del botón aquí
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
