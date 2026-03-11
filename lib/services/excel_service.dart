import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Servicio para manejar la creación y escritura de archivos Excel
class ExcelService {
  static const String fileName = 'registro_tramites.xlsx';
  
  Future<String> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> _getExcelFilePath() async {
    final dir = await _getDocumentsDirectory();
    return path.join(dir, fileName);
  }

  Future<bool> fileExists() async {
    final filePath = await _getExcelFilePath();
    return File(filePath).existsSync();
  }

  Future<bool> createDocument() async {
    try {
      await _createNewExcel();
      return true;
    } catch (e) {
      print('Error al crear documento: $e');
      return false;
    }
  }

  /// Crea un nuevo archivo Excel con encabezados en NEGRITA + columna No.
  Future<void> _createNewExcel() async {
    final filePath = await _getExcelFilePath();
    
    var excel = Excel.createExcel();
    excel.delete('Sheet1');
    Sheet sheetObject = excel['Registro Trámites'];

    final headers = [
      'No.',
      '\t Fecha',
      '\t Nombre\n',
      '\t DPI\n',
      '\t Motivo\n'
    ];

    sheetObject.appendRow(headers);

    // Estilo en negrita para encabezados
    var headerStyle = CellStyle(bold: true);

    for (int i = 0; i < headers.length; i++) {
      final cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.cellStyle = headerStyle;
    }

    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }

  /// Elimina un registro por índice (basado en la posición mostrada en la app)
  /// y reenumera la columna "No." para mantener la numeración correlativa.
  ///
  /// [index] es 0‑based respecto a la lista de registros que devuelve
  /// `readAllRecords` (es decir, salta la fila de encabezados).
  Future<bool> deleteRecordByIndex(int index) async {
    try {
      if (index < 0) return false;

      if (!await fileExists()) {
        print('No se puede eliminar: el archivo Excel no existe');
        return false;
      }

      // Leer todos los registros como los ve la app
      final allRecords = await readAllRecords();

      if (index >= allRecords.length) {
        print('No se puede eliminar: índice fuera de rango');
        return false;
      }

      // Eliminar el registro correspondiente
      allRecords.removeAt(index);

      final filePath = await _getExcelFilePath();

      // Crear un nuevo libro Excel y reescribir encabezados + filas
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      Sheet sheetObject = excel['Registro Trámites'];

      final headers = [
        'No.',
        '\t Fecha',
        '\t Nombre\n',
        '\t DPI\n',
        '\t Motivo\n'
      ];

      sheetObject.appendRow(headers);

      // Estilo en negrita para encabezados
      var headerStyle = CellStyle(bold: true);
      for (int i = 0; i < headers.length; i++) {
        final cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = headerStyle;
      }

      // Reescribir los registros restantes reenumerando la columna No.
      for (int i = 0; i < allRecords.length; i++) {
        final record = allRecords[i];
        sheetObject.appendRow([
          i + 1, // nueva numeración
          record['date'] ?? '',
          record['name'] ?? '',
          record['dpi'] ?? '',
          record['reason'] ?? '',
        ]);
      }

      final List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath).writeAsBytesSync(fileBytes);
        return true;
      }

      return false;
    } catch (e) {
      print('Error al eliminar registro: $e');
      return false;
    }
  }

  /// Agrega una nueva fila:
  /// ✔ Con contador automático (No.)
  /// ✔ Evitando duplicados (Fecha + DPI)
  Future<bool> addRecord({
    required String date,
    required String name,
    required String dpi,
    required String reason,
  }) async {
    try {
      final filePath = await _getExcelFilePath();
      
      if (!await fileExists()) {
        await _createNewExcel();
      }

      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      Sheet sheetObject = excel['Registro Trámites'];

      // 🔍 Verificar duplicados (Fecha + DPI)
      for (var row in sheetObject.rows.skip(1)) {
        final existingDate = row[1]?.value?.toString() ?? '';
        final existingDpi  = row[3]?.value?.toString() ?? '';

        if (existingDate == date && existingDpi == dpi) {
          print('⚠️ Registro duplicado detectado');
          return false;
        }
      }

      // 📊 Contador automático
      final nextNumber = sheetObject.rows.length; // ya incluye encabezado

      // Agregar fila
      sheetObject.appendRow([
        nextNumber,
        date,
        name,
        dpi,
        reason,
      ]);

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

  Future<String> getFilePath() async {
    return await _getExcelFilePath();
  }

  /// Lee todos los registros del archivo Excel
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

      // Saltar encabezados (fila 0)
      for (var row in sheetObject.rows.skip(1)) {
        if (row.length >= 5) {
          records.add({
            'no': row[0]?.value?.toString() ?? '',
            'date': row[1]?.value?.toString() ?? '',
            'name': row[2]?.value?.toString() ?? '',
            'dpi': row[3]?.value?.toString() ?? '',
            'reason': row[4]?.value?.toString() ?? '',
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
