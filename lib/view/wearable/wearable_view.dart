import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../database_service.dart';

class WearableView extends StatefulWidget {
  const WearableView({super.key});

  @override
  State<WearableView> createState() => _WearableViewState();
}

class _WearableViewState extends State<WearableView> {
  int _index = 0;

  final List<_WearableSection> _sections = const [
    _WearableSection(
      icon: Icons.home,
      title: 'Inicio',
      subtitle: 'Resumen rapido',
      actionLabel: 'Abrir inicio',
      routeName: '/home',
      highlight: '3 cercanos',
    ),
    _WearableSection(
      icon: Icons.restaurant_menu,
      title: 'Productos',
      subtitle: 'Destacados del dia',
      actionLabel: 'Ver menu',
      routeName: '/products',
      highlight: 'Top hoy',
    ),
    _WearableSection(
      icon: Icons.map,
      title: 'Mapa',
      subtitle: 'Tiendas cercanas',
      actionLabel: 'Abrir mapa',
      routeName: '/map',
      highlight: 'Rivera',
    ),
    _WearableSection(
      icon: Icons.shopping_cart,
      title: 'Pedidos',
      subtitle: 'Estado en tiempo real',
      actionLabel: 'Ver pedidos',
      routeName: '/orders',
      highlight: '2 activos',
    ),
    _WearableSection(
      icon: Icons.person,
      title: 'Perfil',
      subtitle: 'Cuenta y ajustes',
      actionLabel: 'Abrir perfil',
      routeName: '/profile',
      highlight: 'Usuario',
    ),
  ];

  void _goToSection(int index) {
    setState(() => _index = index);
  }

  int _wrapIndex(int index) {
    final length = _sections.length;
    return (index % length + length) % length;
  }

