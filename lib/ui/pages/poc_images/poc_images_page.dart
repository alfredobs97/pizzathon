import 'package:flutter/material.dart';

class PocImagesPage extends StatelessWidget {
  const PocImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POC: Subida de Imágenes (Admin Only)'),
      ),
      body: const Center(
        child: Text(
          'previa para ver si solo entran admin, aqui ira logica de seleccion y subida',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}