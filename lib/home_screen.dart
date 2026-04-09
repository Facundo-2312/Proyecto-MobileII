import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodFinder'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Características de FoodFinder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeature('📍', 'Búsqueda por ubicación', 'Encuentra restaurantes cercanos a ti'),
                  _buildFeature('⭐', 'Calificaciones', 'Consulta las opiniones de otros usuarios'),
                  _buildFeature('🛵', 'Entrega rápida', 'Recibe tu pedido en minutos'),
                  _buildFeature('🗺️', 'Mapa interactivo', 'Visualiza restaurantes en el mapa'),
                  _buildFeature('📦', 'Tus pedidos', 'Historial completo de tus pedidos'),
                  _buildFeature('👤', 'Tu perfil', 'Personaliza tu cuenta y preferencias'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeature(String icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


