import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'foodfinder.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        latitude REAL,
        longitude REAL,
        rating REAL,
        address TEXT,
        phoneNumber TEXT,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        restaurant_id TEXT NOT NULL,
        name TEXT,
        description TEXT,
        price REAL,
        category TEXT,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        restaurant_id TEXT NOT NULL,
        restaurant_name TEXT,
        total_price REAL,
        status TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        menu_item_id TEXT,
        item_name TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Crear usuario demo
    await db.insert('users', {
      'id': 'user_1',
      'name': 'Usuario Demo',
      'email': 'demo@foodfinder.com',
      'phone': '+598 9 1234567',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    final restaurants = [
      {
        'id': '1',
        'name': 'Pizzería Morosoli',
        'type': 'Italiano',
        'latitude': -34.8950,
        'longitude': -56.1640,
        'rating': 4.7,
        'address': 'Avenida Italia 2960, Montevideo',
        'phoneNumber': '+598 2 406 67 67',
        'description': 'Auténtica pizzería italiana con hornos de leña',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Pizzeria',
      },
      {
        'id': '2',
        'name': 'Sushi Tóquio',
        'type': 'Japonés',
        'latitude': -34.9050,
        'longitude': -56.1680,
        'rating': 4.6,
        'address': 'Calle Buenos Aires 589, Centro',
        'phoneNumber': '+598 2 900 45 23',
        'description': 'Los mejores rolls de sushi fresco preparados al momento',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Sushi',
      },
      {
        'id': '3',
        'name': 'Chivitería El Corte',
        'type': 'Uruguayo',
        'latitude': -34.9020,
        'longitude': -56.1620,
        'rating': 4.8,
        'address': 'Calle 18 de Julio 1512, Centro',
        'phoneNumber': '+598 2 902 22 22',
        'description': 'Famosos chivitos uruguayos preparados con carnes premium',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Chivitos',
      },
      {
        'id': '4',
        'name': 'Parrilla Asadito',
        'type': 'Carne',
        'latitude': -34.9100,
        'longitude': -56.1660,
        'rating': 4.9,
        'address': 'Calle Peatonal Sarandí 642, Centro',
        'phoneNumber': '+598 2 915 67 89',
        'description': 'Parrilla de carnes uruguayas de la mejor calidad a las brasas',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Parrilla',
      },
      {
        'id': '5',
        'name': 'Burger House Montevideo',
        'type': 'Comida Rápida',
        'latitude': -34.8980,
        'longitude': -56.1700,
        'rating': 4.3,
        'address': 'Avenida 18 de Julio 2089, Centro',
        'phoneNumber': '+598 2 908 34 56',
        'description': 'Hamburguesas gourmet con ingredientes de la mejor selección',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Burger',
      },
      {
        'id': '6',
        'name': 'Mariscos Mar del Plata',
        'type': 'Pescados y Mariscos',
        'latitude': -34.9030,
        'longitude': -56.1590,
        'rating': 4.8,
        'address': 'Rambla República de Argentina 300, Rambla',
        'phoneNumber': '+598 2 928 12 34',
        'description': 'Pescados y mariscos frescos directo del puerto de Montevideo',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Mariscos',
      },
      {
        'id': '7',
        'name': 'Pasta Casera',
        'type': 'Italiano',
        'latitude': -34.9060,
        'longitude': -56.1730,
        'rating': 4.7,
        'address': 'Calle Mercedes 1387, Centro',
        'phoneNumber': '+598 2 916 89 01',
        'description': 'Pasta fresca hecha diariamente con recetas tradicionales italianas',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Pasta',
      },
      {
        'id': '8',
        'name': 'Wok & Roll Oriental',
        'type': 'Asiático',
        'latitude': -34.8990,
        'longitude': -56.1610,
        'rating': 4.5,
        'address': 'Calle Yi 1447, Pocitos',
        'phoneNumber': '+598 2 921 45 67',
        'description': 'Comida oriental fusión con ingredientes frescos y auténticos',
        'imageUrl': 'https://via.placeholder.com/300x200?text=Wok',
      },
    ];

    for (var restaurant in restaurants) {
      await db.insert('restaurants', restaurant);
    }

    final menuItems = [
      {'id': '1', 'restaurant_id': '1', 'name': 'Pizza Margherita', 'description': 'Tomate, mozzarella, albahaca', 'price': 450.0, 'category': 'Pizzas'},
      {'id': '2', 'restaurant_id': '1', 'name': 'Pizza Pepperoni', 'description': 'Pepperoni y queso', 'price': 480.0, 'category': 'Pizzas'},
      {'id': '3', 'restaurant_id': '1', 'name': 'Pasta Carbonara', 'description': 'Bacon, huevo, queso', 'price': 420.0, 'category': 'Pastas'},
      {'id': '4', 'restaurant_id': '2', 'name': 'Sushi Mix', 'description': 'Variado de rolls', 'price': 650.0, 'category': 'Rolls'},
      {'id': '5', 'restaurant_id': '2', 'name': 'Sashimi', 'description': '12 piezas de sashimi', 'price': 580.0, 'category': 'Sashimi'},
      {'id': '6', 'restaurant_id': '3', 'name': 'Chivito Canadiense', 'description': 'Carne, jamón, queso', 'price': 650.0, 'category': 'Chivitos'},
      {'id': '7', 'restaurant_id': '4', 'name': 'Asado Uruguayo', 'description': 'Carne a la parrilla', 'price': 750.0, 'category': 'Carnes'},
      {'id': '8', 'restaurant_id': '5', 'name': 'Hamburguesa Premium', 'description': 'Carne, queso, lechuga', 'price': 350.0, 'category': 'Hamburguesas'},
      {'id': '9', 'restaurant_id': '6', 'name': 'Camarones al Ajillo', 'description': 'Camarones con ajo', 'price': 800.0, 'category': 'Mariscos'},
      {'id': '10', 'restaurant_id': '7', 'name': 'Fettuccine Alfredo', 'description': 'Pasta con salsa cremosa', 'price': 520.0, 'category': 'Pastas'},
      {'id': '11', 'restaurant_id': '8', 'name': 'Arroz 3 Delicias', 'description': 'Arroz con verduras', 'price': 400.0, 'category': 'Arroces'},
    ];

    for (var item in menuItems) {
      await db.insert('menu_items', item);
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String restaurantId) async {
    final db = await database;
    return db.query(
      'menu_items',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
    );
  }

  Future<String> createOrder(String userId, String restaurantId, String restaurantName, List<Map<String, dynamic>> items) async {
    final db = await database;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    double totalPrice = 0;
    for (var item in items) {
      totalPrice += (item['price'] as num) * (item['quantity'] as num);
    }

    await db.insert('orders', {
      'id': orderId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'total_price': totalPrice,
      'status': 'Pendiente',
      'created_at': DateTime.now().toIso8601String(),
    });

    for (int i = 0; i < items.length; i++) {
      await db.insert('order_items', {
        'id': '${orderId}_$i',
        'order_id': orderId,
        'menu_item_id': items[i]['id'],
        'item_name': items[i]['name'],
        'quantity': items[i]['quantity'],
        'price': items[i]['price'],
      });
    }

    return orderId;
  }

  // ===== USUARIO =====
  Future<String> createUser(String name, String email, String phone) async {
    final db = await database;
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('users', {
      'id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
    });
    return userId;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query('users');
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  // ===== PEDIDOS (por usuario) =====
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final db = await database;
    return db.query('orders', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return db.query('orders', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final db = await database;
    return db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> deleteOrder(String orderId) async {
    final db = await database;
    await db.delete('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }
}
