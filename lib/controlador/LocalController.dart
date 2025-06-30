import 'dart:io';
import 'package:flutter/material.dart';
import '../modelo/LocalModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data'; // Para Uint8List
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:image_picker/image_picker.dart'; // Para XFile

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

  //variables auxiliares para las validaciones
  String? nombreError;
  String? tipoLocalError;
  String? musicaError;
  String? ambienteError;
  String? bebidasError;
  String? descripcionError;
  String? direccionError;
  String? coordenadasError;
  String? zonaError;
  String? telefonoError;
  String? correoError;
  String? serviciosError;
  String? aforoError;

  // Zonas
  final List<String> zonasQuito = [
    'Ninguno',
    'Amaguaña',
    'Belisario Quevedo',
    'Calacalí',
    'Calderón',
    'Carcelén',
    'Centro Histórico',
    'Checa',
    'Chilibulo',
    'Chillogallo',
    'Chimbacalle',
    'Cochapamba',
    'Comité del Pueblo',
    'Concepción',
    'Conocoto',
    'Cotocollao',
    'Cumbayá',
    'El Batán',
    'El Condado',
    'El Inca',
    'El Labrador',
    'El Tejar',
    'Eloy Alfaro',
    'Guamaní',
    'Guayllabamba',
    'Iñaquito',
    'Itchimbía',
    'Jipijapa',
    'Kennedy',
    'La Argelia',
    'La Ecuatoriana',
    'La Ferroviaria',
    'La Floresta',
    'La Libertad',
    'La Magdalena',
    'La Mariscal',
    'La Mena',
    'La Merced',
    'La Tola',
    'Llano Chico',
    'Lloa',
    'Nayón',
    'Nono',
    'Pifo',
    'Pintag',
    'Pomasqui',
    'Ponceano',
    'Puéllaro',
    'Puembo',
    'Puengasí',
    'Quitumbe',
    'Rumipamba',
    'San Antonio de Pichincha',
    'San Isidro del Inca',
    'San Juan',
    'San Rafael (Capelo)',
    'San Sebastián',
    'Santa Prisca',
    'Sangolquí',
    'Solanda',
    'Tababela',
    'Turubamba',
    'Tumbaco',
    'Villaflora',
    'Yaruqui',
    'Zambiza',
  ];
  String zonaSeleccionada = 'Ninguno';

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
    {'label': 'Música Nacional', 'selected': false},
    {'label': 'Salsa', 'selected': false},
    {'label': 'Electrónica', 'selected': false},
    {'label': 'Jazz', 'selected': false},
    {'label': 'Cumbia', 'selected': false},
    {'label': 'Caribe', 'selected': false},
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
    {'label': 'Whisky', 'selected': false},
    {'label': 'Tequila', 'selected': false},
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

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return;
    }

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitudController.text = position.latitude.toString();
    longitudController.text = position.longitude.toString();
  }

  // Fotos y logo
  List<XFile> fotosLocal = [];
  XFile? logoFile;

