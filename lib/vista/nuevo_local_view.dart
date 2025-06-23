import 'dart:io';
import 'package:flutter/material.dart';
import '../controlador/LocalController.dart';
import 'package:image_picker/image_picker.dart';

class NuevoLocalView extends StatefulWidget {
  const NuevoLocalView({super.key});

  @override
  State<NuevoLocalView> createState() => _NuevoLocalViewState();
}

class _NuevoLocalViewState extends State<NuevoLocalView> {
  final NuevoLocalController controller = NuevoLocalController();

  Future<void> _seleccionarFotosLocal() async {
    final picker = ImagePicker();
    final List<XFile>? fotos = await picker.pickMultiImage();
    if (fotos != null && fotos.isNotEmpty) {
      setState(() {
        controller.fotosLocal.addAll(fotos.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _seleccionarLogo() async {
    final picker = ImagePicker();
    final XFile? logo = await picker.pickImage(source: ImageSource.gallery);
    if (logo != null) {
      setState(() {
        controller.logoFile = File(logo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Nuevo Local',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Exo',
              fontSize: 28,
              fontWeight: FontWeight.w700,
            )),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      //extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(13),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre del local:',
                      style: TextStyle(
                        fontFamily: 'Exo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.nombreController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Exo',
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyanAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Escribe el nombre de tu local',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Exo',
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de local:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: controller.tipoLocalSeleccionado,
                          items: controller.tiposDeLocal
                              .map((tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(
                              () => controller.tipoLocalSeleccionado = value!),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Escoje el tipo de tu local',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categorías:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCategoriaSelector(
                            'Tipo de Música:', controller.musicOptions),
                        const SizedBox(height: 16),
                        _buildCategoriaSelector(
                            'Ambiente:', controller.ambienceOptions),
                        const SizedBox(height: 16),
                        _buildCategoriaSelector(
                            'Bebidas:', controller.drinksOptions),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.deepPurple, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            controller: controller.descripcionController,
                            maxLines: 3,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Escríbenos lo mejor de tu local',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Text(
                      'Días y horarios de atención:',
                      style: const TextStyle(
                        fontFamily: 'Exo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(controller.horarios.length, (i) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.horarios[i]['dia'] as String,
                            style: const TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                controller.seleccionarHora(context, i, true),
                            child: Text(
                              controller.formatearHora(
                                  controller.horarios[i]['inicio']),
                              style: const TextStyle(
                                fontFamily: 'Exo',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                          Text(' - '),
                          TextButton(
                            onPressed: () =>
                                controller.seleccionarHora(context, i, false),
                            child: Text(
                              controller
                                  .formatearHora(controller.horarios[i]['fin']),
                              style: const TextStyle(
                                fontFamily: 'Exo',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dirección:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.direccionController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Escribe la dirección de tu local',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coordenadas GPS de tu local:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.latitudController,
                                decoration:
                                    InputDecoration(labelText: 'Latitud'),
                                style: const TextStyle(
                                  fontFamily: 'Exo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: controller.longitudController,
                                decoration:
                                    InputDecoration(labelText: 'Longitud'),
                                style: const TextStyle(
                                  fontFamily: 'Exo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async =>
                              await controller.obtenerUbicacionActual(),
                          icon: Icon(Icons.my_location),
                          label: Text(
                            'Usar ubicación actual',
                            style: const TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zona de ubicación:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: controller.zonaSeleccionada,
                          items: controller.zonasQuito
                              .map((zona) => DropdownMenuItem(
                                    value: zona,
                                    child: Text(zona),
                                  ))
                              .toList(),
                          onChanged: (zona) => setState(
                              () => controller.zonaSeleccionada = zona!),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Escribe la zona donde se ubica tu local',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Teléfonos de contacto:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...controller.telefonosControllers.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: TextFormField(
                                controller: c,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Exo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w200,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.cyanAccent),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText:
                                      'Coloca un número de contacto de tu local',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Exo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            )),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => controller.agregarTelefono()),
                          child: Icon(Icons.add),
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correo electrónico:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.correoController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'formato correcto: tulocal@correo.com',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Redes Sociales del local:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildRedSocialInput(
                            controller.facebookController, 'Facebook'),
                        _buildRedSocialInput(
                            controller.instagramController, 'Instagram'),
                        _buildRedSocialInput(
                            controller.tiktokController, 'TikTok'),
                        _buildRedSocialInput(
                            controller.paginaWebController, 'Página Web'),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fotos de local:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: _seleccionarFotosLocal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.shade50,
                              shape: StadiumBorder(),
                            ),
                            child: const Text(
                              '+ Agregar fotos',
                              style: TextStyle(
                                fontFamily: 'Exo',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: controller.fotosLocal
                              .map((foto) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(foto,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Logotipo:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: _seleccionarLogo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.shade50,
                              shape: StadiumBorder(),
                            ),
                            child: const Text(
                              '+ Agregar logo',
                              style: TextStyle(
                                fontFamily: 'Exo',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (controller.logoFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              controller.logoFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    _buildServiciosSelector(),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aforo máximo:',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.aforoMaximoController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText:
                                'Número máximo de ocupantes: 100 (Ejemplo)',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    Divider(color: Colors.cyanAccent, thickness: 1.5),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            onPressed: () async {
                              final errores = controller.validarFormulario();
                              setState(() {});

                              if (errores.isEmpty) {
                                await controller.publicarNuevoLocal();
                                Navigator.pop(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        Text("Corrija los siguientes errores:"),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: errores
                                            .map((e) => Text("• $e",
                                                style: TextStyle(
                                                    color: Colors.red)))
                                            .toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Entendido"),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 14),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  Widget _buildRedSocialInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Colors.black87,
            fontFamily: 'Exo',
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        style: const TextStyle(
          fontFamily: 'Exo',
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }

  Widget _buildServiciosSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios y comodidades:',
          style: TextStyle(
            fontFamily: 'Exo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: controller.serviciosDisponibles.map((servicio) {
            return FilterChip(
              label: Text(
                servicio['label'],
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: servicio['selected'],
              selectedColor: Colors.pink.shade50,
              checkmarkColor: Color(0xFFD824A6),
              shape: StadiumBorder(
                side: BorderSide(color: Color(0xFFD824A6), width: 1.5),
              ),
              onSelected: (val) => setState(() => servicio['selected'] = val),
            );
          }).toList(),
        )
      ],
    );
  }
}
