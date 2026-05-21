# 🚀 Guía Rápida - FoodFinder

## Inicio Rápido (5 minutos)

### 1️⃣ Configuración Inicial
```bash
# Entra al directorio
cd foodfinder

# Instala dependencias
flutter pub get
```

### 2️⃣ Google Maps API (IMPORTANTE ⚠️)
**Sin esto, los mapas no funcionarán**

#### Android:
```
Abre: android/app/build.gradle.kts

Busca esta línea:
manifestPlaceholders["com.google.android.geo.API_KEY"] = "AIzaSyDemoKeyChangeThis123456789"

Reemplaza con tu API key:
manifestPlaceholders["com.google.android.geo.API_KEY"] = "TU_CLAVE_AQUI"
```

#### iOS:
```
Abre: ios/Runner/Info.plist

Ya está configurada, pero verifica que funcione
```

### 3️⃣ Ejecutar
```bash
# En modo debug (más lento)
flutter run

# En modo release (recomendado)
flutter run --release
```

## 📱 Funcionalidades Principales

| Función | Cómo Usarla |
|---------|------------|
| **Ver mapa** | Abre la app (pantalla principal) |
| **Ver detalles** | Toca un marcador → "Ver detalles" |
| **Cambiar vista** | Icono lista/mapa (arriba derecha) |
| **Actualizar ubicación** | Botón naranja (abajo derecha) |
| **Ver lista completa** | Presiona el icono de lista |

## 📂 Archivos Importantes

```
📁 lib/
  ├─ 📄 main.dart                    ← ENTRADA PRINCIPAL
  ├─ 📄 map_screen.dart              ← Pantalla de mapa
  ├─ 📄 restaurant_model.dart        ← Modelo de datos
  ├─ 📄 location_service.dart        ← GPS
  └─ 📄 restaurant_service.dart      ← Datos de restaurantes

📁 android/
  └─ 📄 AndroidManifest.xml          ← Permisos

📁 ios/
  └─ 📄 Info.plist                   ← Configuración iOS

📄 README.md                          ← Documentación completa
📄 ARCHITECTURE.md                    ← Arquitectura del proyecto
📄 RESUMEN_ENTREGA.md                ← Resumen del proyecto
```

## 🐛 Solución de Problemas Rápida

### ❌ "El mapa está en blanco"
**Solución**: Configura Google Maps API key en build.gradle.kts

### ❌ "No me pide permisos de ubicación"
**Solución**: Los permisos están configurados, solo aparecen si la app los necesita

### ❌ "La app usa Montevideo como ubicación"
**Solución**: Es normal cuando no hay permisos o no se puede obtener tu GPS. Activa ubicación y vuelve a actualizar.

### ❌ "Errores al compilar"
**Solución**: 
```bash
flutter clean
flutter pub get
flutter run
```

## 📊 Estructura de Datos

### Restaurante (mock de Uruguay)
```dart
{
  id: "1",
  name: "Pizzería Morosoli",
  type: "Italiano",
  latitude: -34.8950,
  longitude: -56.1640,
  rating: 4.7,
  imageUrl: "...",
  address: "Avenida Italia 2960, Montevideo",
  phoneNumber: "+598 2 406 67 67",
  description: "Auténtica pizzería italiana con hornos de leña..."
}
```

## ⚙️ Configuración

### cambiar Ubicación por Defecto
```dart
// En: lib/app_constants.dart
const LatLng defaultLocation = LatLng(40.4168, -3.7038); // ← CAMBIAR
```

### Cambiar Radio de Búsqueda
```dart
// En: lib/app_constants.dart
const double searchRadiusKm = 5.0; // ← CAMBIAR
```

### Agregar más Restaurantes
```dart
// En: lib/app_constants.dart
const List<Map<String, dynamic>> mockRestaurants = [
  // ... existentes ...
  {
    'id': '9',
    'name': 'Tu Restaurante',
    'type': 'Tu Tipo',
    // ... más campos ...
  }
];
```

## 📱 Plataformas Soportadas

- ✅ **Android**: Versión 5.0+ (API 21+)
- ✅ **iOS**: Versión 11.0+
- ⚠️ **Web**: No configurado
- ⚠️ **Desktop**: No configurado

## 🔑 API Keys

### Obtener Google Maps API Key
1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Crea un nuevo proyecto
3. Activa "Maps SDK for Android" y "Maps SDK for iOS"
4. Crea una clave de API
5. Configura restricciones por aplicación

## 📈 Crecimiento del Proyecto

Si quieres agregar más funcionalidades:

### Agregar Búsqueda
```dart
// En RestaurantService
List<Restaurant> search(String query) {
  return _restaurants.where((r) => 
    r.name.contains(query)
  ).toList();
}
```

### Agregar Filtros
```dart
// En RestaurantService  
List<Restaurant> filterByType(String type) {
  return _restaurants.where((r) => 
    r.type == type
  ).toList();
}
```

### Agregar Favoritos
```dart
// Agregar a Restaurant model
bool isFavorite = false;

// Agregar en servicio
void toggleFavorite(String id) { }
```

## 🎯 Checklist Antes de Producción

- [ ] Google Maps API key configurada
- [ ] Permisos de ubicación en AndroidManifest.xml
- [ ] Permisos de ubicación en Info.plist
- [ ] Restaurantes reales en lugar de mock
- [ ] Servidor de datos (API)
- [ ] Pruebas en dispositivo real
- [ ] Iconos y splash screen personalizados
- [ ] Nombre de app cambiado

## 📞 Soporte Técnico

### Comandos Útiles
```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Analizar código
flutter analyze

# Formatear código
dart format lib/

# Ver versión
flutter --version
```

### Logs de Depuración
```bash
# Ver todos los logs
flutter logs

# Ver solo errores
flutter logs --grep "error"
```

## 🎓 Aprender Más

- [Flutter Official Docs](https://flutter.dev/docs)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Dart Language](https://dart.dev/guides)

---

**¡Listo para usar!** 🚀

Para documentación completa, ver **README.md**  
Para arquitectura, ver **ARCHITECTURE.md**
