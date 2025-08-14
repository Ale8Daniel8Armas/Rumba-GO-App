class ReviewModel {
  String usuario_nombre;
  String lugar_nombre;
  String zona_nombre;

  double calificacion;
  String comentario;
  List<String> fotosUrls;
  String fecha;
  String hora_salida;
  double precio;

  List<String> categoriasMusicales;
  List<String> categoriasAmbiente;
  List<String> categoriasBebidas;
  List<String> categorias;

  //Constructor
  ReviewModel({
    required this.usuario_nombre,
    required this.lugar_nombre,
    required this.zona_nombre,
    required this.calificacion,
    required this.comentario,
    required this.fotosUrls,
    required this.fecha,
    required this.hora_salida,
    required this.precio,
    required this.categoriasMusicales,
    required this.categoriasAmbiente,
    required this.categoriasBebidas,
    required this.categorias,
  });

  //constructor vacio
  ReviewModel.empty()
      : usuario_nombre = '',
        lugar_nombre = '',
        zona_nombre = '',
        calificacion = 0.0,
        comentario = '',
        fotosUrls = [],
        fecha = '',
        hora_salida = '',
        precio = 0.0,
        categoriasMusicales = [],
        categoriasAmbiente = [],
        categoriasBebidas = [],
        categorias = [];

  // Conversión a Map (por si se guarda en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'usuario_nombre': usuario_nombre,
      'lugar_nombre': lugar_nombre,
      'zona_nombre': zona_nombre,
      'calificacion': calificacion,
      'comentario': comentario,
      'fotosUrls': fotosUrls,
      'fecha': fecha,
      'hora_salida': hora_salida,
      'precio': precio,
      'categoriasMusicales': categoriasMusicales,
      'categoriasAmbiente': categoriasAmbiente,
      'categoriasBebidas': categoriasBebidas,
      'categorias': categorias,
    };
  }

  //conversión desde Map (por si se lee de Firestore)
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      usuario_nombre: map['usuario_nombre'] ?? '',
      lugar_nombre: map['lugar_nombre'] ?? '',
      zona_nombre: map['zona_nombre'] ?? '',
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 0.0,
      comentario: map['comentario'] ?? '',
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      fecha: map['fecha'] ?? '',
      hora_salida: map['hora_salida'] ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      categoriasMusicales: List<String>.from(map['categoriasMusicales'] ?? []),
      categoriasAmbiente: List<String>.from(map['categoriasAmbiente'] ?? []),
      categoriasBebidas: List<String>.from(map['categoriasBebidas'] ?? []),
      categorias: List<String>.from(map['categorias'] ?? []),
    );
  }
}
