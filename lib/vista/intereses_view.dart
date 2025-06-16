import 'package:flutter/material.dart';
import 'profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personal_data_view.dart';

class InteresesView extends StatefulWidget {
  const InteresesView({super.key});

  @override
  State<InteresesView> createState() => _InteresesViewState();
}

class _InteresesViewState extends State<InteresesView> {
  final List<String> _selectedInterests = [];
  final int _minSelections = 3;

  final List<Map<String, dynamic>> _musicOptions = [
    {'label': 'Rock', 'selected': false},
    {'label': 'Pop', 'selected': false},
    {'label': 'Electrónica', 'selected': false},
    {'label': 'Jazz', 'selected': false},
    {'label': 'Clásica', 'selected': false},
    {'label': 'Reggaetón', 'selected': false},
    {'label': 'Rap', 'selected': false},
  ];

  final List<Map<String, dynamic>> _ambienceOptions = [
    {'label': 'Tranquilo', 'selected': false},
    {'label': 'Animado', 'selected': false},
    {'label': 'Elegante', 'selected': false},
    {'label': 'Informal', 'selected': false},
    {'label': 'Romántico', 'selected': false},
    {'label': 'Familiar', 'selected': false},
  ];

  final List<Map<String, dynamic>> _drinksOptions = [
    {'label': 'Cerveza', 'selected': false},
    {'label': 'Cócteles', 'selected': false},
    {'label': 'Vino', 'selected': false},
    {'label': 'Café', 'selected': false},
    {'label': 'Sin alcohol', 'selected': false},
    {'label': 'Gin', 'selected': false},
  ];

  void _toggleInterest(String category, int index) {
    final option = _getCategoryOptions(category)[index];
    final isSelected = option['selected'];
    final label = option['label'];

    setState(() {
      if (isSelected) {
        option['selected'] = false;
        _selectedInterests.remove(label);
      } else {
        option['selected'] = true;
        _selectedInterests.add(label);
      }
    });
  }

  List<Map<String, dynamic>> _getCategoryOptions(String category) {
    switch (category) {
      case 'music':
        return _musicOptions;
      case 'ambience':
        return _ambienceOptions;
      case 'drinks':
        return _drinksOptions;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalDataView()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Intereses',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Elige lo que quieres ver o qué tipos de lugares de entretenimiento te gustaría encontrar',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            _buildCategorySection(
              icon: Icons.music_note,
              title: 'Tipo de música',
              category: 'music',
              options: _musicOptions,
            ),
            const SizedBox(height: 16),
            _buildCategorySection(
              icon: Icons.apartment,
              title: 'Tipo de ambiente',
              category: 'ambience',
              options: _ambienceOptions,
            ),
            const SizedBox(height: 16),
            _buildCategorySection(
              icon: Icons.local_drink,
              title: 'Bebidas y consumo',
              category: 'drinks',
              options: _drinksOptions,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Seleccionados ${_selectedInterests.length} de $_minSelections',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E6E6E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedInterests.length >= _minSelections
                          ? () async {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (uid == null) return;

                              try {
                                await FirebaseFirestore.instance
                                    .collection('cliente')
                                    .doc(uid)
                                    .set({
                                  'interests': _selectedInterests,
                                }, SetOptions(merge: true));

                                print(
                                    'Intereses guardados: $_selectedInterests');

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PerfilView(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error al guardar los intereses')),
                                );
                                print('Error guardando intereses: $e');
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E004F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required IconData icon,
    required String title,
    required String category,
    required List<Map<String, dynamic>> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option['selected'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => _toggleInterest(category, index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.purple : const Color(0xFFEAEAEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        option['label'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
