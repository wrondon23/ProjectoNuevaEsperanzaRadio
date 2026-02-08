# Radio Nueva Esperanza App

Aplicación móvil oficial de la Iglesia Adventista Nueva Esperanza. Desarrollada en Flutter.

## Características

- 📻 **Radio en Vivo**: Reproducción de streaming (Mixlr). Funciona en segundo plano.
- 📢 **Anuncios**: Tablón de noticias importantes.
- 🗓️ **Actividades**: Calendario de eventos y cultos.
- ℹ️ **Quiénes Somos**: Información sobre la iglesia.

## Estructura del Proyecto

El proyecto sigue una arquitectura limpia ligera organizada por features:

- `lib/core`: Constantes, temas y utilidades.
- `lib/data`: Modelos, repositorios y servicios (Audio).
- `lib/features`: Pantallas y lógica (Home, Radio, Anuncios, etc).
- `assets/data`: Archivos JSON con el contenido local.

## Configuración y Ejecución

### Requisitos Previos

- Flutter SDK instalado (v3.0+)
- Entorno configurado para Android y/o iOS.

### Instalación

1. Clona el repositorio o descarga el código.
2. Navega a la carpeta del proyecto:
   ```bash
   cd radio_nueva_esperanza
   ```
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Si falta generar las carpetas nativas (Android/iOS) porque solo generaste el código Dart:
   ```bash
   flutter create . --org com.nuevaesperanza
   ```

### Ejecutar

```bash
flutter run
```

## Personalización

### Cambiar URL de la Radio
Edita `lib/data/services/audio_handler.dart` y modifica la variable `_streamUrl`:
```dart
static const _streamUrl = 'https://stream.mixlr.com/TU_ID';
```

### Cambiar Datos (Anuncios/Actividades)
Modifica los archivos JSON en `assets/data/`.
- `announcements.json`: Lista de anuncios.
- `activities.json`: Lista de eventos.

### Cambiar Textos / Quiénes Somos
Edita `lib/features/about/screens/about_screen.dart` para cambiar la información estática.

## Compilación (Build)

### Android
```bash
flutter build apk --release
# O para App Bundle (Play Store)
flutter build appbundle --release
```

### iOS
Necesitas macOS y Xcode.
```bash
flutter build ipa --release
```

## Roadmap

- [ ] Integrar Firebase para Notificaciones Push (FCM).
- [ ] Migrar datos a Firebase Firestore (backend real).
- [ ] Agregar slider de volumen en el reproductor.
