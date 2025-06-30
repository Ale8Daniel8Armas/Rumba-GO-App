class LocalModel {
  //String id;
  String nombre;
  String tipoLocal;
  String descripcion;
  String direccion;
  double latitud;
  double longitud;
  String zona;

  List<String> categoriasMusicales;
  List<String> categoriasAmbiente;
  List<String> categoriasBebidas;
  List<String> categorias;

  List<Map<String, String>> horarios;

  List<String> telefonos;
  String correo;
  String facebook;
  String instagram;
  String tiktok;
  String paginaWeb;

  List<String> fotosUrls;
  String logoUrl;

  List<String> servicios;
  int aforoMaximo;

  // Constructor
  LocalModel({
    //required this.id,
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
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      zona: map['zona'] ?? '',
      categoriasMusicales: List<String>.from(map['categoriasMusicales'] ?? []),
      categoriasAmbiente: List<String>.from(map['categoriasAmbiente'] ?? []),
      categoriasBebidas: List<String>.from(map['categoriasBebidas'] ?? []),
      categorias: List<String>.from(map['categorias'] ?? []),
      horarios: (map['horarios'] as List<dynamic>?)
              ?.map((h) => Map<String, String>.from(h as Map))
              .toList() ??
          [],
      telefonos: List<String>.from(map['telefonos'] ?? []),
      correo: map['correo'] ?? '',
      facebook: map['facebook'] ?? '',
      instagram: map['instagram'] ?? '',
      tiktok: map['tiktok'] ?? '',
      paginaWeb: map['paginaWeb'] ?? '',
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      logoUrl: map['logoUrl'] ?? '',
      servicios: List<String>.from(map['servicios'] ?? []),
      aforoMaximo: (map['aforoMaximo'] as num?)?.toInt() ?? 0,
    );
  }
}
