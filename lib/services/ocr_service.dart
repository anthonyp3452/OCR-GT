import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para realizar OCR offline usando Google ML Kit
class OCRService {
  final TextRecognizer _textRecognizer;

  OCRService() : _textRecognizer = TextRecognizer();

  /// Escanea una imagen y extrae el texto usando OCR
  /// 
  /// [imagePath] - Ruta de la imagen a procesar
  /// Retorna el texto reconocido o null si hay error
  Future<String?> scanImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = 
          await _textRecognizer.processImage(inputImage);
      
      // Concatenar todo el texto reconocido
      String fullText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          fullText += line.text + '\n';
        }
      }
      
      return fullText.trim();
    } catch (e) {
      print('Error en OCR: $e');
      return null;
    }
  }

  /// Captura una imagen desde la cámara y realiza OCR
  /// 
  /// Retorna el texto reconocido o null si hay error
  Future<String?> scanFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) {
        return null;
      }

      return await scanImage(image.path);
    } catch (e) {
      print('Error al capturar imagen: $e');
      return null;
    }
  }

  /// Libera los recursos del reconocedor de texto
  void dispose() {
    _textRecognizer.close();
  }
}
