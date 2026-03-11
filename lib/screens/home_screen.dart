import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ocr_service.dart';
import '../services/parser.dart';
import '../services/excel_service.dart';
import 'form_screen.dart';
import 'records_screen.dart';

/// Pantalla principal de la aplicación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OCRService _ocrService = OCRService();
  final DPIParser _parser = DPIParser();
  final ExcelService _excelService = ExcelService();

  bool _isScanning = false;
  String? _scannedText;
  String? _extractedName;
  String? _extractedDPI;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }


  Future<void> _scanDPI() async {
    setState(() {
      _isScanning = true;
      _scannedText = null;
      _extractedName = null;
      _extractedDPI = null;
    });

    try {
      // Realizar OCR
      String? ocrText = await _ocrService.scanFromCamera();
      
      if (ocrText == null || ocrText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo reconocer texto. Intente nuevamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isScanning = false;
        });
        return;
      }

      // Parsear información
      Map<String, String?> parsedData = _parser.parseDPI(ocrText);
      
      setState(() {
        _scannedText = ocrText;
        _extractedName = parsedData['name'];
        _extractedDPI = parsedData['dpi'];
        _isScanning = false;
      });

      // Navegar a formulario con los datos extraídos
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormScreen(
              initialName: _extractedName ?? '',
              initialDPI: _extractedDPI ?? '',
              isManualEntry: false,
            ),
          ),
        ).then((result) {
          setState(() {
            _scannedText = null;
            _extractedName = null;
            _extractedDPI = null;
          });
          if (result == 'retry' && mounted) {
            _scanDPI();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Abre el formulario para registro manual (sin escanear DPI)
  void _openManualRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormScreen(
          initialName: '',
          initialDPI: '',
          isManualEntry: true,
        ),
      ),
    );
  }

  /// Navega a la pantalla de registros guardados
  void _viewRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Trámites DPI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _viewRecords,
            tooltip: 'Ver registros',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'ESCANEO DE DPI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Use la cámara para escanear el DPI y extraer automáticamente la información',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanDPI,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_isScanning ? 'Escaneando...' : 'Escanear DPI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openManualRegister,
                icon: const Icon(Icons.edit_note),
                label: const Text('Registro manual'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              if (_scannedText != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Texto reconocido:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scannedText!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_extractedName != null || _extractedDPI != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Datos extraídos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_extractedName != null)
                    Text('Nombre: $_extractedName'),
                  if (_extractedDPI != null)
                    Text('DPI: $_extractedDPI'),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
