import 'package:google_maps_flutter/google_maps_flutter.dart'
    if (dart.library.html) 'package:foodfinder/google_maps_flutter_stub.dart';

/// Ubicación por defecto (Centro de Montevideo, Uruguay)
const LatLng defaultLocation = LatLng(-34.9011, -56.1645); // Montevideo

/// Radio de búsqueda en kilómetros
const double searchRadiusKm = 50.0;

/// Datos simulados de restaurantes mock en Montevideo
const List<Map<String, dynamic>> mockRestaurants = [
  {
    'id': '1',
    'name': 'Pizzería Morosoli',
    'type': 'Italiano',
    'latitude': -34.8950,
    'longitude': -56.1640,
    'rating': 4.7,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Pizzeria+Morosoli',
    'address': 'Avenida Italia 2960, Montevideo',
    'phoneNumber': '+598 2 406 67 67',
    'description':
        'Auténtica pizzería italiana con hornos de leña tradicionales',
  },
  {
    'id': '2',
    'name': 'Sushi Tóquio',
    'type': 'Japonés',
    'latitude': -34.9050,
    'longitude': -56.1680,
    'rating': 4.6,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Sushi+Tokio',
    'address': 'Calle Buenos Aires 589, Centro',
    'phoneNumber': '+598 2 900 45 23',
    'description': 'Los mejores rolls de sushi fresco preparados al momento',
  },
  {
    'id': '3',
    'name': 'Chivitería El Corte',
    'type': 'Uruguayo',
    'latitude': -34.9020,
    'longitude': -56.1620,
    'rating': 4.8,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Chiviteria+El+Corte',
    'address': 'Calle 18 de Julio 1512, Centro',
    'phoneNumber': '+598 2 902 22 22',
    'description': 'Famosos chivitos uruguayos preparados con carnes premium',
  },
  {
    'id': '4',
    'name': 'Parrilla Asadito',
    'type': 'Carne',
    'latitude': -34.9100,
    'longitude': -56.1660,
    'rating': 4.9,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Parrilla+Asadito',
    'address': 'Calle Peatonal Sarandí 642, Centro',
    'phoneNumber': '+598 2 915 67 89',
    'description':
        'Parrilla de carnes uruguayas de la mejor calidad a las brasas',
  },
  {
    'id': '5',
    'name': 'Burger House Montevideo',
    'type': 'Comida Rápida',
    'latitude': -34.8980,
    'longitude': -56.1700,
    'rating': 4.3,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Burger+House',
    'address': 'Avenida 18 de Julio 2089, Centro',
    'phoneNumber': '+598 2 908 34 56',
    'description':
        'Hamburguesas gourmet con ingredientes de la mejor selección',
  },
  {
    'id': '6',
    'name': 'Mariscos Mar del Plata',
    'type': 'Pescados y Mariscos',
    'latitude': -34.9030,
    'longitude': -56.1590,
    'rating': 4.8,
    'imageUrl':
        'https://via.placeholder.com/300x200?text=Mariscos+Mar+del+Plata',
    'address': 'Rambla República de Argentina 300, Rambla',
    'phoneNumber': '+598 2 928 12 34',
    'description':
        'Pescados y mariscos frescos directo del puerto de Montevideo',
  },
  {
    'id': '7',
    'name': 'Pasta Casera',
    'type': 'Italiano',
    'latitude': -34.9060,
    'longitude': -56.1730,
    'rating': 4.7,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Pasta+Casera',
    'address': 'Calle Mercedes 1387, Centro',
    'phoneNumber': '+598 2 916 89 01',
    'description':
        'Pasta fresca hecha diariamente con recetas tradicionales italianas',
  },
  {
    'id': '8',
    'name': 'Wok & Roll Oriental',
    'type': 'Asiático',
    'latitude': -34.8990,
    'longitude': -56.1610,
    'rating': 4.5,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Wok+Roll+Oriental',
    'address': 'Calle Yi 1447, Pocitos',
    'phoneNumber': '+598 2 921 45 67',
    'description':
        'Comida oriental fusión con ingredientes frescos y auténticos',
  },
  {
    'id': '9',
    'name': 'Benedetto Steakhouse',
    'type': 'Restaurante',
    'latitude': -30.9038,
    'longitude': -55.5381,
    'rating': 4.2,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Benedetto+Steakhouse',
    'address': 'Don Pedro de Ceballos 1070, Rivera',
    'phoneNumber': '+598 2 123 45 67',
    'description':
        'Cerrado · Abre a las 11 a. m. Muy buena parrilla a una cuadra de la calle principal de Rivera.',
  },
  {
    'id': '10',
    'name': 'Morano Restaurant',
    'type': 'Restaurante',
    'latitude': -30.9046,
    'longitude': -55.5348,
    'rating': 4.4,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Morano+Restaurant',
    'address': 'Av. Sarandí 825, Rivera',
    'phoneNumber': '+598 2 234 56 78',
    'description':
        'Cerrado · Abre a las 8:30 a. m. Servicio cuidado en un ambiente clásico.',
  },
  {
    'id': '11',
    'name': 'Lo de Beto',
    'type': 'Parrilla',
    'latitude': -30.9040,
    'longitude': -55.5370,
    'rating': 4.5,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Lo+de+Beto',
    'address': 'Don Pedro de Ceballos 1175, Rivera',
    'phoneNumber': '+598 2 345 67 89',
    'description':
        'Cerrado · Abre a las 7 p. m. Parrilla reconocida por sus cortes y ambiente relajado.',
  },
  {
    'id': '12',
    'name': 'Gardel Restaurante e Parrillada',
    'type': 'Restaurante',
    'latitude': -30.9062,
    'longitude': -55.5395,
    'rating': 4.0,
    'imageUrl': 'https://via.placeholder.com/300x200?text=Gardel+Restaurante',
    'address': 'Paysandú 1170, Rivera',
    'phoneNumber': '+598 2 456 78 90',
    'description':
        'Cerrado · Abre a las 7 p. m. Parrillada de estilo local con música y buenos cortes.',
  },
  {
    'id': '13',
    'name': 'La Perdiz',
    'type': 'Uruguaya',
    'latitude': -30.9050,
    'longitude': -55.5331,
    'rating': 4.5,
    'imageUrl': 'https://via.placeholder.com/300x200?text=La+Perdiz',
    'address': 'Av. Sepé 51, Rivera',
    'phoneNumber': '+598 2 567 89 01',
    'description':
        'Cerrado · Abre a las 12 p. m. Cocina uruguaya tradicional con platos caseros.',
  },
];
