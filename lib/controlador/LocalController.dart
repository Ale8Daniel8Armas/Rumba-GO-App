import 'dart:io';
import 'package:flutter/material.dart';
import '../modelo/LocalModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

class NuevoLocalController {
  // Controladores de texto
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController latitudController = TextEditingController();
  final TextEditingController longitudController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController paginaWebController = TextEditingController();
  final TextEditingController aforoMaximoController = TextEditingController();

  // Zonas
  final List<String> zonasQuito = [
    'La Mariscal',
    'Centro Histórico',
    'La Floresta',
    'La Carolina',
    'El Condado',
    'Cumbayá',
    'Tumbaco',
    'La Magdalena',
    'Carcelén',
    'Quitumbe',
  ];
  String zonaSeleccionada = 'La Mariscal';

  // Teléfonos
  List<TextEditingController> telefonosControllers = [TextEditingController()];

  void agregarTelefono() {
    telefonosControllers.add(TextEditingController());
  }

  // Tipo de local
  String tipoLocalSeleccionado = 'Discoteca';
  final List<String> tiposDeLocal = ['Discoteca', 'Bar', 'Karaoke'];

  // Opciones de categorías
  final List<Map<String, dynamic>> musicOptions = [
    {'label': 'Rock', 'selected': false},
    {'label': 'Pop', 'selected': false},
    {'label': 'Electrónica', 'selected': false},
    {'label': 'Jazz', 'selected': false},
    {'label': 'Clásica', 'selected': false},
    {'label': 'Reggaetón', 'selected': false},
    {'label': 'Rap', 'selected': false},
  ];

  final List<Map<String, dynamic>> ambienceOptions = [
    {'label': 'Tranquilo', 'selected': false},
    {'label': 'Animado', 'selected': false},
    {'label': 'Elegante', 'selected': false},
    {'label': 'Informal', 'selected': false},
    {'label': 'Romántico', 'selected': false},
    {'label': 'Familiar', 'selected': false},
  ];

  final List<Map<String, dynamic>> drinksOptions = [
    {'label': 'Cerveza', 'selected': false},
    {'label': 'Cócteles', 'selected': false},
    {'label': 'Vino', 'selected': false},
    {'label': 'Café', 'selected': false},
    {'label': 'Sin alcohol', 'selected': false},
    {'label': 'Gin', 'selected': false},
  ];

  // Servicios y comodidades
  final List<Map<String, dynamic>> serviciosDisponibles = [
    {'label': 'Pago en línea', 'selected': false},
    {'label': 'WiFi', 'selected': false},
    {'label': 'Tercera Edad', 'selected': false},
    {'label': 'Estacionamiento', 'selected': false},
    {'label': 'Terraza', 'selected': false},
    {'label': 'Espacio fumadores', 'selected': false},
    {'label': 'Zona VIP', 'selected': false},
    {'label': 'Menu platillos', 'selected': false},
    {'label': 'Bebidas', 'selected': false},
    {'label': 'DJ en vivo', 'selected': false},
  ];

  List<String> obtenerEtiquetasSeleccionadas(List<Map<String, dynamic>> lista) {
    return lista
        .where((item) => item['selected'] == true)
        .map((item) => item['label'] as String)
        .toList();
  }

  // Lista de horarios por día
  final List<Map<String, dynamic>> horarios = List.generate(
    7,
    (index) => {
      'dia': [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ][index],
      'inicio': TimeOfDay(hour: 0, minute: 0),
      'fin': TimeOfDay(hour: 0, minute: 0),
    },
  );

  // Método para seleccionar una hora en el horario
  Future<void> seleccionarHora(
      BuildContext context, int index, bool esInicio) async {
    final TimeOfDay? seleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (seleccionada != null) {
      if (esInicio) {
        horarios[index]['inicio'] = seleccionada;
      } else {
        horarios[index]['fin'] = seleccionada;
      }
    }
  }

