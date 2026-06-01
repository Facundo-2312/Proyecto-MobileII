# FoodFinder 🍽️

Una aplicación Flutter para descubrir restaurantes en Uruguay usando tu ubicación y mostrarlos en un mapa interactivo.

## Características ✨

- **Mapa Interactivo**: Visualiza restaurantes cercanos en tiempo real con Google Maps en mobile y OpenStreetMap en web
- **Geolocalización GPS**: Obtiene automáticamente tu ubicación actual
- **Datos Mock**: 13 restaurantes simulados de Uruguay con información completa
- **Lista de Restaurantes**: Alterna entre vista de mapa y lista de restaurantes
- **Detalles del Restaurante**: Información completa con mapa integrado, teléfono y dirección
- **Distancia Calculada**: Calcula automáticamente la distancia de cada restaurante
- **Búsqueda Eficiente**: Radio de búsqueda de 50 km y fallback a restaurantes reales ordenados por distancia
- **Vista Smartwatch (Demo)**: Interfaz tipo reloj integrada en la app principal

## Requisitos Técnicos

- Flutter 3.9.2 o superior
- Dart 3.9.2 o superior
- Permisos de ubicación en Android e iOS

### Dependencias Principales

```yaml
google_maps_flutter: ^2.5.0
geolocator: ^10.1.0
flutter_map: ^6.1.0
latlong2: ^0.9.0
```

## Instalación 🚀

### 1. Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd foodfinder
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar el mapa

En Android e iOS la app usa Google Maps. En web usa OpenStreetMap, por lo que no necesita API key.

#### Android:
1. Abre `android/app/build.gradle.kts`
2. Define `MAPS_API_KEY` en `android/gradle.properties` o como variable de entorno.

```properties
MAPS_API_KEY=TU_API_KEY_AQUI
```

#### iOS:
1. Abre `ios/Runner/Info.plist`
2. Agrega tu API key de Google Maps en la configuración de GoogleMaps

### 4. Ejecutar la aplicación
```bash
flutter run
```

Para ejecución en release (recomendado):
```bash
flutter run --release
```

## Estructura del Proyecto 📁

```
lib/
├── main.dart                      # Punto de entrada
├── app_constants.dart             # Constantes y datos mock
├── restaurant_model.dart          # Modelo de datos
├── location_service.dart          # Servicio de geolocalización
├── restaurant_service.dart        # Servicio de restaurantes
├── map_screen.dart               # Pantalla principal (mapa)
├── restaurant_details_screen.dart # Pantalla de detalles
├── restaurant_marker_popup.dart   # Widget de popup del marcador
└── restaurant_list_widget.dart    # Widget de lista de restaurantes
```

## Funcionalidades Principales 🎯

### 1. Pantalla Principal (Mapa)
- Muestra tu ubicación con marcador azul
- Restaurantes cercanos con marcadores naranjas
- Panel inferior con lista horizontal desplazable
- Botón de actualización de ubicación

### 2. Vista de Lista
- Alterna entre vista de mapa y lista
- Muestra distancia, rating y tipo de comida
- Navegación rápida a detalles del restaurante

### 3. Detalles del Restaurante
- Imagen del restaurante
- Información básica (nombre, tipo, rating)
- Dirección y teléfono
- Mapa con ubicación del restaurante y tu ubicación
- Botones para llamar y compartir

### 4. Geolocalización
- Solicita permisos automáticamente
- Fallback a ubicación por defecto (Montevideo, Uruguay)
- Actualización manual disponible

## Permisos Requeridos 🔐

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>FoodFinder necesita acceso a tu ubicación para mostrar restaurantes cercanos</string>
```

## Uso 📱

1. **Abre la aplicación**: Se cargará automáticamente tu ubicación
2. **Visualiza el mapa**: Los restaurantes aparecerán como marcadores naranjas
3. **Interactúa con los marcadores**: Toca un marcador para ver un popup con información
4. **Ver detalles**: Presiona el botón "Ver detalles" en el popup
5. **Cambiar vista**: Usa el icono en la esquina superior derecha para alternar entre mapa y lista
6. **Actualizar ubicación**: Presiona el botón flotante en la esquina inferior derecha

## Datos Mock 🍴

La aplicación incluye restaurantes simulados de Uruguay, con foco en Montevideo y Rivera:

1. **Pizzería Morosoli** - Italiano (Montevideo)
2. **Chivitería El Corte** - Uruguayo (Montevideo)
3. **Parrilla Asadito** - Carne (Montevideo)
4. **Wok & Roll Oriental** - Asiático (Montevideo)
5. **Benedetto Steakhouse** - Restaurante (Rivera)
6. **La Perdiz** - Uruguaya (Rivera)

## Optimizaciones 🚄

- **Bajo Consumo de Batería**: Solo actualiza GPS cuando el usuario lo solicita
- **Caché de Ubicación**: Almacena la última ubicación conocida
- **Renderizado Eficiente**: Usa widgets optimizados para listas infinitas
- **Sin Procesos en Segundo Plano**: Todo se ejecuta bajo demanda del usuario

## Consideraciones Futuras 🔮

- [ ] Integración con API real de restaurantes
- [ ] Filtrado por tipo de comida
- [ ] Búsqueda por nombre
- [ ] Calificaciones y reseñas de usuarios
- [ ] Integración de publicidad
- [ ] Favoritos locales
- [ ] Historial de búsqueda

## Solución de Problemas 🔧

### El mapa no se muestra
- Verifica que Google Maps API esté configurado correctamente
- Comprueba que la API key sea válida
- Reinicia la aplicación

### No se obtiene la ubicación
- Verifica que los permisos estén activados en el dispositivo
- Comprueba que el servicio de ubicación esté habilitado
- La app usará Montevideo como ubicación por defecto si no hay permisos

### La app se congela
- Reinicia el dispositivo
- Ejecuta `flutter clean` y `flutter pub get` nuevamente

## Desarrollo 👨‍💻

### Ejecutar análisis de código
```bash
flutter analyze
```

### Formatear código
```bash
dart format lib/
```

### Ejecutar tests (cuando estén disponibles)
```bash
flutter test
```

## Contribuciones 🤝

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## Licencia 📄

Este proyecto está bajo licencia MIT.

## Autor 👤

Desarrollado como proyecto de demostración de Flutter.

## Contacto 📞

Para preguntas o sugerencias, por favor abre un issue en el repositorio.
