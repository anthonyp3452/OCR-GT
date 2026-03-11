import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/excel_service.dart';

/// ============================================================================
/// OPCIONES DEL MENÚ DESPLEGABLE "Motivo del trámite" (solo cuando viene del escáner)
/// Para AGREGAR: añada cadenas a la lista. Para QUITAR: elimine las que no desee.
/// ============================================================================
const List<String> _motivoTramiteOpciones = [
  'JUBILACION',
  'CARNET DE AFILIACIÓN',
  'CONSULTA DE JUBILACION',
  'ACTA DE SUPERVIVENCIA',
  'INSCRIPCION',
  'ACTUALIZACIÓN DE DATOS',
  'CONSULTA PAGO DE SUSPENSION',
  'CUOTA MURTUORIA IVS',
  'CUOTA MURTUORIA AFILIADOS',
  'CONTRIBUCION VOLUNTARIA',
  'MEDICINA LEGAL',
  'ACTUALIZACION JUBILADO',
];

const String _motivoOtroValue = '__OTRO__';

class FormScreen extends StatefulWidget {
  final String initialName;
  final String initialDPI;
  /// true = registro manual (motivo se escribe a mano)
  /// false = viene del escáner (motivo en menú desplegable)
  final bool isManualEntry;

  const FormScreen({
    super.key,
    required this.initialName,
    required this.initialDPI,
    this.isManualEntry = false,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dpiController = TextEditingController();
  final _reasonController = TextEditingController(); // Para "Otro"
  final ExcelService _excelService = ExcelService();
  String? _selectedMotivo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _dpiController.text = widget.initialDPI;
    // Por defecto, en registro manual se usa "Otro" para permitir escribir libremente,
    // pero el usuario puede cambiarlo a un motivo de la lista si lo desea.
    if (widget.isManualEntry) {
      _selectedMotivo = _motivoOtroValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dpiController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _getReasonValue() {
    if (_selectedMotivo == _motivoOtroValue) {
      return _reasonController.text.trim();
    }
    if (_selectedMotivo == null) return '';
    return _selectedMotivo!;
  }

  /// Guarda el registro en el archivo Excel
  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Obtener fecha actual
      String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Guardar en Excel
      bool success = await _excelService.addRecord(
        date: currentDate,
        name: _nameController.text.trim(),
        dpi: _dpiController.text.trim(),
        reason: _getReasonValue(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el registro'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Valida que el nombre tenga al menos 2 palabras (nombre y apellido)
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    List<String> words = value.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length < 2) {
      return 'Ingrese al menos nombre y apellido';
    }
    return null;
  }

  /// Valida que el DPI tenga 13 dígitos
  String? _validateDPI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DPI es requerido';
    }
    
    // Remover espacios y caracteres no numéricos
    String cleanDPI = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanDPI.length != 13) {
      return 'El DPI debe tener 13 dígitos';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Registro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Complete la información del trámite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                hintText: 'Ingrese nombre y apellido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: _validateName,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _dpiController,
              decoration: const InputDecoration(
                labelText: 'Número de DPI *',
                hintText: '0000000000000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              maxLength: 13,
              validator: _validateDPI,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedMotivo,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Motivo del trámite *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              hint: const Text('Seleccione el motivo'),
              items: [
                ..._motivoTramiteOpciones.map(
                  (opcion) => DropdownMenuItem<String>(
                    value: opcion,
                    child: Text(opcion, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: _motivoOtroValue,
                  child: Text('OTRO (Escribir manualmente)'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMotivo = value;
                  if (_selectedMotivo != _motivoOtroValue) {
                    _reasonController.clear();
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione el motivo del trámite';
                }
                return null;
              },
            ),
            if (_selectedMotivo == _motivoOtroValue) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Especifique el motivo *',
                  hintText: 'Escriba el motivo del trámite',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                validator: (value) {
                  if (_selectedMotivo == _motivoOtroValue) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El motivo es requerido';
                    }
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar Registro'),
            ),
            const SizedBox(height: 16),
            if (!widget.isManualEntry)
              TextButton.icon(
                onPressed: _isSaving ? null : () => Navigator.pop(context, 'retry'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Reintentar fotografía'),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
