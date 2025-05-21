import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_view.dart';

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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
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
            ],
          ),
        ),
      ),
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
