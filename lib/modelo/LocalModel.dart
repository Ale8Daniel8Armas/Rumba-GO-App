class LocalModel {
  String nombre;
  String tipoLocal; // Ej: 'Bar', 'Discoteca', 'Karaoke'
  String descripcion;
  String direccion;
  double latitud;
  double longitud;
  String zona; // Ej: 'Zona Rosa', 'Centro Histórico'

  List<String> categoriasMusicales; // seleccionadas desde _musicOptions
  List<String> categoriasAmbiente; // seleccionadas desde _ambienceOptions
  List<String> categoriasBebidas; // seleccionadas desde _drinksOptions
  List<String> categorias; //Lista de categorias unificada

  List<Map<String, String>>
      horarios; // Ej: [{'día': 'Lunes', 'inicio': '18:00', 'fin': '02:00'}]

  List<String> telefonos; // Puede haber más de uno
  String correo;
  String facebook;
  String instagram;
  String tiktok;
  String paginaWeb;

  List<String> fotosUrls; // Almacenadas en Firebase Storage (paths)
  String logoUrl; // Almacenado también en Storage

  List<String> servicios; // Ej: ['DJ en vivo', 'Terraza', 'WiFi', ...]
  int aforoMaximo;

  // Constructor
  LocalModel({
    required this.nombre,
    required this.tipoLocal,
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.zona,
    required this.categoriasMusicales,
    required this.categoriasAmbiente,
    required this.categoriasBebidas,
    required this.categorias,
    required this.horarios,
    required this.telefonos,
    required this.correo,
    required this.facebook,
    required this.instagram,
    required this.tiktok,
    required this.paginaWeb,
    required this.fotosUrls,
    required this.logoUrl,
    required this.servicios,
    required this.aforoMaximo,
  });

  // Conversión a Map (por si se guarda en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipoLocal': tipoLocal,
      'descripcion': descripcion,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'zona': zona,
      'categoriasMusicales': categoriasMusicales,
      'categoriasAmbiente': categoriasAmbiente,
      'categoriasBebidas': categoriasBebidas,
      'categorias': categorias,
      'horarios': horarios,
      'telefonos': telefonos,
      'correo': correo,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'paginaWeb': paginaWeb,
      'fotosUrls': fotosUrls,
      'logoUrl': logoUrl,
      'servicios': servicios,
      'aforoMaximo': aforoMaximo,
    };
  }

  // Constructor desde Map (para recuperar desde Firestore)
 factory LocalModel.fromMap(Map<String, dynamic> map) {
    return LocalModel(
      nombre: map['nombre'] ?? '',
      tipoLocal: map['tipoLocal'] ?? '',
      descripcion: map['descripcion'] ?? '',
      direccion: map['direccion'] ?? '',
      latitud: map['latitud'] ?? 0.0,
      longitud: map['longitud'] ?? 0.0,
      zona: map['zona'] ?? '',
      categoriasMusicales: List<String>.from(map['categoriasMusicales'] ?? []),
      categoriasAmbiente: List<String>.from(map['categoriasAmbiente'] ?? []),
      categoriasBebidas: List<String>.from(map['categoriasBebidas'] ?? []),
      categorias: List<String>.from(map['categorias'] ?? []),
      horarios: List<Map<String, String>>.from(map['horarios'] ?? []),
      telefonos: List<String>.from(map['telefonos'] ?? []),
      correo: map['correo'] ?? '',
      facebook: map['facebook'] ?? '',
      instagram: map['instagram'] ?? '',
      tiktok: map['tiktok'] ?? '',
      paginaWeb: map['paginaWeb'] ?? '',
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      logoUrl: map['logoUrl'] ?? '',
      servicios: List<String>.from(map['servicios'] ?? []),
      aforoMaximo: map['aforoMaximo'] ?? 0,
    );
  }
}
