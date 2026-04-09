import 'package:flutter/material.dart';
import 'database_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _restaurants = [];
  String? _selectedRestaurant;
  List<Map<String, dynamic>> _menuItems = [];
  Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final db = await _db.database;
    final restaurants = await db.query('restaurants');
    setState(() {
      _restaurants = restaurants;
      if (_restaurants.isNotEmpty) {
        _selectedRestaurant = _restaurants.first['id'] as String?;
        _loadMenuItems(_selectedRestaurant!);
      }
    });
  }

  Future<void> _loadMenuItems(String restaurantId) async {
    final items = await _db.getMenuItems(restaurantId);
    setState(() {
      _menuItems = items;
      _cart.clear();
    });
  }

  Future<void> _makeOrder() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrito vacío')),
      );
      return;
    }

    final restaurantName = _restaurants
        .firstWhere((r) => r['id'] == _selectedRestaurant)['name'];

    final items = _menuItems
        .where((item) => _cart.containsKey(item['id']))
        .map((item) => {
              'id': item['id'],
              'name': item['name'],
              'price': item['price'],
              'quantity': _cart[item['id']]!,
            })
        .toList();

    try {
      await _db.createOrder('user_1', _selectedRestaurant!, restaurantName, items);
      setState(() => _cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pedido guardado en la BD')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedRestaurant,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRestaurant = value);
                  _loadMenuItems(value);
                }
              },
              items: _restaurants
                  .map((r) => DropdownMenuItem<String>(
                        value: r['id'] as String,
                        child: Text(r['name'] as String),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final quantity = _cart[item['id']] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                item['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${item['price']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (quantity > 0)
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.orange,
                                ),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (quantity > 0) {
                                        _cart[item['id']] = quantity - 1;
                                        if (_cart[item['id']] == 0) {
                                          _cart.remove(item['id']);
                                        }
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _cart[item['id']] = (quantity) + 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _makeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Hacer Pedido (${_cart.length} items)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

