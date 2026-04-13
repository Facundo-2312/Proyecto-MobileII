import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodFinder'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orange.shade700],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Bienvenido a FoodFinder!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre los mejores restaurantes de Montevideo',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Características de FoodFinder',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 8,
                      radius: const Radius.circular(8),
                      child: GridView.count(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3.2,
                        children: [
                          _buildFeatureCard(
                            '📍',
                            'Búsqueda por ubicación',
                            'Encuentra restaurantes cercanos a ti',
                            () => Navigator.pushNamed(context, '/map'),
                          ),
                          _buildFeatureCard(
                            '⭐',
                            'Calificaciones',
                            'Consulta las opiniones de otros usuarios',
                            () => Navigator.pushNamed(context, '/profile'),
                          ),
                          _buildFeatureCard(
                            '🛵',
                            'Entrega rápida',
                            'Recibe tu pedido en minutos',
                            () => Navigator.pushNamed(context, '/orders'),
                          ),
                          _buildFeatureCard(
                            '🗺️',
                            'Mapa interactivo',
                            'Visualiza restaurantes en el mapa',
                            () => Navigator.pushNamed(context, '/map'),
                          ),
                          _buildFeatureCard(
                            '📦',
                            'Tus pedidos',
                            'Historial completo de tus pedidos',
                            () => Navigator.pushNamed(context, '/orders'),
                          ),
                          _buildFeatureCard(
                            '👤',
                            'Tu perfil',
                            'Personaliza tu cuenta y preferencias',
                            () => Navigator.pushNamed(context, '/profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureCard(
    String icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
