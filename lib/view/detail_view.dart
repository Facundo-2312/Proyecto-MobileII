import 'package:flutter/material.dart';
import '../model/restaurant.dart';

class DetailView extends StatelessWidget {
  final Restaurant restaurant;

  const DetailView({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.restaurant, size: 100, color: Colors.orange),
            const SizedBox(height: 20),

            Text(
              restaurant.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text("Tipo: ${restaurant.type}"),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              icon: const Icon(Icons.map),
              label: const Text("Ver en mapa"),
            )
          ],
        ),
      ),
    );
  }
}