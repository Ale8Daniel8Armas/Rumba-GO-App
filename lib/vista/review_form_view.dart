import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../modelo/ReviewModel.dart';
import '../controlador/ReviewController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewFormView extends StatefulWidget {
  final String? lugarNombre;
  final String? zonaNombre;
  final String? usuarioNombre;

  const ReviewFormView({
    Key? key,
    this.lugarNombre,
    this.zonaNombre,
    this.usuarioNombre,
  }) : super(key: key);

  @override
  _ReviewFormView createState() => _ReviewFormView();
}

class _ReviewFormView extends State<ReviewFormView> {
  final _formKey = GlobalKey<FormState>();
  final ReviewController _reviewController = ReviewController();
  final ImagePicker _picker = ImagePicker();
  String username = '';

  late TextEditingController _lugarController;
  late TextEditingController _zonaController;
  late TextEditingController _comentarioController;
  late TextEditingController _horaSalidaController;
  late TextEditingController _precioController;

  double _calificacion = 5.0;
  List<XFile> _imagenesSeleccionadas = [];
  DateTime _fechaSeleccionada = DateTime.now();

  List<Map<String, dynamic>> _musicOptions = [];
  List<Map<String, dynamic>> _ambienceOptions = [];
  List<Map<String, dynamic>> _drinksOptions = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _lugarController = TextEditingController(text: widget.lugarNombre ?? '');
    _zonaController = TextEditingController(text: widget.zonaNombre ?? '');
    _comentarioController = TextEditingController();
    _horaSalidaController = TextEditingController();
    _precioController = TextEditingController();
    _musicOptions = List.from(_reviewController.musicOptions);
    _ambienceOptions = List.from(_reviewController.ambienceOptions);
    _drinksOptions = List.from(_reviewController.drinksOptions);

