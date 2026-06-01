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
  bool _processingAction = false;
  String? _activeUserId;
  String? _selectedRestaurant;
  String _selectedStatus = 'Pendiente';
  final TextEditingController _totalPriceController = TextEditingController();
  final List<String> _statusOptions = ['Pendiente', 'Preparando', 'Entregado'];

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double? _parsePrice(String rawValue) {
    return double.tryParse(rawValue.trim().replaceAll(',', '.'));
  }

  String _formatOrderDate(dynamic createdAt) {
    if (createdAt == null) return '-';
    final parsed = DateTime.tryParse(createdAt.toString());
    if (parsed == null) return createdAt.toString();

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  int get _pendingOrdersCount {
    return _orders.where((order) {
      final status = (order['status'] as String? ?? '').toLowerCase();
      return status == 'pendiente' || status == 'preparando';
    }).length;
  }

  int get _deliveredOrdersCount {
    return _orders.where((order) {
      final status = (order['status'] as String? ?? '').toLowerCase();
      return status == 'entregado';
    }).length;
  }

  double get _totalOrdersAmount {
    return _orders.fold<double>(0, (acc, order) {
      final total = (order['total_price'] as num?)?.toDouble() ?? 0;
      return acc + total;
    });
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de pedidos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.shopping_bag, size: 18),
                  label: Text('Total: ${_orders.length}'),
                ),
                Chip(
                  avatar: const Icon(Icons.local_shipping, size: 18),
                  label: Text('Activos: $_pendingOrdersCount'),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 18),
                  label: Text('Entregados: $_deliveredOrdersCount'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Monto acumulado: \$${_totalOrdersAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final userId = await _db.getOrCreateSessionUserId();
    if (!mounted) return;
    setState(() {
      _activeUserId = userId;
    });
    await _loadOrders();
    await _loadRestaurants();
  }

  Future<void> _loadOrders() async {
    final userId = _activeUserId ?? await _db.getOrCreateSessionUserId();
    final orders = await _db.getUserOrders(userId);
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
    if (_processingAction) return;

    setState(() {
      _processingAction = true;
    });

    try {
      await _db.updateOrderStatus(orderId, status);
      await _loadOrders();
      _showInfo('Estado actualizado a "$status"');
    } catch (e) {
      _showInfo('No se pudo actualizar el estado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingAction = false;
        });
      }
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    await _db.deleteOrder(orderId);
    await _loadOrders();
  }

  Future<void> _confirmDeleteOrder(Map<String, dynamic> order) async {
    if (_processingAction) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Seguro que deseas eliminar el pedido de ${order['restaurant_name'] ?? 'este restaurante'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _processingAction = true;
      });
      try {
        await _deleteOrder(order['id'] as String);
        _showInfo('Pedido eliminado');
      } catch (e) {
        _showInfo('No se pudo eliminar el pedido: $e');
      } finally {
        if (mounted) {
          setState(() {
            _processingAction = false;
          });
        }
      }
    }
  }

  Future<void> _showEditOrderDialog(Map<String, dynamic> order) async {
    if (_restaurants.isEmpty) {
      await _loadRestaurants();
    }
    if (!mounted) return;

    String selectedRestaurant =
        order['restaurant_id'] as String? ?? _selectedRestaurant ?? '';
    String selectedStatus = order['status'] as String? ?? 'Pendiente';
    final totalController = TextEditingController(
      text: (order['total_price'] as num?)?.toString() ?? '0',
    );
    final notesController = TextEditingController(
      text: order['notes'] as String? ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar pedido'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRestaurant.isEmpty
                          ? null
                          : selectedRestaurant,
                      decoration: const InputDecoration(labelText: 'Restaurante'),
                      items: _restaurants
                          .map((restaurant) => DropdownMenuItem<String>(
                                value: restaurant['id'] as String,
                                child: Text(restaurant['name'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRestaurant = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: totalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _statusOptions
                          .map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios / observaciones',
                        border: OutlineInputBorder(),
                      ),
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
                    final parsedTotal = _parsePrice(totalController.text);
                    if (selectedRestaurant.isEmpty) {
                      _showInfo('Selecciona un restaurante.');
                      return;
                    }
                    if (parsedTotal == null || parsedTotal <= 0) {
                      _showInfo('Ingresa un total mayor a 0.');
                      return;
                    }

                    final restaurant = _restaurants.firstWhere(
                      (restaurant) => restaurant['id'] == selectedRestaurant,
                      orElse: () => order,
                    );
                    final restaurantName = restaurant['name'] as String? ??
                        (order['restaurant_name'] as String? ?? 'Restaurante');
                    final totalPrice = parsedTotal;

                    Navigator.of(dialogContext).pop();
                    setState(() {
                      _processingAction = true;
                    });
                    try {
                      await _db.updateOrder(
                        order['id'] as String,
                        restaurantId: selectedRestaurant,
                        restaurantName: restaurantName,
                        totalPrice: totalPrice,
                        status: selectedStatus,
                        notes: notesController.text.trim(),
                      );
                      if (!mounted) return;
                      await _loadOrders();
                      _showInfo('Pedido actualizado');
                    } catch (e) {
                      _showInfo('No se pudo actualizar: $e');
                    } finally {
                      if (mounted) {
                        setState(() {
                          _processingAction = false;
                        });
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    totalController.dispose();
    notesController.dispose();
  }

  Future<void> _showCreateOrderDialog() async {
    if (_restaurants.isEmpty) {
      await _loadRestaurants();
    }
    if (!mounted) return;

    _selectedRestaurant ??= _restaurants.isNotEmpty ? _restaurants.first['id'] as String? : null;
    _selectedStatus = 'Pendiente';
    _totalPriceController.text = '0';
    final notesController = TextEditingController();

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
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comentarios / observaciones',
                    border: OutlineInputBorder(),
                  ),
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
                final selectedRestaurant = _selectedRestaurant;
                final price = _parsePrice(_totalPriceController.text);
                if (selectedRestaurant == null || selectedRestaurant.isEmpty) {
                  _showInfo('Selecciona un restaurante para crear el pedido.');
                  return;
                }
                if (price == null || price <= 0) {
                  _showInfo('Ingresa un total mayor a 0.');
                  return;
                }

                final restaurant = _restaurants.firstWhere(
                  (restaurant) => restaurant['id'] == selectedRestaurant,
                  orElse: () => {},
                );
                final restaurantName = restaurant['name'] as String? ?? 'Restaurante';

                Navigator.of(context).pop();
                setState(() {
                  _processingAction = true;
                });
                try {
                  await _db.createOrderSimple(
                    _activeUserId ?? await _db.getOrCreateSessionUserId(),
                    selectedRestaurant,
                    restaurantName,
                    price,
                    _selectedStatus,
                    notes: notesController.text.trim(),
                  );
                  if (!mounted) return;
                  await _loadOrders();
                  _showInfo('Pedido creado correctamente');
                } catch (e) {
                  _showInfo('No se pudo crear el pedido: $e');
                } finally {
                  if (mounted) {
                    setState(() {
                      _processingAction = false;
                    });
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    notesController.dispose();
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
        onPressed: _processingAction ? null : _showCreateOrderDialog,
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
              onRefresh: _processingAction ? () async {} : _loadOrders,
              child: ListView(
                children: [
                  _buildSummaryCard(),
                  ..._orders.map((order) {
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
                            if ((order['notes'] as String?)?.trim().isNotEmpty ?? false)
                              Text(
                                'Obs: ${order['notes']}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(_formatOrderDate(order['created_at'])),
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
                            IconButton(
                              tooltip: 'Editar pedido',
                              onPressed: _processingAction ? null : () => _showEditOrderDialog(order),
                              icon: const Icon(Icons.edit, color: Colors.orange),
                            ),
                            IconButton(
                              tooltip: 'Eliminar pedido',
                              onPressed: _processingAction ? null : () => _confirmDeleteOrder(order),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              enabled: !_processingAction,
                              onSelected: (value) async {
                                await _changeOrderStatus(order['id'] as String, value);
                              },
                              itemBuilder: (context) {
                                return [
                                  ..._statusOptions.map((status) {
                                    return PopupMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }
}

