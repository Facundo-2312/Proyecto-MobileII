import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'database_service.dart';
import 'users_management_screen.dart';
import 'register_user_screen.dart';
import 'feature_screens.dart';
import 'legal_screens.dart';
import 'premium_upgrade_screen.dart';
import 'view/wearable/wearable_view.dart';

import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const AppBootstrapScreen(),
      routes: {
        '/products': (context) => const ProductsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/map': (context) => const MapScreen(),
        '/wearable': (context) => const WearableView(),
        '/location-search': (context) => const LocationSearchScreen(),
        '/ratings': (context) => const RatingsScreen(),
        '/fast-delivery': (context) => const FastDeliveryScreen(),
        '/users': (context) => const UsersManagementScreen(),
        '/register': (context) => const RegisterUserScreen(),
        '/signup': (context) => const RegisterUserScreen(),
        '/terms': (context) => const TermsOfUseScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
        '/premium': (context) => const PremiumUpgradeScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => MissingRestaurantScreen(routeName: settings.name),
      ),
    );
  }
}

class AppBootstrapScreen extends StatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  State<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<AppBootstrapScreen> {
  late final Future<void> _startupFuture = _initializeApp();

  Future<void> _initializeApp() async {
    if (!kIsWeb) {
      await DatabaseService().database;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StartupErrorScreen(error: snapshot.error);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const StartupLoadingScreen();
        }

        return const FoodFinderHome();
      },
    );
  }
}

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(46),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Image.asset('assets/branding/app_icon.png'),
                ),
                const SizedBox(height: 28),
                Text(
                  'FoodFinder',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cargando restaurantes, perfil y mapa...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(99),
                    color: colorScheme.primary,
                    backgroundColor: Colors.orange.shade100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final Object? error;

  const StartupErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudo iniciar la aplicación.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa la configuración local e inténtalo nuevamente.${error == null ? '' : '\n\n$error'}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

  static const List<Widget> _screens = [
    HomeScreen(),
    ProductsScreen(),
    MapScreen(),
    OrdersScreen(),
    ProfileScreen(),
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
              Icon(Icons.info_outline, size: 56, color: Colors.orange.shade700),
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
                    : routeName == '/wearable'
                    ? 'La vista smartwatch es una simulación de interfaz dentro de la app principal.'
                    : 'La ruta solicitada no está disponible. Vuelve al inicio y navega nuevamente desde la aplicación.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const FoodFinderHome()),
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
