import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodfinder/database_service.dart';
import 'package:foodfinder/main.dart';
import 'package:foodfinder/orders_screen.dart';
import 'package:foodfinder/register_user_screen.dart';

void main() {
  testWidgets('FoodFinder app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodFinderApp());

    expect(find.byType(FoodFinderApp), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('Bottom navigation changes selected tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FoodFinderApp());

    BottomNavigationBar navBar() => tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );

    expect(navBar().currentIndex, 0);

    await tester.tap(find.byIcon(Icons.restaurant_menu));
    await tester.pump(const Duration(milliseconds: 200));

    expect(navBar().currentIndex, 1);

    await tester.tap(find.byIcon(Icons.person));
    await tester.pump(const Duration(milliseconds: 200));

    expect(navBar().currentIndex, 4);
  });

  testWidgets('Missing screen shows wearable-specific fallback copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MissingRestaurantScreen(routeName: '/wearable')),
    );

    expect(find.text('Detalle no disponible'), findsOneWidget);
    expect(
      find.textContaining('simulación de interfaz dentro de la app principal'),
      findsOneWidget,
    );
  });

  testWidgets('Register user screen creates a new account', (
    WidgetTester tester,
  ) async {
    final db = DatabaseService();
    final email = 'nuevo_${DateTime.now().millisecondsSinceEpoch}@mail.com';

    await tester.pumpWidget(
      const MaterialApp(home: RegisterUserScreen()),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      'Usuario Test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      email,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teléfono'),
      '099000111',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      '1234',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      '1234',
    );

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 600));

    final createdUser = await db.getUserByEmail(email);
    expect(createdUser, isNotNull);
    expect(createdUser?['name'], 'Usuario Test');
  });

  testWidgets('Home screen has a signup shortcut card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FoodFinderApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Crear cuenta'), findsOneWidget);

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(RegisterUserScreen), findsOneWidget);
  });

  testWidgets('Deleting an order asks for confirmation and removes it', (
    WidgetTester tester,
  ) async {
    final db = DatabaseService();
    final userId = await db.getOrCreateSessionUserId();
    final orderId = await db.createOrderSimple(
      userId,
      '1',
      'Pizzeria Morosoli',
      700,
      'Pendiente',
    );

    await tester.pumpWidget(
      const MaterialApp(home: OrdersScreen()),
    );
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Confirmar eliminación'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Eliminar'));
    await tester.pump(const Duration(milliseconds: 900));

    final remainingOrders = await db.getUserOrders(userId);
    final exists = remainingOrders.any((order) => order['id'] == orderId);
    expect(exists, isFalse);
  });

  testWidgets('Edit order allows saving comments', (WidgetTester tester) async {
    final db = DatabaseService();
    final userId = await db.getOrCreateSessionUserId();
    final orderId = await db.createOrderSimple(
      userId,
      '1',
      'Pizzeria Morosoli',
      800,
      'Pendiente',
    );

    await tester.pumpWidget(
      const MaterialApp(home: OrdersScreen()),
    );
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Comentarios / observaciones'),
      'Sin cebolla, por favor',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
    await tester.pump(const Duration(milliseconds: 900));

    final updatedOrders = await db.getUserOrders(userId);
    final updatedOrder = updatedOrders.firstWhere((order) => order['id'] == orderId);
    expect(updatedOrder['notes'], 'Sin cebolla, por favor');
  });
}
