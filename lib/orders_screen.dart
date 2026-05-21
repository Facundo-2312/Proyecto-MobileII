import 'package:flutter/material.dart';
import 'database_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _restaurants = [];
  bool _loading = true;
  String? _selectedRestaurant;
  String _selectedStatus = 'Pendiente';
  final TextEditingController _totalPriceController = TextEditingController();
  final List<String> _statusOptions = ['Pendiente', 'Preparando', 'Entregado'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadRestaurants();
  }

  Future<void> _loadOrders() async {
    final orders = await _db.getUserOrders('user_1');
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> _loadRestaurants() async {
    final restaurants = await _db.getRestaurants();
    setState(() {
      _restaurants = restaurants;
      if (_selectedRestaurant == null && _restaurants.isNotEmpty) {
        _selectedRestaurant = _restaurants.first['id'] as String?;
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregado':
        return Colors.green;
      case 'Preparando':
        return Colors.orange;
      case 'En camino':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _changeOrderStatus(String orderId, String status) async {
    await _db.updateOrderStatus(orderId, status);
    await _loadOrders();
  }

  Future<void> _deleteOrder(String orderId) async {
    await _db.deleteOrder(orderId);
    await _loadOrders();
  }

  Future<void> _showCreateOrderDialog() async {
    if (_restaurants.isEmpty) {
      await _loadRestaurants();
    }
    if (!mounted) return;

    _selectedRestaurant ??= _restaurants.isNotEmpty ? _restaurants.first['id'] as String? : null;
    _selectedStatus = 'Pendiente';
    _totalPriceController.text = '0';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear pedido manual'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedRestaurant,
                  decoration: const InputDecoration(labelText: 'Restaurante'),
                  items: _restaurants
                      .map((restaurant) => DropdownMenuItem<String>(
                            value: restaurant['id'] as String,
                            child: Text(restaurant['name'] as String),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRestaurant = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _totalPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: _statusOptions
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                final restaurant = _restaurants.firstWhere(
                  (restaurant) => restaurant['id'] == _selectedRestaurant,
                  orElse: () => {},
                );
                final restaurantName = restaurant['name'] as String? ?? 'Restaurante';
                final price = double.tryParse(_totalPriceController.text.replaceAll(',', '.')) ?? 0.0;

                Navigator.of(context).pop();
                await _db.createOrderSimple(
                  'user_1',
                  _selectedRestaurant ?? '1',
                  restaurantName,
                  price,
                  _selectedStatus,
                );
                if (!mounted) return;
                await _loadOrders();
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _showCreateOrderDialog,
        child: const Icon(Icons.add),
      ),
      body: _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes pedidos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Hacer un pedido', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showCreateOrderDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Crear pedido manual', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final orderStatus = order['status'] as String? ?? 'Pendiente';
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      title: Text(
                        order['restaurant_name'] ?? 'Restaurante',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('ID: ${order['id']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Text('Total: \$${order['total_price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateTime.parse(order['created_at'] as String).toString().split('.')[0]),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              orderStatus,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _getStatusColor(orderStatus),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await _deleteOrder(order['id'] as String);
                              } else {
                                await _changeOrderStatus(order['id'] as String, value);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                ..._statusOptions.map((status) {
                                  return PopupMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }),
                                const PopupMenuDivider(),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

