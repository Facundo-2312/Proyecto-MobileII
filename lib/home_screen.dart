import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<_FeatureItem> _features = const [
    _FeatureItem(
      icon: Icons.location_on,
      title: 'Búsqueda por ubicación',
      subtitle: 'Encuentra restaurantes cercanos a ti',
      routeName: '/location-search',
    ),
    _FeatureItem(
      icon: Icons.star,
      title: 'Calificaciones',
      subtitle: 'Consulta las opiniones de otros usuarios',
      routeName: '/ratings',
    ),
    _FeatureItem(
      icon: Icons.delivery_dining,
      title: 'Entrega rápida',
      subtitle: 'Recibe tu pedido en minutos',
      routeName: '/fast-delivery',
    ),
    _FeatureItem(
      icon: Icons.map,
      title: 'Mapa interactivo',
      subtitle: 'Visualiza restaurantes en el mapa',
      routeName: '/map',
    ),
    _FeatureItem(
      icon: Icons.inventory_2,
      title: 'Tus pedidos',
      subtitle: 'Historial completo de tus pedidos',
      routeName: '/orders',
    ),
    _FeatureItem(
      icon: Icons.person,
      title: 'Tu perfil',
      subtitle: 'Personaliza tu cuenta y preferencias',
      routeName: '/profile',
    ),
    _FeatureItem(
      icon: Icons.person_add_alt_1,
      title: 'Crear cuenta',
      subtitle: 'Registra un nuevo usuario en pocos pasos',
      routeName: '/signup',
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isVeryNarrow = screenWidth < 260;
    final isUltraNarrow = screenWidth < 220;
    final horizontalPadding = isVeryNarrow ? 10.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isUltraNarrow ? 42 : kToolbarHeight,
        title: Text(
          'FoodFinder',
          style: TextStyle(fontSize: isUltraNarrow ? 14 : 20),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Vista smartwatch (demo)',
            onPressed: () => Navigator.pushNamed(context, '/wearable'),
            icon: const Icon(Icons.watch),
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: !isMobile,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isUltraNarrow ? 10 : (isVeryNarrow ? 14 : 20),
                  horizontalPadding,
                  isUltraNarrow ? 14 : (isVeryNarrow ? 18 : 24),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade700],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: isUltraNarrow
                          ? 28
                          : (isVeryNarrow ? 34 : (isMobile ? 48 : 60)),
                      color: Colors.white,
                    ),
                    SizedBox(height: isUltraNarrow ? 4 : (isVeryNarrow ? 6 : 10)),
                    Text(
                      '¡Bienvenido a FoodFinder!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isUltraNarrow
                            ? 13
                            : (isVeryNarrow ? 16 : (isMobile ? 20 : 24)),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isUltraNarrow ? 2 : (isVeryNarrow ? 4 : 8)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        'Descubre los mejores restaurantes de Montevideo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isUltraNarrow
                              ? 8
                              : (isVeryNarrow ? 10 : (isMobile ? 12 : 14)),
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  12,
                ),
                child: Text(
                  'Características de FoodFinder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isUltraNarrow ? 13 : (isVeryNarrow ? 16 : 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                16,
              ),
              sliver: isMobile
                  ? SliverList.separated(
                      itemCount: _features.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final feature = _features[index];
                        return _buildFeatureCard(
                          icon: feature.icon,
                          title: feature.title,
                          subtitle: feature.subtitle,
                          onTap: () => Navigator.pushNamed(
                            context,
                            feature.routeName,
                          ),
                          isCompact: true,
                          isVeryNarrow: isVeryNarrow,
                          isUltraNarrow: isUltraNarrow,
                        );
                      },
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final feature = _features[index];
                        return _buildFeatureCard(
                          icon: feature.icon,
                          title: feature.title,
                          subtitle: feature.subtitle,
                          onTap: () => Navigator.pushNamed(
                            context,
                            feature.routeName,
                          ),
                          isCompact: false,
                          isVeryNarrow: false,
                          isUltraNarrow: false,
                        );
                      }, childCount: _features.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth < 1100 ? 2 : 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: screenWidth < 1100 ? 2.4 : 2.1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isCompact,
    required bool isVeryNarrow,
    required bool isUltraNarrow,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(
            isCompact
                ? (isUltraNarrow ? 8 : (isVeryNarrow ? 10 : 14))
                : 16,
          ),
          child: isCompact
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isUltraNarrow ? 28 : (isVeryNarrow ? 34 : 44),
                      height: isUltraNarrow ? 28 : (isVeryNarrow ? 34 : 44),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(isUltraNarrow ? 8 : 12),
                      ),
                      child: Icon(
                        icon,
                        size: isUltraNarrow ? 14 : (isVeryNarrow ? 18 : 24),
                        color: Colors.orange[800],
                      ),
                    ),
                    SizedBox(width: isUltraNarrow ? 6 : (isVeryNarrow ? 8 : 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isUltraNarrow ? 9 : (isVeryNarrow ? 11 : 15),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isUltraNarrow ? 1 : (isVeryNarrow ? 2 : 4)),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isUltraNarrow ? 7 : (isVeryNarrow ? 9 : 12),
                            ),
                            maxLines: isUltraNarrow ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isUltraNarrow ? 2 : (isVeryNarrow ? 4 : 8)),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isUltraNarrow ? 10 : (isVeryNarrow ? 12 : 16),
                      color: Colors.grey[500],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(icon, size: 28, color: Colors.orange[800]),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });
}
