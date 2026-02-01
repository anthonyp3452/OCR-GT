# Registro de Trámites DPI - Guatemala

Aplicación móvil Android desarrollada con Flutter para registro de personas que realizan trámites, utilizando escaneo de DPI (Documento Personal de Identificación) de Guatemala con OCR offline.

## 🎯 Características

- ✅ **100% Offline**: No requiere conexión a internet
- 📷 **Escaneo de DPI**: Usa la cámara del dispositivo para capturar el documento
- 🔍 **OCR Offline**: Google ML Kit - Text Recognition para extraer texto sin internet
- 📝 **Extracción Automática**: Identifica automáticamente nombre completo y número de DPI (13 dígitos)
- ✏️ **Formulario Editable**: Permite editar y completar la información extraída
- 📊 **Almacenamiento Local**: Guarda los registros en archivo Excel (.xlsx) en el dispositivo
- 📋 **Visualización**: Lista todos los registros guardados con detalles

## 📋 Requisitos

- Flutter SDK 3.0.0 o superior
- Android SDK 21 (Android 5.0) o superior
- Android Studio o VS Code con extensiones de Flutter
- Dispositivo Android físico o emulador con cámara

## 🚀 Instalación

### 1. Clonar o descargar el proyecto

```bash
cd dpi_scanner_guatemala
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Verificar configuración

```bash
flutter doctor
```

Asegúrate de que Flutter esté correctamente configurado y que tengas un dispositivo Android conectado o emulador ejecutándose.

### 4. Ejecutar la aplicación

```bash
flutter run
```

O desde Android Studio/VS Code, presiona F5 o el botón de ejecutar.

## 📱 Uso de la Aplicación

### Escanear DPI

1. Abre la aplicación
2. Presiona el botón **"Escanear DPI"**
3. Permite el acceso a la cámara cuando se solicite
4. Enfoca el DPI en la pantalla y captura la foto
5. La aplicación procesará la imagen con OCR

### Completar Registro

1. Después del escaneo, se abrirá un formulario con:
   - **Nombre**: Pre-llenado si se detectó en el OCR
   - **DPI**: Pre-llenado si se detectó (13 dígitos)
   - **Motivo del trámite**: Campo a completar manualmente

2. Edita los campos si es necesario
3. Completa el motivo del trámite
4. Presiona **"Guardar Registro"**

### Ver Registros

1. Desde la pantalla principal, presiona el ícono de lista (☰) en la esquina superior derecha
2. Verás todos los registros guardados con:
   - Fecha y hora
   - Nombre completo
   - Número de DPI
   - Motivo del trámite
3. Puedes copiar la ruta del archivo Excel para acceder desde un explorador de archivos

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── screens/
│   ├── home_screen.dart      # Pantalla principal con escáner
│   ├── form_screen.dart      # Formulario para completar registro
│   └── records_screen.dart   # Lista de registros guardados
└── services/
    ├── ocr_service.dart      # Servicio de OCR con Google ML Kit
    ├── parser.dart           # Parser para extraer nombre y DPI
    └── excel_service.dart    # Servicio para manejar archivos Excel
```

## 🔧 Tecnologías Utilizadas

- **Flutter**: Framework multiplataforma
- **Google ML Kit - Text Recognition**: OCR offline
- **camera / image_picker**: Captura de imágenes desde cámara
- **path_provider**: Manejo de rutas de archivos locales
- **excel**: Generación y lectura de archivos Excel
- **permission_handler**: Manejo de permisos de Android

## 📄 Formato del Archivo Excel

El archivo `registro_tramites.xlsx` se guarda en el directorio de documentos de la aplicación con las siguientes columnas:

| Fecha | Nombre | DPI | Motivo |
|-------|--------|-----|--------|
| 2026-01-25 10:30:00 | Juan Pérez | 1234567890123 | Consulta médica |
| ... | ... | ... | ... |

## 🔐 Permisos Requeridos

La aplicación solicita los siguientes permisos:

- **Cámara**: Para capturar fotos del DPI
- **Almacenamiento**: Para guardar el archivo Excel

Estos permisos se solicitan automáticamente al iniciar la aplicación.

## 🐛 Solución de Problemas

### El OCR no reconoce el texto

- Asegúrate de que la imagen esté bien enfocada
- Verifica que haya buena iluminación
- El DPI debe estar completo y visible en la foto
- Intenta capturar nuevamente con mejor calidad

### No se puede guardar el archivo

- Verifica que la aplicación tenga permisos de almacenamiento
- Asegúrate de que haya espacio disponible en el dispositivo

### La cámara no se abre

- Verifica los permisos de cámara en Configuración > Aplicaciones
- Reinicia la aplicación después de otorgar permisos

## 📝 Notas Importantes

- La aplicación funciona **100% offline**, no requiere internet
- El archivo Excel se guarda localmente en el dispositivo
- Los datos no se sincronizan con ningún servidor
- Para acceder al archivo desde una PC, conecta el dispositivo por USB y navega a la carpeta de la aplicación

## 🔄 Próximas Mejoras (Opcional)

- [ ] Validación mejorada del formato de DPI
- [ ] Búsqueda y filtrado de registros
- [ ] Exportación a otros formatos (CSV, PDF)
- [ ] Modo oscuro
- [ ] Soporte para múltiples idiomas

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso personal y comercial.

## 👨‍💻 Desarrollo

Desarrollado con Flutter para uso en oficinas guatemaltecas que requieren registro de trámites con DPI.

---

**Versión**: 1.0.0  
**Última actualización**: Enero 2026
