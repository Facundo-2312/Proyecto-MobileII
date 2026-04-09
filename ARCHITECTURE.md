# Arquitectura FoodFinder

## Descripción General

FoodFinder es una aplicación de Flutter que sigue una arquitectura modular y escalable, separando las responsabilidades en capas distintas.

## Capas de Arquitectura

### 1. **Capa de Presentación (UI)**
Responsable de la interfaz de usuario y la interacción con el usuario.

- **`map_screen.dart`**: Pantalla principal que gestiona el mapa, marcadores y vista general
- **`restaurant_details_screen.dart`**: Pantalla de detalles del restaurante
- **`restaurant_marker_popup.dart`**: Widget para el popup de información del marcador
- **`restaurant_list_widget.dart`**: Widget para la lista de restaurantes

**Características**:
- Usa State Management basado en setState
- Separación clara de responsabilidades
- Widgets reutilizables

### 2. **Capa de Lógica de Negocio (Services)**
Gestiona la lógica de aplicación independiente de la UI.

#### LocationService (`location_service.dart`)
```dart
- checkAndRequestPermissions()      // Solicita permisos de ubicación
- getCurrentLocation()              // Obtiene posición actual
- updateLocation()                  // Actualiza manualmente
- getLastKnownLocation()            // Retorna ubicación conocida
```

**Singleton Pattern**: Una única instancia durante toda la sesión

#### RestaurantService (`restaurant_service.dart`)
```dart
- initialize()                      // Carga datos mock
- getAllRestaurants()               // Retorna todos los restaurantes
- getNearbyRestaurants(location)    // Filtra por distancia
- searchRestaurants(query)          // Búsqueda por nombre/tipo
- getRestaurantById(id)             // Obtiene un restaurante específico
- getTopRatedRestaurants()          // Retorna los mejor valorados
- getRestaurantsByType(type)        // Filtra por tipo de comida
```

**Singleton Pattern**: Caché de restaurantes cargado una sola vez

### 3. **Capa de Datos (Models & Constants)**

#### Restaurant Model (`restaurant_model.dart`)
```dart
- id: String                    // Identificador único
- name: String                  // Nombre del restaurante
- type: String                  // Tipo de comida
- location: LatLng              // Coordenadas geográficas
- rating: double                // Calificación (0-5)
- imageUrl: String              // URL de la imagen
- address: String               // Dirección física
- phoneNumber: String           // Teléfono de contacto
- description: String           // Descripción detallada

- getDistanceInKm()             // Calcula distancia usando Haversine
- fromJson()                    // Constructor desde JSON
- toJson()                      // Serialización a JSON
```

#### Constants (`app_constants.dart`)
```dart
- defaultLocation: LatLng       // Ubicación por defecto (Madrid)
- searchRadiusKm: double        // Radio de búsqueda (5km)
- mockRestaurants: List         // Datos simulados con 8 restaurantes
```

## Flujo de Datos

```
┌─────────────────────────────────────────────────────┐
│             Interfaz de Usuario (UI)                │
│  ┌──────────────┐      ┌──────────────────────────┐ │
│  │ MapScreen    │      │ RestaurantDetailsScreen  │ │
│  └──────────────┘      └──────────────────────────┘ │
└────────────────────┬────────────────────────────────┘
                     │ Interacción del usuario
                     ▼
┌─────────────────────────────────────────────────────┐
│         Capa de Lógica de Negocio                   │
│  ┌──────────────────┐    ┌──────────────────────┐  │
│  │ LocationService  │    │ RestaurantService    │  │
│  └──────────────────┘    └──────────────────────┘  │
└────────────────────┬────────────────────────────────┘
                     │ Consulta de datos
                     ▼
┌─────────────────────────────────────────────────────┐
│         Capa de Datos (Models & Constants)          │
│  ┌──────────────────┐    ┌──────────────────────┐  │
│  │ Restaurant Model │    │ AppConstants         │  │
│  └──────────────────┘    └──────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Patrón de Diseño: Singleton

Tanto `LocationService` como `RestaurantService` implementan el patrón Singleton:

```dart
class LocationService {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() {
    return _instance;
  }
  
  LocationService._internal();
}
```

**Ventajas**:
- Una única instancia global
- Acceso centralizado
- Caché de datos
- Gestión eficiente de recursos

## Cálculo de Distancia

Usa la **Fórmula de Haversine** para calcular distancias geodésicas:

```dart
double getDistanceInKm(LatLng userLocation) {
  const double earthRadiusKm = 6371;
  // Implementación matemática completa
  // Retorna distancia en kilómetros
}
```

## Manejo de Permisos

**Flujo de Permisos**:
1. Verifica permisos existentes
2. Si está denegado: Solicita permiso
3. Si está denegado permanentemente: Abre configuración
4. Si se obtiene: Procede con geolocalización
5. Si falla: Usa ubicación por defecto (Madrid)

## Optimizaciones

### 1. **Eficiencia de Batería**
- GPS activado solo bajo demanda del usuario
- Caché de ubicación
- Sin actualizaciones periódicas

### 2. **Rendimiento**
- Lazy loading de datos
- Caché de servicios
- Renderizado optimizado con ListView

### 3. **UX**
- Fallbacks inteligentes (ubicación por defecto)
- Loading indicators
- Mensajes de error claros
- Interfaz responsive

## Extensibilidad

### Para agregar nuevas funcionalidades:

1. **Nuevo tipo de búsqueda**: Agregar método en `RestaurantService`
2. **Nueva pantalla**: Crear archivo en lib/, importar en main.dart
3. **Nuevo dato de restaurante**: Actualizar `Restaurant` model
4. **Nueva fuente de datos**: Reemplazar `mockRestaurants` con API

### Ejemplo: Agregar filtrado por precio
```dart
// En RestaurantService
List<Restaurant> getRestaurantsByPriceRange(double minPrice, double maxPrice) {
  return _restaurants.where((r) => 
    r.price >= minPrice && r.price <= maxPrice
  ).toList();
}

// Agregar en Restaurant model
final double price;
```

## Testing

Para agregar tests:

```dart
// test/restaurant_service_test.dart
void main() {
  test('Should calculate distance correctly', () {
    final service = RestaurantService();
    // Tests aquí
  });
}
```

## Consideraciones de Seguridad

- Los permisos se solicitan dinámicamente (Runtime Permissions)
- No se almacenan datos sensibles localmente
- API keys configurables por entorno

## Conclusión

La arquitectura de FoodFinder está diseñada para ser:
- ✅ **Modular**: Componentes independientes
- ✅ **Escalable**: Fácil agregar nuevas funcionalidades
- ✅ **Mantenible**: Código limpio y bien organizado
- ✅ **Eficiente**: Optimizado para rendimiento y batería
