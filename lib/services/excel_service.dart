import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Servicio para manejar la creación y escritura de archivos Excel
class ExcelService {
  static const String fileName = 'registro_tramites.xlsx';
  
  /// Obtiene la ruta del directorio de documentos de la aplicación
  Future<String> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Obtiene la ruta completa del archivo Excel
  Future<String> _getExcelFilePath() async {
    final dir = await _getDocumentsDirectory();
    return path.join(dir, fileName);
  }

  /// Verifica si el archivo Excel existe
  Future<bool> fileExists() async {
    final filePath = await _getExcelFilePath();
    return File(filePath).existsSync();
  }

  /// Crea un nuevo archivo Excel con los encabezados.
  /// Puede llamarse manualmente desde el botón "Crear documento".
  Future<bool> createDocument() async {
    try {
      await _createNewExcel();
      return true;
    } catch (e) {
      print('Error al crear documento: $e');
      return false;
    }
  }

  /// Crea un nuevo archivo Excel con los encabezados (método interno)
  Future<void> _createNewExcel() async {
    final filePath = await _getExcelFilePath();
    
    var excel = Excel.createExcel();
    excel.delete('Sheet1'); // Eliminar hoja por defecto
    Sheet sheetObject = excel['Registro Trámites'];
    
    // Agregar encabezados
    sheetObject.appendRow([
      'Fecha',
      'Nombre',
      'DPI',
      'Motivo'
    ]);
    
    // Guardar archivo
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }

  /// Agrega una nueva fila al archivo Excel existente
  /// 
  /// [date] - Fecha del registro
  /// [name] - Nombre completo de la persona
  /// [dpi] - Número de DPI
  /// [reason] - Motivo del trámite
  Future<bool> addRecord({
    required String date,
    required String name,
    required String dpi,
    required String reason,
  }) async {
    try {
      final filePath = await _getExcelFilePath();
      
      // Si el archivo no existe, crearlo
      if (!await fileExists()) {
        await _createNewExcel();
      }

      // Leer archivo existente
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      
      // Obtener la hoja de trabajo
      Sheet sheetObject = excel['Registro Trámites'];
      
      // Agregar nueva fila
      sheetObject.appendRow([date, name, dpi, reason]);
      
      // Guardar cambios
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath).writeAsBytesSync(fileBytes);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error al agregar registro: $e');
      return false;
    }
  }

  /// Obtiene la ruta del archivo Excel para mostrar al usuario
  Future<String> getFilePath() async {
    return await _getExcelFilePath();
  }

  /// Lee todos los registros del archivo Excel
  /// 
  /// Retorna una lista de mapas con los datos
  Future<List<Map<String, String>>> readAllRecords() async {
    try {
      if (!await fileExists()) {
        return [];
      }

      final filePath = await _getExcelFilePath();
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      
      Sheet sheetObject = excel['Registro Trámites'];
      
      List<Map<String, String>> records = [];
      
      // Leer desde la fila 1 (saltar encabezados en fila 0)
      for (var row in sheetObject.rows.skip(1)) {
        if (row.length >= 4) {
          records.add({
            'date': row[0]?.value?.toString() ?? '',
            'name': row[1]?.value?.toString() ?? '',
            'dpi': row[2]?.value?.toString() ?? '',
            'reason': row[3]?.value?.toString() ?? '',
          });
        }
      }
      
      return records;
    } catch (e) {
      print('Error al leer registros: $e');
      return [];
    }
  }
}
