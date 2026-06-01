import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_platform.dart';
import 'app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static const List<String> availableRoles = ['admin', 'manager', 'user'];

  static final List<Map<String, dynamic>> _webRestaurants = List.unmodifiable(
    mockRestaurants,
  );
  static const String _seedAdminPassword = String.fromEnvironment(
    'FOODFINDER_ADMIN_PASSWORD',
    defaultValue: '',
  );

  static final List<Map<String, dynamic>> _webMenuItems = [
    {
      'id': '1',
      'restaurant_id': '1',
      'name': 'Pizza Margherita',
      'description': 'Tomate, mozzarella, albahaca',
      'price': 450.0,
      'category': 'Pizzas',
    },
    {
      'id': '2',
      'restaurant_id': '1',
      'name': 'Pizza Pepperoni',
      'description': 'Pepperoni y queso',
      'price': 480.0,
      'category': 'Pizzas',
    },
    {
      'id': '3',
      'restaurant_id': '1',
      'name': 'Pasta Carbonara',
      'description': 'Bacon, huevo, queso',
      'price': 420.0,
      'category': 'Pastas',
    },
    {
      'id': '4',
      'restaurant_id': '2',
      'name': 'Sushi Mix',
      'description': 'Variado de rolls',
      'price': 650.0,
      'category': 'Rolls',
    },
    {
      'id': '5',
      'restaurant_id': '2',
      'name': 'Sashimi',
      'description': '12 piezas de sashimi',
      'price': 580.0,
      'category': 'Sashimi',
    },
    {
      'id': '6',
      'restaurant_id': '3',
      'name': 'Chivito Canadiense',
      'description': 'Carne, jamón, queso',
      'price': 650.0,
      'category': 'Chivitos',
    },
    {
      'id': '7',
      'restaurant_id': '4',
      'name': 'Asado Uruguayo',
      'description': 'Carne a la parrilla',
      'price': 750.0,
      'category': 'Carnes',
    },
    {
      'id': '8',
      'restaurant_id': '5',
      'name': 'Hamburguesa Premium',
      'description': 'Carne, queso, lechuga',
      'price': 350.0,
      'category': 'Hamburguesas',
    },
    {
      'id': '9',
      'restaurant_id': '6',
      'name': 'Camarones al Ajillo',
      'description': 'Camarones con ajo',
      'price': 800.0,
      'category': 'Mariscos',
    },
    {
      'id': '10',
      'restaurant_id': '7',
      'name': 'Fettuccine Alfredo',
      'description': 'Pasta con salsa cremosa',
      'price': 520.0,
      'category': 'Pastas',
    },
    {
      'id': '11',
      'restaurant_id': '8',
      'name': 'Arroz 3 Delicias',
      'description': 'Arroz con verduras',
      'price': 400.0,
      'category': 'Arroces',
    },
  ];

  final List<Map<String, dynamic>> _webUsers = [];
  final List<Map<String, dynamic>> _webOrders = [];
  final List<Map<String, dynamic>> _webOrderItems = [];
  final Map<String, String> _webAppState = {};
  bool _webDataInitialized = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite no está disponible en Web. Usa los métodos del servicio directamente.',
      );
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await initializeDatabaseFactory();

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'foodfinder.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _ensureWebDataInitialized() async {
    if (!kIsWeb || _webDataInitialized) return;
    _webDataInitialized = true;

    _webUsers.add({
      'id': 'user_1',
      'name': 'Usuario Demo',
      'email': 'demo@foodfinder.com',
      'phone': '+598 9 1234567',
      'created_at': DateTime.now().toIso8601String(),
      'password': '',
      'role': 'user',
    });

    _webUsers.add({
      'id': 'admin_1',
      'name': 'Administrador',
      'email': 'admin@foodfinder.com',
      'phone': '+598 9 0000000',
      'created_at': DateTime.now().toIso8601String(),
      'password': _seedAdminPassword,
      'role': 'admin',
    });
  }

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return List<Map<String, dynamic>>.from(_webRestaurants);
    }
    final db = await database;
    return db.query('restaurants');
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        created_at TEXT,
        password TEXT DEFAULT '',
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    await db.execute('''
      CREATE TABLE app_state (
        key TEXT PRIMARY KEY,
        value TEXT
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
        notes TEXT DEFAULT '',
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

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN password TEXT DEFAULT ''");
      await db.execute("ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_state (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      await _ensureAdminUser(db);
    }

    if (oldVersion < 3) {
      await db.execute("ALTER TABLE orders ADD COLUMN notes TEXT DEFAULT ''");
    }
  }

  Future<void> _insertInitialData(Database db) async {
    // Crear usuario demo
    await db.insert('users', {
      'id': 'user_1',
      'name': 'Usuario Demo',
      'email': 'demo@foodfinder.com',
      'phone': '+598 9 1234567',
      'created_at': DateTime.now().toIso8601String(),
      'password': '',
      'role': 'user',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _ensureAdminUser(db);

    final restaurants = List<Map<String, dynamic>>.from(mockRestaurants);

    for (var restaurant in restaurants) {
      await db.insert('restaurants', restaurant);
    }

    final menuItems = [
      {
        'id': '1',
        'restaurant_id': '1',
        'name': 'Pizza Margherita',
        'description': 'Tomate, mozzarella, albahaca',
        'price': 450.0,
        'category': 'Pizzas',
      },
      {
        'id': '2',
        'restaurant_id': '1',
        'name': 'Pizza Pepperoni',
        'description': 'Pepperoni y queso',
        'price': 480.0,
        'category': 'Pizzas',
      },
      {
        'id': '3',
        'restaurant_id': '1',
        'name': 'Pasta Carbonara',
        'description': 'Bacon, huevo, queso',
        'price': 420.0,
        'category': 'Pastas',
      },
      {
        'id': '4',
        'restaurant_id': '2',
        'name': 'Sushi Mix',
        'description': 'Variado de rolls',
        'price': 650.0,
        'category': 'Rolls',
      },
      {
        'id': '5',
        'restaurant_id': '2',
        'name': 'Sashimi',
        'description': '12 piezas de sashimi',
        'price': 580.0,
        'category': 'Sashimi',
      },
      {
        'id': '6',
        'restaurant_id': '3',
        'name': 'Chivito Canadiense',
        'description': 'Carne, jamón, queso',
        'price': 650.0,
        'category': 'Chivitos',
      },
      {
        'id': '7',
        'restaurant_id': '4',
        'name': 'Asado Uruguayo',
        'description': 'Carne a la parrilla',
        'price': 750.0,
        'category': 'Carnes',
      },
      {
        'id': '8',
        'restaurant_id': '5',
        'name': 'Hamburguesa Premium',
        'description': 'Carne, queso, lechuga',
        'price': 350.0,
        'category': 'Hamburguesas',
      },
      {
        'id': '9',
        'restaurant_id': '6',
        'name': 'Camarones al Ajillo',
        'description': 'Camarones con ajo',
        'price': 800.0,
        'category': 'Mariscos',
      },
      {
        'id': '10',
        'restaurant_id': '7',
        'name': 'Fettuccine Alfredo',
        'description': 'Pasta con salsa cremosa',
        'price': 520.0,
        'category': 'Pastas',
      },
      {
        'id': '11',
        'restaurant_id': '8',
        'name': 'Arroz 3 Delicias',
        'description': 'Arroz con verduras',
        'price': 400.0,
        'category': 'Arroces',
      },
    ];

    for (var item in menuItems) {
      await db.insert('menu_items', item);
    }
  }

  Future<void> _ensureAdminUser(Database db) async {
    await db.insert(
      'users',
      {
        'id': 'admin_1',
        'name': 'Administrador',
        'email': 'admin@foodfinder.com',
        'phone': '+598 9 0000000',
        'created_at': DateTime.now().toIso8601String(),
        'password': _seedAdminPassword,
        'role': 'admin',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String restaurantId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return _webMenuItems
          .where((item) => item['restaurant_id'] == restaurantId)
          .toList();
    }
    final db = await database;
    return db.query(
      'menu_items',
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
    );
  }

  Future<String> createOrder(
    String userId,
    String restaurantId,
    String restaurantName,
    List<Map<String, dynamic>> items,
  ) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    double totalPrice = 0;
    for (var item in items) {
      totalPrice += (item['price'] as num) * (item['quantity'] as num);
    }

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      _webOrders.add({
        'id': orderId,
        'user_id': userId,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'total_price': totalPrice,
        'status': 'Pendiente',
        'notes': '',
        'created_at': DateTime.now().toIso8601String(),
      });

      for (int i = 0; i < items.length; i++) {
        _webOrderItems.add({
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

    final db = await database;
    await db.insert('orders', {
      'id': orderId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'total_price': totalPrice,
      'status': 'Pendiente',
      'notes': '',
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

  Future<String> createOrderSimple(
    String userId,
    String restaurantId,
    String restaurantName,
    double totalPrice,
    String status,
    {String notes = ''}
  ) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      _webOrders.add({
        'id': orderId,
        'user_id': userId,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'total_price': totalPrice,
        'status': status,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
      return orderId;
    }

    final db = await database;
    await db.insert('orders', {
      'id': orderId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'total_price': totalPrice,
      'status': status,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
    return orderId;
  }

  // ===== USUARIO =====
  Future<String> createUser(String name, String email, String phone) async {
    return createUserWithCredentials(name, email, phone);
  }

  Future<String> createUserWithCredentials(
    String name,
    String email,
    String phone, {
    String password = '',
    String role = 'user',
  }) async {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      _webUsers.add({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'password': password,
        'role': role,
      });
      return userId;
    }

    final db = await database;
    await db.insert('users', {
      'id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': DateTime.now().toIso8601String(),
      'password': password,
      'role': role,
    });
    return userId;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return List<Map<String, dynamic>>.from(_webUsers);
    }
    final db = await database;
    return db.query('users');
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final user = _webUsers.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      return user.isNotEmpty ? Map<String, dynamic>.from(user) : null;
    }
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final user = _webUsers.firstWhere(
        (user) => (user['email'] as String?)?.toLowerCase() == email.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );
      return user.isNotEmpty ? Map<String, dynamic>.from(user) : null;
    }

    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    final user = await getUserByEmail(email);
    if (user == null) {
      return null;
    }

    final storedPassword = (user['password'] as String?) ?? '';
    if (storedPassword != password) {
      return null;
    }

    await setCurrentUserId(user['id'] as String?);
    return user;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return getUser(userId);
  }

  Future<int> countUsersByRole(String role) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return _webUsers.where((user) => user['role'] == role).length;
    }

    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM users WHERE role = ?',
      [role],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<void> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    String? password,
    String? role,
  }) async {
    final existingUser = await getUser(userId);
    if (existingUser == null) {
      throw StateError('Usuario no encontrado.');
    }

    final updateData = <String, dynamic>{};
    if (name != null) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) updateData['name'] = trimmed;
    }
    if (email != null) {
      final trimmed = email.trim().toLowerCase();
      if (trimmed.isNotEmpty) updateData['email'] = trimmed;
    }
    if (phone != null) updateData['phone'] = phone.trim();
    if (password != null && password.isNotEmpty) updateData['password'] = password;

    if (role != null) {
      if (!availableRoles.contains(role)) {
        throw ArgumentError('Rol no válido.');
      }

      final currentRole = (existingUser['role'] as String?) ?? 'user';
      if (currentRole == 'admin' && role != 'admin') {
        final adminCount = await countUsersByRole('admin');
        if (adminCount <= 1) {
          throw StateError('Debe existir al menos un administrador.');
        }
      }
      updateData['role'] = role;
    }

    if (updateData.isEmpty) {
      return;
    }

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final index = _webUsers.indexWhere((user) => user['id'] == userId);
      if (index == -1) {
        throw StateError('Usuario no encontrado.');
      }
      _webUsers[index].addAll(updateData);
      return;
    }

    final db = await database;
    await db.update('users', updateData, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> deleteUser(String userId) async {
    final existingUser = await getUser(userId);
    if (existingUser == null) {
      throw StateError('Usuario no encontrado.');
    }

    final currentRole = (existingUser['role'] as String?) ?? 'user';
    if (currentRole == 'admin') {
      final adminCount = await countUsersByRole('admin');
      if (adminCount <= 1) {
        throw StateError('No se puede eliminar el único administrador.');
      }
    }

    final currentUserId = await getCurrentUserId();

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      _webOrderItems.removeWhere((item) {
        final orderId = item['order_id'] as String?;
        if (orderId == null) return false;
        final order = _webOrders.firstWhere(
          (value) => value['id'] == orderId,
          orElse: () => <String, dynamic>{},
        );
        return order['user_id'] == userId;
      });
      _webOrders.removeWhere((order) => order['user_id'] == userId);
      _webUsers.removeWhere((user) => user['id'] == userId);
      if (currentUserId == userId) {
        await setCurrentUserId(null);
      }
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      final userOrders = await txn.query(
        'orders',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final order in userOrders) {
        final orderId = order['id'] as String;
        await txn.delete('order_items', where: 'order_id = ?', whereArgs: [orderId]);
      }

      await txn.delete('orders', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });

    if (currentUserId == userId) {
      await setCurrentUserId(null);
    }
  }

  Future<String> getOrCreateSessionUserId() async {
    final currentUserId = await getCurrentUserId();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return currentUserId;
    }

    final users = await getAllUsers();
    if (users.isNotEmpty) {
      final fallbackUserId = users.first['id'] as String;
      await setCurrentUserId(fallbackUserId);
      return fallbackUserId;
    }

    final createdUserId = await createUserWithCredentials(
      'Usuario Demo',
      'demo@foodfinder.com',
      '+598 9 1234567',
      password: '',
      role: 'user',
    );
    await setCurrentUserId(createdUserId);
    return createdUserId;
  }

  Future<String?> getCurrentUserId() async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return _webAppState['current_user_id'];
    }

    final db = await database;
    final result = await db.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['current_user_id'],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['value'] as String?;
  }

  Future<void> setCurrentUserId(String? userId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      if (userId == null || userId.isEmpty) {
        _webAppState.remove('current_user_id');
      } else {
        _webAppState['current_user_id'] = userId;
      }
      return;
    }

    final db = await database;
    if (userId == null || userId.isEmpty) {
      await db.delete('app_state', where: 'key = ?', whereArgs: ['current_user_id']);
      return;
    }

    await db.insert(
      'app_state',
      {'key': 'current_user_id', 'value': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> logout() async {
    await setCurrentUserId(null);
  }

  Future<Map<String, dynamic>> signInAsGuest() async {
    final userId = await getOrCreateSessionUserId();
    final user = await getUser(userId);
    if (user == null) {
      throw StateError('No se pudo crear sesión de invitado.');
    }
    return user;
  }

  // ===== PEDIDOS (por usuario) =====
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final orders = _webOrders
          .where((order) => order['user_id'] == userId)
          .toList();
      orders.sort(
        (a, b) =>
            (b['created_at'] as String).compareTo(a['created_at'] as String),
      );
      return orders;
    }
    final db = await database;
    return db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final orders = List<Map<String, dynamic>>.from(_webOrders);
      orders.sort(
        (a, b) =>
            (b['created_at'] as String).compareTo(a['created_at'] as String),
      );
      return orders;
    }
    final db = await database;
    return db.query('orders', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      return _webOrderItems
          .where((item) => item['order_id'] == orderId)
          .toList();
    }
    final db = await database;
    return db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final index = _webOrders.indexWhere((order) => order['id'] == orderId);
      if (index != -1) {
        _webOrders[index]['status'] = status;
      }
      return;
    }
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateOrder(
    String orderId, {
    String? restaurantId,
    String? restaurantName,
    double? totalPrice,
    String? status,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{};
    if (restaurantId != null) updateData['restaurant_id'] = restaurantId;
    if (restaurantName != null) updateData['restaurant_name'] = restaurantName;
    if (totalPrice != null) updateData['total_price'] = totalPrice;
    if (status != null) updateData['status'] = status;
    if (notes != null) updateData['notes'] = notes;

    if (updateData.isEmpty) {
      return;
    }

    if (kIsWeb) {
      await _ensureWebDataInitialized();
      final index = _webOrders.indexWhere((order) => order['id'] == orderId);
      if (index != -1) {
        _webOrders[index].addAll(updateData);
      }
      return;
    }

    final db = await database;
    await db.update(
      'orders',
      updateData,
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> deleteOrder(String orderId) async {
    if (kIsWeb) {
      await _ensureWebDataInitialized();
      _webOrderItems.removeWhere((item) => item['order_id'] == orderId);
      _webOrders.removeWhere((order) => order['id'] == orderId);
      return;
    }
    final db = await database;
    await db.delete('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }
}