    _loadLocalName();
  }

  @override
  void dispose() {
    _lugarController.dispose();
    _zonaController.dispose();
    _comentarioController.dispose();
    _horaSalidaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('cliente').doc(uid).get();
    setState(() {
      username = doc.data()?['user_name'] ?? 'Usuario';
    });
  }

  Future<void> _loadLocalName() async {
    try {
      final firestore = FirebaseFirestore.instance;
      String nombreBuscado = widget.lugarNombre ?? _lugarController.text.trim();

      if (nombreBuscado.isNotEmpty) {
        // Consulta directa para verificar si existe el local
        QuerySnapshot query = await firestore
            .collection('locales')
            .where('nombre', isEqualTo: nombreBuscado)
            .get();

        if (query.docs.isNotEmpty) {
          final localDoc = query.docs.first;
          final localData = localDoc.data() as Map<String, dynamic>;

          setState(() {
            _lugarController.text = nombreBuscado;
            _zonaController.text = localData['zona'] ?? 'Quito';
          });
          return;
        }
      }

      // Si no se encontró el local, mostrar lista para seleccionar
      QuerySnapshot allLocals = await firestore.collection('locales').get();
      List<Map<String, dynamic>> localesData = allLocals.docs
          .map((doc) => {
                'nombre':
                    (doc.data() as Map<String, dynamic>)['nombre'] as String,
                'zona':
                    (doc.data() as Map<String, dynamic>)['zona'] as String? ??
                        'Quito',
              })
          .toList();

      if (localesData.isNotEmpty && mounted) {
        Map<String, dynamic>? seleccionado =
            await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selecciona un local'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: localesData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(localesData[index]['nombre']),
                      subtitle: Text('Zona: ${localesData[index]['zona']}'),
                      onTap: () {
                        Navigator.of(context).pop(localesData[index]);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );

        if (seleccionado != null && mounted) {
          setState(() {
            _lugarController.text = seleccionado['nombre'];
            _zonaController.text = seleccionado['zona'];
          });
        }
      }
    } catch (e) {
      print('Error cargando nombre del local: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B46C1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Reseña',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLugarInfo(),
                                  const SizedBox(height: 20),
                                  _buildCalificacion(),
                                  const SizedBox(height: 20),
                                  _buildComentario(),
                                  const SizedBox(height: 16),
                                  _buildAgregarFotos(),
                                  const SizedBox(height: 10),
                                  _buildCategoriaSelector(
                                      'Tipo de Música:', _musicOptions),
                                  const SizedBox(height: 16),
                                  _buildCategoriaSelector(
                                      'Ambiente:', _ambienceOptions),
                                  const SizedBox(height: 16),
                                  _buildCategoriaSelector(
                                      'Bebidas:', _drinksOptions),
                                  const SizedBox(height: 20),
                                  _buildFechaSalida(),
                                  const SizedBox(height: 20),
                                  _buildHoraSalida(),
                                  const SizedBox(height: 20),
                                  _buildPrecio(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.grey, width: 0.2),
                              ),
                            ),
                            child: _buildBotones(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLugarInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lugar:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          _lugarController.text.isNotEmpty
              ? _lugarController.text
              : 'No encontrado',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCalificacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calificación:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _calificacion = (index + 1).toDouble();
                });
              },
              child: Icon(
                Icons.star,
                size: 32,
                color: index < _calificacion ? Colors.amber : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildComentario() {
    return TextFormField(
      controller: _comentarioController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Coméntanos como fue tu experiencia en este lugar...',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El comentario no puede estar vacío';
        }
        return null;
      },
    );
  }

  Widget _buildAgregarFotos() {
    return Row(
      children: [
        GestureDetector(
          onTap: _seleccionarImagenes,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(
                  'Agregar fotos',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        if (_imagenesSeleccionadas.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            '${_imagenesSeleccionadas.length} foto(s) seleccionada(s)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildFechaSalida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione la fecha de salida:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? fechaSeleccionada = await showDatePicker(
              context: context,
              initialDate: _fechaSeleccionada,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
            );
            if (fechaSeleccionada != null) {
              setState(() {
                _fechaSeleccionada = fechaSeleccionada;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoraSalida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿A qué hora sucedió?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? horaSeleccionada = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (horaSeleccionada != null) {
              setState(() {
                _horaSalidaController.text = horaSeleccionada.format(context);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _horaSalidaController.text.isNotEmpty
                      ? _horaSalidaController.text
                      : 'Seleccionar hora',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrecio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cuánto gasto en el local?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _precioController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Ingrese el precio',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingrese un precio';
            }
            if (double.tryParse(value) == null) {
              return 'Ingrese un valor numérico válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Container(
          width: 150,
          decoration: BoxDecoration(
            color: Color(0xFFD824A6),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(
              color: Colors.deepPurple,
              width: 1.5,
            ),
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Descartar',
              style: TextStyle(
                fontFamily: 'Exo',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
          width: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF1B0036),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Registrar',
              style: TextStyle(
                fontFamily: 'Exo',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarImagenes() async {
    final List<XFile>? imagenes = await _picker.pickMultiImage();

    if (imagenes != null && imagenes.isNotEmpty) {
      setState(() {
        _imagenesSeleccionadas.addAll(imagenes);
      });
    }
  }

  Future<void> _guardarReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_musicOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona al menos un tipo de música'),
          backgroundColor: Colors.red));
      return;
    }
    if (_ambienceOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona al menos un tipo de ambiente'),
          backgroundColor: Colors.red));
      return;
    }
    if (_drinksOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona al menos un tipo de bebida'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final review = ReviewModel(
        usuario_nombre: '@$username',
        lugar_nombre: _lugarController.text.isNotEmpty
            ? _lugarController.text
            : 'Desconocido',
        zona_nombre: _zonaController.text.trim(),
        calificacion: _calificacion,
        comentario: _comentarioController.text.trim(),
        fotosUrls: [],
        fecha: DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
        hora_salida: _horaSalidaController.text.trim(),
        precio: double.tryParse(_precioController.text) ?? 0.0,
        categoriasMusicales:
            _reviewController.obtenerEtiquetasSeleccionadas(_musicOptions),
        categoriasAmbiente:
            _reviewController.obtenerEtiquetasSeleccionadas(_ambienceOptions),
        categoriasBebidas:
            _reviewController.obtenerEtiquetasSeleccionadas(_drinksOptions),
        categorias: [
          ..._reviewController.obtenerEtiquetasSeleccionadas(_musicOptions),
          ..._reviewController.obtenerEtiquetasSeleccionadas(_ambienceOptions),
          ..._reviewController.obtenerEtiquetasSeleccionadas(_drinksOptions),
        ],
      );

      // Guardar la reseña y obtener el ID
      final reviewId = await _reviewController.agregarReview(review);

      if (reviewId == null) {
        throw Exception('Error al guardar la reseña');
      }

      // Subir imágenes si hay alguna
      List<String> urlsImagenes = [];
      if (_imagenesSeleccionadas.isNotEmpty) {
        urlsImagenes = await _reviewController.subirImagenesReview(
            _imagenesSeleccionadas, reviewId);

        if (urlsImagenes.isNotEmpty) {
          review.fotosUrls = urlsImagenes;
          await _reviewController.actualizarReview(reviewId, review);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reseña publicada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCategoriaSelector(
      String label, List<Map<String, dynamic>> opciones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Exo',
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: opciones.map((op) {
            return FilterChip(
              label: Text(
                op['label'],
                style: const TextStyle(
                  color: Colors.purple,
                  fontFamily: 'Exo',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: op['selected'],
              selectedColor: Colors.pink.shade50,
              checkmarkColor: Color(0xFFD824A6),
              shape: StadiumBorder(
                side: BorderSide(color: Color(0xFFD824A6), width: 1.5),
              ),
              onSelected: (val) => setState(() => op['selected'] = val),
            );
          }).toList(),
        )
      ],
    );
  }
}
