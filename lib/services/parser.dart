class DPIParser {
  static final RegExp _soloLetras = RegExp(r'^[A-Za-zÁÉÍÓÚÑáéíóúñ ]+$');

  static final List<String> _bloqueados = [
    'APELLIDOS',
    'I GVEN NAMES',
    'I GIVEN NAMES',
    'NOMBRES',
    'I SURNAME',
    'SURNAME',
    'CÓDIGO ÚNICO DE IDENTIFICACIÓN',
    'CODIGO UNICO DE IDENTIFICACION',
    'CÓDIGO ÚNICO DE IDENTIFICACIÓN CUI',
    'CODIGO UNICO DE IDENTIFICACION CUI',
    'CUI',
    'DOCUMENTO PERSONAL DE IDENTIFICACION',
    'DOCUMENTO PERSONAL DE IDENTIFICACIÓN',
    'REPUBLICA DE GUATEMALA',
    'REPÚBLICA DE GUATEMALA',
    'REGISTRO NACIONAL DE LAS PERSONAS',
    'RENAP',
    'GUATEMALA',
    'DPI',
    'NACIONALIDAD',
    'SEXO',
    'FECHA',
    'LUGAR',
    'MUNICIPIO',
    'DEPARTAMENTO',
    'PAIS DE NACIMIENTO',
    'PAÍS DE NACIMIENTO',
    'PAIS NACIMIENTO',
    'PAÍS NACIMIENTO',
  ];

  String _clean(String t) => t
      .replaceAll(RegExp(r'[^\w\sÁÉÍÓÚÑáéíóúñ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _esLineaNombre(String l) {
    final u = l.toUpperCase();
    if (!_soloLetras.hasMatch(l)) return false;
    if (l.length < 4) return false;
    for (final b in _bloqueados) {
      if (u == b || u.startsWith(b)) return false;
    }
    return true;
  }

  String _limpiarEtiqueta(String l) {
    return l
        .replaceAll(RegExp(r'^APELLIDOS?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^NOMBRES?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^C[ÓO]DIGO\s+ÚNICO\s+DE\s+IDENTIFICACI[ÓO]N\s*-?\s*CUI\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^PA[ÍI]S\s+DE\s+NACIMIENTO\s*', caseSensitive: false), '')
        .trim();
  }

  String? extractName(String ocrText) {
    if (ocrText.trim().isEmpty) return null;

    final lines = ocrText
        .split('\n')
        .map((l) => _clean(l))
        .where((l) => l.isNotEmpty)
        .toList();

    final Set<String> nombres = {};
    final Set<String> apellidos = {};

    for (int i = 0; i < lines.length; i++) {
      final u = lines[i].toUpperCase();

      if (u.contains('REGISTRO NACIONAL DE LAS PERSONAS')) continue;
      if (u == 'RENAP') continue;

      // 🔹 APELLIDOS
      if (u.contains('APELLIDO')) {
        final l = _limpiarEtiqueta(lines[i]);
        if (_esLineaNombre(l)) apellidos.add(l);

        if (i + 1 < lines.length && _esLineaNombre(lines[i + 1])) {
          apellidos.add(lines[i + 1]);
        }
      }

      // 🔹 NOMBRES
      if (u.contains('NOMBRE')) {
        final l = _limpiarEtiqueta(lines[i]);
        if (_esLineaNombre(l)) nombres.add(l);

        if (i + 1 < lines.length && _esLineaNombre(lines[i + 1])) {
          nombres.add(lines[i + 1]);
        }
      }
    }

    if (nombres.isNotEmpty && apellidos.isNotEmpty) {
      return '${nombres.join(' ')} ${apellidos.join(' ')}'.trim();
    }

    // 🔹 Fallback seguro
    for (final l in lines) {
      final u = l.toUpperCase();
      if (u.contains('REPUBLICA') ||
          u.contains('GUATEMALA') ||
          u.contains('REGISTRO') ||
          u.contains('RENAP') ||
          u.contains('DOCUMENTO') ||
          u.contains('CÓDIGO') ||
          u.contains('CODIGO') ||
          u.contains('PAIS') ||
          u.contains('NACIMIENTO')) {
        continue;
      }

      if (_esLineaNombre(l) && l.split(' ').length >= 2) {
        return l;
      }
    }

    return null;
  }

  String? extractDPI(String ocrText) {
    final RegExp dpiPattern = RegExp(r'(\d[\s-]?){12}\d');
    final match = dpiPattern.firstMatch(ocrText);

    if (match != null) {
      return match.group(0)!.replaceAll(RegExp(r'[^\d]'), '');
    }

    final allDigits = ocrText.replaceAll(RegExp(r'[^\d]'), '');
    if (allDigits.length >= 13) {
      return allDigits.substring(0, 13);
    }

    return null;
  }

  Map<String, String?> parseDPI(String ocrText) {
    return {
      'name': extractName(ocrText),
      'dpi': extractDPI(ocrText),
    };
  }
}