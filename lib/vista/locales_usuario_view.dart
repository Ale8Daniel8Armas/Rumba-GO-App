import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalesUsuarioView extends StatelessWidget {
  const LocalesUsuarioView({super.key});

  Future<List<Map<String, dynamic>>> obtenerLocalesUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final snapshot = await FirebaseFirestore.instance
        .collection('locales')
        .where('idUsuario', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Tus locales'),
        backgroundColor: const Color(0xFF1B0036),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerLocalesUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes locales registrados.'));
          }

          final locales = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: locales.length,
            itemBuilder: (context, index) {
              final local = locales[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (local['logoUrl'] != null &&
                          local['logoUrl'].toString().isNotEmpty)
                        Center(
                          child: Image.network(
                            local['logoUrl'],
                            height: 100,
                            width: 100,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        local['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B0036),
                        ),
                      ),
                      Text(
                        local['descripcion'] ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              local['direccion'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Categorías: ${_joinList(local['categorias'])}'),
                      Text('Zona: ${local['zona']}'),
                      Text('Aforo Máximo: ${local['aforoMaximo']}'),
                      Text('Correo: ${local['correo']}'),
                      const SizedBox(height: 8),
                      if ((local['fotosUrls'] as List).isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                (local['fotosUrls'] as List).map<Widget>((url) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _joinList(dynamic lista) {
    if (lista is List) {
      return lista.join(', ');
    }
    return '';
  }
}
