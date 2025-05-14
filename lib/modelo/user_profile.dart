class UserProfile {
  String username;
  String? descripcion;
  String? fotoPerfilUrl;
  String? instagram;
  String? twitter;
  String? facebook;

  UserProfile({
    required this.username,
    this.descripcion,
    this.fotoPerfilUrl,
    this.instagram,
    this.twitter,
    this.facebook,
  });
}