  // GPS - Formulario para pedir permisos de geolocalización
  Future<void> obtenerUbicacionActual() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    // Verifica si el GPS está habilitado
    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      // Puedes mostrar un diálogo o mensaje aquí
      return;
    }

    // Revisa permisos
    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      // Permiso denegado permanentemente
      return;
    }

    // Todo OK, obtén ubicación
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitudController.text = position.latitude.toString();
    longitudController.text = position.longitude.toString();
  }

  // Fotos y logo
  List<File> fotosLocal = [];
  File? logoFile;

  // Subir imagen a Firebase y obtener URL
  Future<String> subirImagen(File archivo, String nombreArchivo) async {
    final ref =
        FirebaseStorage.instance.ref().child('locales/$nombreArchivo.jpg');
    await ref.putFile(archivo);
    return await ref.getDownloadURL();
  }

  Future<LocalModel> construirModelo() async {
    final categoriasMusicales = obtenerEtiquetasSeleccionadas(musicOptions);
    final categoriasAmbiente = obtenerEtiquetasSeleccionadas(ambienceOptions);
    final categoriasBebidas = obtenerEtiquetasSeleccionadas(drinksOptions);
    final todasLasCategorias = [
      ...categoriasMusicales,
      ...categoriasAmbiente,
      ...categoriasBebidas,
    ];
    final servicios = obtenerEtiquetasSeleccionadas(serviciosDisponibles);
    final fotosUrls = await Future.wait(fotosLocal.asMap().entries.map((e) {
      return subirImagen(
          e.value, 'foto_${DateTime.now().millisecondsSinceEpoch}_${e.key}');
    }));

    final logoUrl = logoFile != null
        ? await subirImagen(
            logoFile!, 'logo_${DateTime.now().millisecondsSinceEpoch}')
        : '';

    return LocalModel(
      nombre: nombreController.text,
      tipoLocal: tipoLocalSeleccionado,
      descripcion: descripcionController.text,
      direccion: direccionController.text,
      latitud: double.tryParse(latitudController.text) ?? 0.0,
      longitud: double.tryParse(longitudController.text) ?? 0.0,
      zona: zonaSeleccionada,
      categoriasMusicales: categoriasMusicales,
      categoriasAmbiente: categoriasAmbiente,
      categoriasBebidas: categoriasBebidas,
      categorias: todasLasCategorias,
      horarios: horarios
          .map((h) => {
                'día': h['dia'] as String,
                'inicio': formatearHora(h['inicio'] as TimeOfDay),
                'fin': formatearHora(h['fin'] as TimeOfDay),
              })
          .toList(),
      telefonos: telefonosControllers
          .map((controller) => controller.text)
          .where((t) => t.trim().isNotEmpty)
          .toList(),
      correo: correoController.text,
      facebook: facebookController.text,
      instagram: instagramController.text,
      tiktok: tiktokController.text,
      paginaWeb: paginaWebController.text,
      fotosUrls: fotosUrls,
      logoUrl: logoUrl,
      servicios: servicios,
      aforoMaximo: int.tryParse(aforoMaximoController.text) ?? 0,
    );
  }

  // Guardar local en Firestore
  Future<void> guardarEnFirestore(LocalModel local) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) throw Exception('Usuario no autenticado');

    await firestore.collection('locales').add({
      ...local.toMap(),
      'idUsuario': user.uid,
      'fechaAlta': FieldValue.serverTimestamp(),
      'estado': 'pendiente',
    });
  }

  //Actualizar el rol del usuario
  Future<void> actualizarRolUsuarioAPropietario() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) throw Exception('Usuario no autenticado');

    final clienteRef = firestore.collection('cliente').doc(user.uid);

    await clienteRef.update({'rol': 'propietario'});
  }

  // Botón final: registrar
  Future<void> publicarNuevoLocal() async {
    final local = await construirModelo();
    await guardarEnFirestore(local);
    await actualizarRolUsuarioAPropietario();
  }

  // Hora
  String formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
