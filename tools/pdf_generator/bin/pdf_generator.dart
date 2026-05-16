import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart' as gcf;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Colores de la App (extraídos de theme.dart)
const PdfColor kBackgroundColor = PdfColor.fromInt(0xFFF8EEE3);
const PdfColor kPrimaryColor = PdfColor.fromInt(0xFFE36414);
const PdfColor kSecondaryColor = PdfColor.fromInt(0xFF540B0E);
const PdfColor kOnSurfaceColor = PdfColor.fromInt(0xFF1E1E1E);

void main(List<String> arguments) async {
  // 1. Cargar Credenciales
  final secretsFile = File('../../secrets-dev.json');
  if (!await secretsFile.exists()) {
    print('Error: No se encontró secrets-dev.json en la raíz del proyecto.');
    return;
  }

  // Nota: firebase_admin_sdk requiere un archivo de cuenta de servicio real.
  final serviceAccountFile = File('../../service-account.json');
  if (!await serviceAccountFile.exists()) {
    print('Error: No se encontró service-account.json en la raíz del proyecto.');
    return;
  }

  // Leer el project_id del archivo para asegurar que se usa el correcto
  final serviceAccountContent = await serviceAccountFile.readAsString();
  final serviceAccountMap = jsonDecode(serviceAccountContent) as Map<String, dynamic>;
  final String projectId = serviceAccountMap['project_id'] ?? 'pizzathon-app-dev';

  print('Inicializando conexión para el proyecto: $projectId...');

  // Inicializamos Firestore directamente para evitar que el SDK de Admin use el proyecto por defecto del sistema
  final firestore = gcf.Firestore(
    settings: gcf.Settings(
      projectId: projectId,
      credential: gcf.Credential.fromServiceAccount(serviceAccountFile),
    ),
  );

  final collection = arguments.isNotEmpty ? arguments[0] : 'admin_selections_2026_05';

  print('Obteniendo pizzas de la colección $collection en el proyecto $projectId...');
  try {
    // Realizar la consulta
    final querySnapshot = await firestore.collection(collection).orderBy('createdAt').get();
    final docs = querySnapshot.docs;

    print('Se encontraron ${docs.length} pizzas.');

    if (docs.isEmpty) {
      print('Aviso: La colección está vacía o no existe en el proyecto $projectId.');
      return;
    }

    final pdf = pw.Document();

    int pizzaCount = 1;
    for (final doc in docs) {
      final data = doc.data();
      final pizzaId = doc.id;
      print('Procesando Pizza #$pizzaCount (ID: $pizzaId)...');

      // Descargar imágenes en paralelo
      final imageUrls = Map<String, dynamic>.from(data['imageUrls'] as Map? ?? {});
      if (imageUrls.isNotEmpty) {
        print('  Descargando ${imageUrls.length} imágenes...');
      }

      final imageFutures = imageUrls.entries.map((entry) async {
        try {
          final response = await http.get(Uri.parse(entry.value));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          }
        } catch (e) {
          print('  Error al descargar imagen ${entry.key}: $e');
        }
        return null;
      });

      final results = await Future.wait(imageFutures);
      final List<Uint8List> imageBytesList = results.whereType<Uint8List>().toList();

      // Añadir página al PDF
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            buildBackground: (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Container(color: kBackgroundColor),
              );
            },
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: kPrimaryColor,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'PIZZA #$pizzaCount',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'ID: $pizzaId',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Detalles Técnicos
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: _buildTechnicalDetails(data),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      flex: 1,
                      child: _buildIngredients(data),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Imágenes
                if (imageBytesList.isNotEmpty)
                  pw.Expanded(
                    child: pw.GridView(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: imageBytesList.map((bytes) {
                        return pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: kSecondaryColor, width: 2),
                          ),
                          child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        ),
      );
      pizzaCount++;
    }

    print('Guardando PDF...');
    final file = File('../../pizzas_jueces.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF generado exitosamente en: ${file.path}');
  } catch (e) {
    print('Error al acceder a Firestore en $projectId: $e');
    print('Asegúrate de que la Firestore API esté habilitada en el proyecto $projectId.');
  } finally {
    exit(0);
  }
}

pw.Widget _buildTechnicalDetails(Map<String, dynamic> data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('DATOS TÉCNICOS'),
      _buildDetailRow('Estilo', _getStyleDisplayName(data['pizzaStyle'])),
      _buildDetailRow('Harinas', data['flours'] ?? '-'),
      _buildDetailRow(
          'Prefermento', '${data['preferment'] ?? '-'} (${data['prefermentPercentage'] ?? '-'}%)'),
      _buildDetailRow('Hidratación', '${data['hydration'] ?? '-'}%'),
      _buildDetailRow('Peso bola', '${data['doughBallWeight'] ?? '-'}g'),
      _buildDetailRow('Horno', data['oven'] ?? '-'),
      _buildDetailRow('Temperatura', '${data['cookingTemperature'] ?? '-'}°C'),
    ],
  );
}

String _getStyleDisplayName(String? style) {
  switch (style) {
    case 'contemporanea':
      return 'Contemporánea';
    case 'napoletana':
      return 'Napoletana';
    case 'newYork':
      return 'New York';
    case 'tondaClasica':
      return 'Tonda clásica';
    case 'tondaRomana':
      return 'Tonda romana';
    case 'tegliaRomana':
      return 'Teglia romana';
    case 'padellino':
      return 'Padellino';
    case 'palaRomana':
      return 'Pala romana';
    case 'fritaMontanara':
      return 'Frita Montanara';
    default:
      return style ?? '-';
  }
}

pw.Widget _buildIngredients(Map<String, dynamic> data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('INGREDIENTES'),
      _buildDetailRow('Base', data['baseIngredient'] ?? '-'),
      pw.SizedBox(height: 5),
      pw.Text('Otros ingredientes:',
          style:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: kSecondaryColor)),
      pw.Text(data['otherIngredients'] ?? '-', style: const pw.TextStyle(fontSize: 10)),
    ],
  );
}

pw.Widget _buildSectionTitle(String title) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    decoration: const pw.BoxDecoration(
      color: kSecondaryColor,
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12),
    ),
  );
}

pw.Widget _buildDetailRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: kSecondaryColor),
          ),
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(fontSize: 10, color: kOnSurfaceColor),
          ),
        ],
      ),
    ),
  );
}
