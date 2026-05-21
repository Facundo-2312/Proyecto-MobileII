import 'package:flutter/material.dart';

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
      actionLabel: 'Abrir home',
      routeName: '/products',
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
                        const SizedBox(height: 3),
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
                        const SizedBox(height: 4),
                        Container(
                          height: 20,
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
                        const SizedBox(height: 4),
                        Expanded(
                          child: _WearableSectionView(
                            section: currentSection,
                            onAction: () => _openRoute(currentSection.routeName),
                          ),
                        ),
                        const SizedBox(height: 3),
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
        final compact = constraints.maxHeight < 72;
        final horizontalGap = compact ? 3.0 : 4.0;
        final outerPadding = compact ? 4.0 : 6.0;
        final iconSize = compact ? 10.0 : 12.0;
        final titleSize = compact ? 9.0 : 10.0;
        final chipSize = compact ? 6.0 : 7.0;
        final subtitleSize = compact ? 8.0 : 9.0;
        final buttonHeight = compact ? 20.0 : 24.0;
        final buttonFontSize = compact ? 8.0 : 9.0;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  section.subtitle,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
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
