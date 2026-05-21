### ESTRUCTURA DE LA BASE DE DATOS - FoodFinder

La aplicación utiliza **SQLite (sqflite)** para almacenar todos los datos de forma local y en tiempo real.

## 📁 Ubicación del Código
- **lib/database_service.dart** - Servicio principal de la BD (singleton)
- **lib/products_screen.dart** - Pantalla de pedidos (usa createOrder con user_id)
- **lib/orders_screen.dart** - Pantalla de historial de pedidos (filtra por usuario)

## 📋 Tablas de la BD

### 1. **users**
Almacena información de los usuarios del sistema.
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  phone TEXT,
  created_at TEXT
);
```

### 2. **restaurants**
Datos de los restaurantes disponibles.
```sql
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
);
```

### 3. **menu_items**
Items del menú de cada restaurante.
```sql
CREATE TABLE menu_items (
  id TEXT PRIMARY KEY,
  restaurant_id TEXT NOT NULL,
  name TEXT,
  description TEXT,
  price REAL,
  category TEXT,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);
```

### 4. **orders**
Pedidos de los usuarios.
```sql
CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,          ← ID DEL USUARIO QUE HIZO EL PEDIDO
  restaurant_id TEXT NOT NULL,
  restaurant_name TEXT,
  total_price REAL,
  status TEXT,
  created_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);
```

### 5. **order_items**
Items individuales dentro de cada pedido.
```sql
CREATE TABLE order_items (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL,
  menu_item_id TEXT,
  item_name TEXT,
  quantity INTEGER,
  price REAL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
);
```

## 🔧 Métodos Principales del DatabaseService

### Usuarios
```dart
Future<String> createUser(String name, String email, String phone)
  → Crea un nuevo usuario en la BD

Future<List<Map<String, dynamic>>> getAllUsers()
  → Obtiene todos los usuarios

Future<Map<String, dynamic>?> getUser(String userId)
  → Obtiene datos de un usuario específico
```

### Pedidos
```dart
Future<String> createOrder(String userId, String restaurantId, 
                          String restaurantName, List items)
  → Crea un pedido para un usuario específico

Future<List<Map<String, dynamic>>> getUserOrders(String userId)
  → Obtiene solo los pedidos del usuario
```

## 🎯 Flujo de Uso Multi-Usuario (En Vivo)

### Paso 1: Crear múltiples usuarios
```dart
final userId1 = await db.createUser('Juan', 'juan@mail.com', '+598 99 123456');
final userId2 = await db.createUser('María', 'maria@mail.com', '+598 99 654321');
```

### Paso 2: Cada usuario hace pedidos
```dart
// Juan hace un pedido
await db.createOrder(userId1, '1', 'Pizzería Morosoli', items);

// María hace un pedido
await db.createOrder(userId2, '2', 'Sushi Tóquio', items);
```

### Paso 3: Ver pedidos solo de cada usuario
```dart
// Ver pedidos de Juan
final juanOrders = await db.getUserOrders(userId1);

// Ver pedidos de María
final mariaOrders = await db.getUserOrders(userId2);
```

## ⚙️ Datos Iniciales

La BD se inicializa automáticamente con:
- **1 usuario demo**: usuario_1 (Usuario Demo)
- **8 restaurantes**: Pizzería Morosoli, Sushi Tóquio, Chivitería El Corte, etc.
- **11 items de menú**: distribuidos entre los restaurantes

## 💾 Persistencia de Datos

- La BD se guarda automáticamente en el dispositivo/navegador
- Los datos persisten aunque se cierre la app
- Cada vez que se crea un pedido, se guarda inmediatamente

## 🚀 Para la Presentación al Profesor

Puedes demostrar:
1. **Crear 2+ usuarios** en vivo (en el ProfileScreen o una nueva pantalla de Admin)
2. **Hacer pedidos** con cada usuario (cada uno vé sus propios pedidos)
3. **Verificar la BD** mostrando que los datos se guardan con el user_id asociado
4. **Cambiar entre usuarios** y ver que cada uno tiene su propio historial
