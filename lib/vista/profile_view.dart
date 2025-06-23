import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

import 'edit_profile_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_view.dart';
import 'map_view.dart';
import 'reviews_page.dart';
import 'contacts_page.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  String _username = '';
  final ImagePicker _picker = ImagePicker();
  late Future<DocumentSnapshot> _profileFuture;
  String descripcion = '';
  String? facebook = '';
  String? instagram = '';
  String? twitter = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfile();
    _loadDescription();
    _loadSocialNetworks();
  }

  void _loadProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _profileFuture =
          FirebaseFirestore.instance.collection('cliente').doc(uid).get();
    }
  }

  Future<void> _loadUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('cliente').doc(uid).get();
    setState(() {
      _username = doc.data()?['user_name'] ?? 'Usuario';
    });
  }

  Future<void> _loadDescription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('cliente').doc(uid).get();
    setState(() {
      descripcion = doc.data()?['description'] ?? 'Sin descripción';
    });
  }

  Future<void> _loadSocialNetworks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('cliente').doc(uid).get();

    final data = doc.data();
    setState(() {
      facebook = (data?['facebook'] as String?)?.trim();
      instagram = (data?['instagram'] as String?)?.trim();
      twitter = (data?['twitter'] as String?)?.trim();
    });
  }

  Future<void> _pickAndUploadImage(String? uid) async {
    if (uid == null) {
      print('❌ UID es null');
      return;
    }

    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      print('📸 No se seleccionó ninguna imagen');
      return;
    }

    try {
      print('⬆️ Subiendo imagen a Firebase Storage...');

      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedImage.path,
        '${pickedImage.path}_compressed.jpg',
        quality: 70,
      );

      if (compressedFile == null) {
        print('❌ Falló la compresión');
        return;
      }

      await storageRef.putFile(File(compressedFile.path));

      final downloadUrl = await storageRef.getDownloadURL();
      print('✅ Imagen subida. URL: $downloadUrl');

      await FirebaseFirestore.instance
          .collection('cliente')
          .doc(uid)
          .set({'profile_image': downloadUrl}, SetOptions(merge: true));

      print('✅ URL guardada en Firestore');

      if (mounted) {
        setState(() {
          _profileFuture =
              FirebaseFirestore.instance.collection('cliente').doc(uid).get();
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error subiendo imagen: $e');
      print('📋 StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () => _pickAndUploadImage(user?.uid),
      child: FutureBuilder<DocumentSnapshot>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
                radius: 50, child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.error, color: Colors.red),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final imageUrl = (data != null && data.containsKey('profile_image'))
              ? data['profile_image']
              : '';

          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? const Icon(Icons.camera_alt_outlined,
                    size: 40, color: Colors.black54)
                : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Perfil',
                style: TextStyle(
                  color: Color(0xFFD824A6),
                  fontFamily: 'Exo',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileImage(),
              const SizedBox(height: 10),
              Text(
                '@$_username',
                style: const TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Exo',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$descripcion',
                style: const TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 4),
              if ((facebook ?? '').isNotEmpty ||
                  (instagram ?? '').isNotEmpty ||
                  (twitter ?? '').isNotEmpty) ...[
                if ((facebook ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('Facebook: $facebook',
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w200,
                        )),
                  ),
                if ((instagram ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('Instagram: @$instagram',
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w200,
                        )),
                  ),
                if ((twitter ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('Twitter: @$twitter',
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w200,
                        )),
                  ),
              ],
              const SizedBox(height: 30),
              _ListTileProfile(
                icon: Icons.edit,
                text: 'Editar',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerfilEditableView(),
                    ),
                  );
                },
              ),
              _ListTileProfile(
                icon: Icons.star,
                text: 'Apariencia',
                color: Colors.blueAccent,
                onTap: () {},
              ),
              _ListTileProfile(
                icon: Icons.logout,
                text: 'Salir',
                color: Colors.red,
                onTap: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTileProfile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ListTileProfile({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          onTap: onTap,
        ),
        const Divider(thickness: 1),
      ],
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
