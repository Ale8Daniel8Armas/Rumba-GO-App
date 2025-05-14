enum Gender { masculino, femenino, otro, noSeleccionado }

class PersonalData {
  String nombre;
  DateTime? fechaNacimiento;
  Gender genero;
  String correo;

  PersonalData({
    required this.nombre,
    this.fechaNacimiento,
    this.genero = Gender.noSeleccionado,
    required this.correo,
  });
}
