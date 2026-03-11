import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:open_filex/open_filex.dart';
import '../services/excel_service.dart';

/// Pantalla para ver todos los registros guardados
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final ExcelService _excelService = ExcelService();
  List<Map<String, String>> _records = [];
  bool _isLoading = true;
  String? _filePath;
  bool _fileExists = false;
  bool _isCreatingDoc = false;
  bool _isDeleting = false;
  int? _deletingIndex;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// Carga los registros desde el archivo Excel
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, String>> records = await _excelService.readAllRecords();
      String filePath = await _excelService.getFilePath();
      bool exists = await _excelService.fileExists();
      
      setState(() {
        _records = records;
        _filePath = filePath;
        _fileExists = exists;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar registros: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Crea el documento Excel manualmente (vacío, listo para agregar registros)
  Future<void> _createDocument() async {
    setState(() => _isCreatingDoc = true);
    try {
      bool success = await _excelService.createDocument();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documento creado exitosamente. Ya puede agregar registros.'),
              backgroundColor: Colors.green,
            ),
          );
          _loadRecords();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear el documento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingDoc = false);
      }
    }
  }

  /// Comparte el archivo Excel para que el usuario pueda guardarlo o enviarlo
  Future<void> _shareDocument() async {
    if (_filePath == null) return;
    try {
      await Share.shareXFiles(
        [XFile(_filePath!)],
        text: 'Registro de trámites DPI',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    }
  }

  /// Abre el archivo Excel con una app externa (Google Sheets, Excel, etc.)
  Future<void> _openDocument() async {
    if (_filePath == null) return;
    try {
      final result = await OpenFilex.open(_filePath!);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el archivo: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Copia la ruta del archivo al portapapeles
  void _copyFilePath() {
    if (_filePath != null) {
      Clipboard.setData(ClipboardData(text: _filePath!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ruta copiada al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Confirma con el usuario y elimina un registro por índice.
  Future<void> _confirmAndDeleteRecord(int index) async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text(
            '¿Está seguro de borrar este registro? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _deletingIndex = index;
    });

    try {
      final success = await _excelService.deleteRecordByIndex(index);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadRecords();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar registro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _deletingIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Guardados'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_fileExists)
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.visibility),
              onPressed: _openDocument,
              tooltip: 'Ver documento',
            ),
          if (_fileExists)
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.share),
              onPressed: _shareDocument,
              tooltip: 'Compartir documento',
            ),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay registros guardados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_fileExists)
                        ElevatedButton.icon(
                          onPressed: _isCreatingDoc ? null : _createDocument,
                          icon: _isCreatingDoc
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add_circle_outline),
                          label: Text(_isCreatingDoc ? 'Creando...' : 'Crear documento'),
                        ),
                      if (!_fileExists)
                        const SizedBox(height: 8),
                      if (!_fileExists)
                        Text(
                          'Cree el archivo Excel para empezar a agregar registros',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      if (_filePath != null) ...[
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              const Text(
                                'Ubicación del archivo:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _filePath!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _copyFilePath,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copiar ruta'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_filePath != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue[50],
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Archivo:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _filePath!,
                                    style: const TextStyle(fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: _copyFilePath,
                              tooltip: 'Copiar ruta',
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record['name'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _isDeleting && _deletingIndex == index
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                              tooltip: 'Eliminar registro',
                                              onPressed: _isDeleting
                                                  ? null
                                                  : () => _confirmAndDeleteRecord(index),
                                            ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.badge,
                                    'DPI:',
                                    record['dpi'] ?? 'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.description,
                                    'Motivo:',
                                    record['reason'] ?? 'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    'Fecha:',
                                    record['date'] ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