// Subir imagen a Firebase y obtener URL
  Future<String> subirImagen(XFile imagen, String nombreArchivo) async {
    try {
      final bytes = await imagen.readAsBytes();

      String mimeType = 'image/jpeg';
      String extension = 'jpg';

      if (imagen.name.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
        extension = 'png';
      } else if (imagen.name.toLowerCase().endsWith('.jpeg') ||
          imagen.name.toLowerCase().endsWith('.jpg')) {
        mimeType = 'image/jpeg';
        extension = 'jpg';
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('locales')
          .child('$nombreArchivo.$extension');

      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'original_name': imagen.name,
          'uploaded_by': FirebaseAuth.instance.currentUser?.uid ?? '',
          'upload_date': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(bytes, metadata);

      final taskSnapshot = await uploadTask
          .whenComplete(() {})
          .timeout(const Duration(seconds: 45), onTimeout: () {
        throw Exception('Tiempo de espera excedido al subir la imagen');
      });

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen: ${e.toString()}');
    }
  }

//validadores auxiliares para carga de imagen
  Future<Uint8List> _getBytesFromImagen(dynamic imagen) async {
    if (imagen is XFile) {
      return await imagen.readAsBytes();
    } else if (imagen is Uint8List) {
      return imagen;
    } else {
      throw Exception('Tipo de imagen no soportado para web');
    }
  }

  Future<File> _getFileFromImagen(dynamic imagen) async {
    if (imagen is XFile) {
      return File(imagen.path);
    } else if (imagen is File) {
      return imagen;
    } else {
      throw Exception('Tipo de imagen no soportado para móvil/desktop');
    }
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

    // Subir imágenes y obtener URLs
    String? logoUrl;
    if (logoFile != null) {
      logoUrl = await subirImagen(
          logoFile!, 'logo_${DateTime.now().millisecondsSinceEpoch}');
    }

    final fotosUrls = await Future.wait(fotosLocal.asMap().entries.map((e) =>
        subirImagen(e.value,
            'foto_${DateTime.now().millisecondsSinceEpoch}_${e.key}')));

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
      logoUrl: logoUrl ?? '',
      servicios: servicios,
      aforoMaximo: int.tryParse(aforoMaximoController.text) ?? 0,
    );
  }

  // Guardar local en Firestore
  Future<void> guardarEnFirestore(LocalModel local) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception('Usuario no autenticado');

      await firestore.collection('locales').add({
        ...local.toMap(),
        'idUsuario': user.uid,
        'fechaAlta': FieldValue.serverTimestamp(),
        'estado': 'pendiente',
        'rating': 0,
        'reseñas': [],
      });
    } catch (e) {
      throw Exception('Error al guardar en Firestore: $e');
    }
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
    try {
      final errores = validarFormulario();
      if (errores.isNotEmpty) {
        throw Exception(errores.join('\n'));
      }

      final local = await construirModelo();
      await guardarEnFirestore(local);
      await actualizarRolUsuarioAPropietario();
    } catch (e) {
      throw Exception('Error al publicar local: $e');
    }
  }

  // Hora
  String formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  // validaciones
  List<String> validarFormulario() {
    List<String> errores = [];

    // Limpiar errores previos
    nombreError = tipoLocalError = musicaError = ambienteError = bebidasError =
        descripcionError = direccionError = coordenadasError = zonaError =
            telefonoError = correoError = serviciosError = aforoError = null;

    // 1) Validación nombre del local
    if (nombreController.text.isEmpty) {
      nombreError = "El nombre del local es obligatorio";
      errores.add(nombreError!);
    } else if (nombreController.text.split(' ').length > 30) {
      nombreError = "El nombre no puede exceder 30 palabras";
      errores.add(nombreError!);
    }

    // 2) Validación tipo de local
    if (tipoLocalSeleccionado == null || tipoLocalSeleccionado!.isEmpty) {
      tipoLocalError = "Seleccione un tipo de local";
      errores.add(tipoLocalError!);
    }

    // 3) Validación categorías (música, ambiente, bebidas)
    if (!musicOptions.any((op) => op['selected'])) {
      musicaError = "Seleccione al menos un tipo de música";
      errores.add(musicaError!);
    }

    if (!ambienceOptions.any((op) => op['selected'])) {
      ambienteError = "Seleccione al menos un tipo de ambiente";
      errores.add(ambienteError!);
    }

    if (!drinksOptions.any((op) => op['selected'])) {
      bebidasError = "Seleccione al menos un tipo de bebida";
      errores.add(bebidasError!);
    }

    // 4) Validación descripción
    if (descripcionController.text.split(' ').length > 254) {
      descripcionError = "La descripción no puede exceder 254 palabras";
      errores.add(descripcionError!);
    }

    // 5) Validación dirección
    if (direccionController.text.isEmpty) {
      direccionError = "La dirección es obligatoria";
      errores.add(direccionError!);
    } else if (direccionController.text.split(' ').length > 30) {
      direccionError = "La dirección no puede exceder 30 palabras";
      errores.add(direccionError!);
    }

    // 6) Validación coordenadas GPS
    if (latitudController.text.isEmpty || longitudController.text.isEmpty) {
      coordenadasError = "Las coordenadas GPS son obligatorias";
      errores.add(coordenadasError!);
    }

    // 7) Validación zona
    if (zonaSeleccionada == null || zonaSeleccionada!.isEmpty) {
      zonaError = "Seleccione una zona";
      errores.add(zonaError!);
    }

    // 8) Validación teléfonos
    for (var telController in telefonosControllers) {
      if (telController.text.isEmpty) {
        telefonoError = "El teléfono es obligatorio";
        errores.add(telefonoError!);
        break;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(telController.text)) {
        telefonoError = "El teléfono solo debe contener números";
        errores.add(telefonoError!);
        break;
      }
      if (telController.text.length != 10) {
        telefonoError = "El teléfono debe tener 10 dígitos";
        errores.add(telefonoError!);
        break;
      }
    }

    // 9) Validación correo electrónico
    if (correoController.text.isEmpty) {
      correoError = "El correo electrónico es obligatorio";
      errores.add(correoError!);
    } else if (!correoController.text.contains('@')) {
      correoError = "El correo debe contener @";
      errores.add(correoError!);
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(correoController.text)) {
      correoError = "Formato de correo inválido";
      errores.add(correoError!);
    }

    // 10) Validación servicios y comodidades
    final serviciosSeleccionados =
        serviciosDisponibles.where((s) => s['selected']).length;
    if (serviciosSeleccionados < 3) {
      serviciosError = "Seleccione al menos 3 servicios/comodidades";
      errores.add(serviciosError!);
    }

    // 11) Validación aforo máximo
    if (aforoMaximoController.text.isEmpty) {
      aforoError = "El aforo máximo es obligatorio";
      errores.add(aforoError!);
    } else {
      try {
        int aforo = int.parse(aforoMaximoController.text);
        if (aforo < 1 || aforo > 1000) {
          aforoError = "El aforo debe estar entre 1 y 1000";
          errores.add(aforoError!);
        }
      } catch (e) {
        aforoError = "Ingrese un número válido en el aforo";
        errores.add(aforoError!);
      }
    }

    /*
    //12 Validacion de carga de imagenes
    if (logoFile == null) {
      errores.add('El logo del local es requerido');
    }

    if (fotosLocal.isEmpty) {
      errores.add('Debe agregar al menos una foto del local');
    } else if (fotosLocal.length > 10) {
      errores.add('Máximo 10 fotos permitidas');
    }
    */
    return errores;
  }
}