  void _openRoute(String routeName) {
    if (routeName == '/home') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _WearableHomeMiniScreen(),
        ),
      );
      return;
    }

    if (routeName == '/products') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _WearableProductsMiniScreen(),
        ),
      );
      return;
    }

    if (routeName == '/orders') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _WearableOrdersMiniScreen(),
        ),
      );
      return;
    }

    if (routeName == '/profile') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _WearableProfileMiniScreen(),
        ),
      );
      return;
    }

    if (routeName == '/map') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _WearableMiniMapScreen(),
        ),
      );
      return;
    }

    final section = _sections.firstWhere(
      (item) => item.routeName == routeName,
      orElse: () => _sections[_index],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WearableSectionScreen(section: section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = _sections[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipOval(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.restaurant, color: Colors.orange, size: 10),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'FoodFinder',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.watch, color: Colors.white70, size: 11),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Demo UI smartwatch',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 9,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Volver',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.place, color: Colors.orange, size: 10),
                              SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'Rivera',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: _WearableSectionView(
                            section: currentSection,
                            onAction: () => _openRoute(currentSection.routeName),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ArrowButton(
                              icon: Icons.chevron_left,
                              onTap: () => _goToSection(_wrapIndex(_index - 1)),
                            ),
                            Row(
                              children: List.generate(_sections.length, (index) {
                                final selected = index == _index;
                                return Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  decoration: BoxDecoration(
                                    color: selected ? Colors.orange : Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                            _ArrowButton(
                              icon: Icons.chevron_right,
                              onTap: () => _goToSection(_wrapIndex(_index + 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WearableSection {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String routeName;
  final String highlight;

  const _WearableSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.routeName,
    required this.highlight,
  });
}

class _WearableSectionView extends StatelessWidget {
  final _WearableSection section;
  final VoidCallback onAction;

  const _WearableSectionView({required this.section, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ultraCompact = constraints.maxHeight < 56;
        final compact = constraints.maxHeight < 72;
        final horizontalGap = ultraCompact ? 2.0 : (compact ? 3.0 : 4.0);
        final outerPadding = ultraCompact ? 3.0 : (compact ? 4.0 : 6.0);
        final iconSize = ultraCompact ? 9.0 : (compact ? 10.0 : 12.0);
        final titleSize = ultraCompact ? 8.0 : (compact ? 9.0 : 10.0);
        final chipSize = ultraCompact ? 5.0 : (compact ? 6.0 : 7.0);
        final subtitleSize = ultraCompact ? 7.0 : (compact ? 8.0 : 9.0);
        final buttonHeight = ultraCompact ? 16.0 : (compact ? 20.0 : 24.0);
        final buttonFontSize = ultraCompact ? 7.0 : (compact ? 8.0 : 9.0);
        final showSubtitle = !ultraCompact;
        final showHighlight = !ultraCompact;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.orange.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(outerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(section.icon, color: Colors.white, size: iconSize),
                          SizedBox(width: horizontalGap),
                          Expanded(
                            child: Text(
                              section.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showHighlight)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 3 : 4,
                          vertical: compact ? 1 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          section.highlight,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: chipSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ultraCompact ? 1 : 2),
                if (showSubtitle)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        section.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                SizedBox(height: ultraCompact ? 1 : 2),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      section.actionLabel,
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 11, color: Colors.white70),
      ),
    );
  }
}

class _WearableSectionScreen extends StatelessWidget {
  final _WearableSection section;

  const _WearableSectionScreen({required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipOval(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              section.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _WearableSectionView(
                          section: section,
                          onAction: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            'Volver al reloj',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WearableMiniMapScreen extends StatefulWidget {
  const _WearableMiniMapScreen();

  @override
  State<_WearableMiniMapScreen> createState() => _WearableMiniMapScreenState();
}

class _WearableMiniShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _WearableMiniShell({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipOval(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          trailing ?? const SizedBox(width: 18, height: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WearableHomeMiniScreen extends StatelessWidget {
  const _WearableHomeMiniScreen();

  @override
  Widget build(BuildContext context) {
    return _WearableMiniShell(
      title: 'Inicio mini',
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.4,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _MiniNavTile(
            icon: Icons.restaurant_menu,
            label: 'Productos',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _WearableProductsMiniScreen(),
              ),
            ),
          ),
          _MiniNavTile(
            icon: Icons.shopping_cart,
            label: 'Pedidos',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _WearableOrdersMiniScreen(),
              ),
            ),
          ),
          _MiniNavTile(
            icon: Icons.map,
            label: 'Mapa',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _WearableMiniMapScreen(),
              ),
            ),
          ),
          _MiniNavTile(
            icon: Icons.person,
            label: 'Perfil',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _WearableProfileMiniScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.orange),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WearableProductsMiniScreen extends StatefulWidget {
  const _WearableProductsMiniScreen();

  @override
  State<_WearableProductsMiniScreen> createState() =>
      _WearableProductsMiniScreenState();
}

class _WearableProductsMiniScreenState extends State<_WearableProductsMiniScreen> {
  final DatabaseService _db = DatabaseService();
  final Map<String, int> _cart = {};
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _menu = [];
  String? _selectedRestaurantId;
  String _selectedRestaurantName = 'Restaurante';
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await _db.getOrCreateSessionUserId();
    final restaurants = await _db.getRestaurants();

    if (!mounted) return;

    String? selectedId;
    String selectedName = 'Restaurante';
    List<Map<String, dynamic>> menu = [];
    if (restaurants.isNotEmpty) {
      selectedId = restaurants.first['id'] as String;
      selectedName = restaurants.first['name'] as String? ?? 'Restaurante';
      menu = await _db.getMenuItems(selectedId);
    }

    if (!mounted) return;

    setState(() {
      _userId = userId;
      _restaurants = restaurants;
      _selectedRestaurantId = selectedId;
      _selectedRestaurantName = selectedName;
      _menu = menu;
      _loading = false;
    });
  }

  Future<void> _switchRestaurant() async {
    if (_restaurants.length < 2 || _selectedRestaurantId == null) return;
    final currentIndex = _restaurants.indexWhere(
      (restaurant) => restaurant['id'] == _selectedRestaurantId,
    );
    final nextIndex = (currentIndex + 1) % _restaurants.length;
    final next = _restaurants[nextIndex];
    final nextId = next['id'] as String;
    final menu = await _db.getMenuItems(nextId);

    if (!mounted) return;

    setState(() {
      _selectedRestaurantId = nextId;
      _selectedRestaurantName = next['name'] as String? ?? 'Restaurante';
      _menu = menu;
      _cart.clear();
    });
  }

  Future<void> _createQuickOrder() async {
    if (_userId == null || _selectedRestaurantId == null || _cart.isEmpty) {
      return;
    }

    double total = 0;
    for (final item in _menu) {
      final qty = _cart[item['id']] ?? 0;
      if (qty > 0) {
        total += ((item['price'] as num?)?.toDouble() ?? 0) * qty;
      }
    }

    await _db.createOrderSimple(
      _userId!,
      _selectedRestaurantId!,
      _selectedRestaurantName,
      total,
      'Pendiente',
    );

    if (!mounted) return;

    setState(() {
      _cart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido creado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _cart.values.fold<int>(0, (sum, qty) => sum + qty);

    return _WearableMiniShell(
      title: 'Productos mini',
      trailing: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _switchRestaurant,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.swap_horiz, size: 10, color: Colors.orange),
        ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedRestaurantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menu.length > 3 ? 3 : _menu.length,
                    itemBuilder: (context, index) {
                      final item = _menu[index];
                      final itemId = item['id'] as String;
                      final qty = _cart[itemId] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name'] as String? ?? 'Item',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  final next = qty - 1;
                                  if (next <= 0) {
                                    _cart.remove(itemId);
                                  } else {
                                    _cart[itemId] = next;
                                  }
                                });
                              },
                              child: const Icon(Icons.remove, color: Colors.white70, size: 11),
                            ),
                            SizedBox(
                              width: 12,
                              child: Text(
                                '$qty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _cart[itemId] = qty + 1;
                                });
                              },
                              child: const Icon(Icons.add, color: Colors.white, size: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  height: 18,
                  child: ElevatedButton(
                    onPressed: totalItems == 0 ? null : _createQuickOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Pedir ($totalItems)',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WearableOrdersMiniScreen extends StatefulWidget {
  const _WearableOrdersMiniScreen();

  @override
  State<_WearableOrdersMiniScreen> createState() => _WearableOrdersMiniScreenState();
}

class _WearableOrdersMiniScreenState extends State<_WearableOrdersMiniScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = await _db.getOrCreateSessionUserId();
    final orders = await _db.getUserOrders(userId);
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  String _nextStatus(String current) {
    if (current == 'Pendiente') return 'Preparando';
    if (current == 'Preparando') return 'Entregado';
    return 'Pendiente';
  }

  Future<void> _cycleStatus(Map<String, dynamic> order) async {
    final current = order['status'] as String? ?? 'Pendiente';
    await _db.updateOrderStatus(order['id'] as String, _nextStatus(current));
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return _WearableMiniShell(
      title: 'Pedidos mini',
      child: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'Sin pedidos',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                )
              : ListView.builder(
                  itemCount: _orders.length > 4 ? 4 : _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final status = order['status'] as String? ?? 'Pendiente';
                    return InkWell(
                      onTap: () => _cycleStatus(order),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                order['restaurant_name'] as String? ?? 'Restaurante',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _WearableProfileMiniScreen extends StatefulWidget {
  const _WearableProfileMiniScreen();

  @override
  State<_WearableProfileMiniScreen> createState() => _WearableProfileMiniScreenState();
}

class _WearableProfileMiniScreenState extends State<_WearableProfileMiniScreen> {
  final DatabaseService _db = DatabaseService();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    var user = await _db.getCurrentUser();
    user ??= await _db.signInAsGuest();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _db.logout();
    if (!mounted) return;
    setState(() {
      _user = null;
    });
  }

  Future<void> _guestLogin() async {
    final user = await _db.signInAsGuest();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = (_user?['role'] as String? ?? 'user').toUpperCase();
    final name = _user?['name'] as String? ?? 'Sin sesion';
    final email = _user?['email'] as String? ?? 'sin-email';

    return _WearableMiniShell(
      title: 'Perfil mini',
      child: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 7),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 18,
                  child: ElevatedButton(
                    onPressed: _user == null ? _guestLogin : _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _user == null ? Colors.orange : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _user == null ? 'Entrar invitado' : 'Cerrar sesion',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WearableMiniMapScreenState extends State<_WearableMiniMapScreen> {
  static const LatLng _riveraCenter = LatLng(-30.9053, -55.5508);
  final MapController _mapController = MapController();
  double _zoom = 14;

  void _resetView() {
    _zoom = 14;
    _mapController.move(_riveraCenter, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipOval(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Mapa mini',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _resetView,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.my_location,
                                size: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _riveraCenter,
                              initialZoom: _zoom,
                              minZoom: 10,
                              maxZoom: 18,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all,
                              ),
                              onPositionChanged: (position, _) {
                                _zoom = position.zoom ?? _zoom;
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.foodfinder.app',
                              ),
                              const MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _riveraCenter,
                                    width: 26,
                                    height: 26,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.deepOrange,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
