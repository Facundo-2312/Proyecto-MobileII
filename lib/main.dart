import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'database_service.dart';
import 'users_management_screen.dart';
import 'feature_screens.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializa BD en mobile, no en web
  if (!kIsWeb) {
    await DatabaseService().database;
  }

  runApp(const FoodFinderApp());
}

class FoodFinderApp extends StatelessWidget {
  const FoodFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const FoodFinderHome(),
      routes: {
        '/products': (context) => const ProductsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/map': (context) => const MapScreen(),
        '/location-search': (context) => const LocationSearchScreen(),
        '/ratings': (context) => const RatingsScreen(),
        '/fast-delivery': (context) => const FastDeliveryScreen(),
        '/users': (context) => const UsersManagementScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => MissingRestaurantScreen(routeName: settings.name),
      ),
    );
  }
}

class FoodFinderHome extends StatefulWidget {
  const FoodFinderHome({super.key});

  @override
  State<FoodFinderHome> createState() => _FoodFinderHomeState();
}

class _FoodFinderHomeState extends State<FoodFinderHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const MapScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Productos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class MissingRestaurantScreen extends StatelessWidget {
  final String? routeName;

  const MissingRestaurantScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle no disponible'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 56,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar este restaurante.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                routeName == '/details'
                    ? 'La ruta de detalle ya no se abre directamente en web. Vuelve al inicio y abre el restaurante nuevamente desde la lista.'
                    : 'La ruta solicitada no está disponible. Vuelve al inicio y navega nuevamente desde la aplicación.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const FoodFinderHome(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
