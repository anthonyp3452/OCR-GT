# 📱 Instrucciones Detalladas de Instalación

## Requisitos Previos

### 1. Instalar Flutter

1. Descarga Flutter desde: https://flutter.dev/docs/get-started/install
2. Extrae el archivo ZIP en una ubicación (ej: `C:\src\flutter`)
3. Agrega Flutter al PATH de Windows:
   - Busca "Variables de entorno" en Windows
   - Agrega `C:\src\flutter\bin` al PATH
4. Verifica la instalación:
   ```bash
   flutter doctor
   ```

### 2. Instalar Android Studio

1. Descarga Android Studio desde: https://developer.android.com/studio
2. Instala Android Studio con los componentes recomendados
3. Abre Android Studio y configura el SDK de Android
4. Acepta las licencias:
   ```bash
   flutter doctor --android-licenses
   ```

### 3. Configurar Dispositivo Android

**Opción A: Dispositivo Físico** 
1. Habilita "Opciones de desarrollador" en tu Android:
   - Ve a Configuración > Acerca del teléfono
   - Toca 7 veces en "Número de compilación"
2. Habilita "Depuración USB"
3. Conecta el dispositivo por USB
4. Verifica conexión:
   ```bash
   flutter devices
   ```

**Opción B: Emulador Android**
1. Abre Android Studio
2. Ve a Tools > Device Manager
3. Crea un nuevo dispositivo virtual (AVD)
4. Selecciona un dispositivo con Android 5.0 o superior
5. Inicia el emulador

## Instalación del Proyecto

### Paso 1: Navegar al Proyecto

```bash
cd C:\Users\48126\Desktop\IGSS\OCR
```

### Paso 2: Instalar Dependencias

```bash
flutter pub get
```

Este comando descargará todas las dependencias necesarias:
- google_mlkit_text_recognition
- camera
- image_picker
- path_provider
- excel
- permission_handler
- intl

### Paso 3: Verificar Configuración

```bash
flutter doctor -v
```

Asegúrate de que todo esté marcado con ✓ (check verde).

### Paso 4: Ejecutar la Aplicación

**Desde la terminal:**
```bash
flutter run
```

**Desde Android Studio:**
1. Abre el proyecto en Android Studio
2. Espera a que indexe los archivos
3. Selecciona tu dispositivo/emulador en la barra superior
4. Presiona el botón ▶️ (Run)

**Desde VS Code:**
1. Abre el proyecto en VS Code
2. Presiona F5 o ve a Run > Start Debugging
3. Selecciona "Dart & Flutter"

## Compilar APK para Instalación

### APK de Debug (para pruebas)

```bash
flutter build apk --debug
```

El APK estará en: `build\app\outputs\flutter-apk\app-debug.apk`

### APK de Release (para distribución)

```bash
flutter build apk --release
```

El APK estará en: `build\app\outputs\flutter-apk\app-release.apk`

## Solución de Problemas Comunes

### Error: "SDK location not found"

Crea el archivo `android/local.properties` con:
```
sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk
```
(Ajusta la ruta según tu instalación)

### Error: "Gradle sync failed"

1. Abre Android Studio
2. Ve a File > Sync Project with Gradle Files
3. Espera a que termine la sincronización

### Error: "Permission denied" en permisos

1. Ve a Configuración > Aplicaciones en tu Android
2. Encuentra la app "Registro Trámites DPI"
3. Ve a Permisos
4. Habilita Cámara y Almacenamiento manualmente

### La cámara no funciona

1. Verifica que el dispositivo tenga cámara
2. Si usas emulador, asegúrate de que tenga cámara configurada
3. Revisa los permisos de la aplicación

### Error: "cannot connect to daemon at tcp:5037" / "daemon still not running"

Este error suele ocurrir cuando ADB no puede conectar con el dispositivo. La compilación termina bien, pero falla la instalación. Soluciones:

1. **Reiniciar ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

2. **Verificar conexión del dispositivo:**
   - Desconecta y vuelve a conectar el cable USB
   - En el teléfono, acepta el mensaje "¿Permitir depuración USB?"
   - Prueba otro puerto USB o cable

3. **Si sigue fallando, instala el APK manualmente:**
   ```bash
   flutter build apk --debug
   ```
   Luego copia `build\app\outputs\flutter-apk\app-debug.apk` al teléfono e instálalo manualmente.

### Error al generar Excel

1. Verifica permisos de almacenamiento
2. Asegúrate de que haya espacio en el dispositivo
3. Revisa los logs:
   ```bash
   flutter run -v
   ```

## Estructura de Carpetas Esperada

```
OCR/
├── android/              # Configuración Android
├── lib/                  # Código fuente Dart
│   ├── main.dart
│   ├── screens/
│   └── services/
├── pubspec.yaml          # Dependencias
├── README.md
└── INSTRUCCIONES_INSTALACION.md
```

## Próximos Pasos

1. ✅ Instalar Flutter y Android Studio
2. ✅ Configurar dispositivo/emulador
3. ✅ Ejecutar `flutter pub get`
4. ✅ Ejecutar `flutter run`
5. ✅ Probar la aplicación escaneando un DPI

## Notas Importantes

- La primera compilación puede tardar varios minutos
- Asegúrate de tener al menos 2GB de espacio libre
- El proyecto funciona 100% offline después de la instalación
- Los archivos Excel se guardan en el almacenamiento interno de la app

---

**¿Necesitas ayuda?** Revisa los logs con `flutter run -v` para más detalles sobre errores.
