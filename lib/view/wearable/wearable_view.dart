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
      subtitle: 'Resumen rápido',
      actionLabel: 'Abrir home',
      routeName: '/products',
      highlight: '3 cercanos',
    ),
    _WearableSection(
      icon: Icons.restaurant_menu,
      title: 'Productos',
                  width: 136,
                  height: 136,
      routeName: '/products',
      highlight: 'Top hoy',
    ),
                      borderRadius: BorderRadius.circular(16),
      icon: Icons.map,
      title: 'Mapa',
                    child: Padding(
                      padding: const EdgeInsets.all(5),
      routeName: '/map',
      highlight: 'Rivera',
    ),
    _WearableSection(
      icon: Icons.shopping_cart,
                                width: 14,
                                height: 14,
      actionLabel: 'Ver pedidos',
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
    ),
    _WearableSection(
      icon: Icons.person,
      title: 'Perfil',
                                  size: 9,
      actionLabel: 'Abrir perfil',
      routeName: '/profile',
                              const SizedBox(width: 3),
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }
                                    fontSize: 9,
  void _goToSection(int index) {
    setState(() => _index = index);
  }

  int _wrapIndex(int index) {
    final length = _sections.length;
    return (index % length + length) % length;
                                size: 10,

  void _openRoute(String routeName) {
    Navigator.of(context).pushNamed(routeName);
                          const SizedBox(height: 2),

                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
    return Scaffold(
      backgroundColor: Colors.black,
                              borderRadius: BorderRadius.circular(9),
        child: ClipOval(
          child: SizedBox(
            width: 250,
                                Icon(Icons.place, color: Colors.orange, size: 9),
                                SizedBox(width: 2),
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 148,
                  height: 148,
                  child: Container(
                    decoration: BoxDecoration(
                                      fontSize: 7,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          const SizedBox(height: 3),
                            children: [
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 120,
                                height: 52,
                                child: _WearableSectionView(
                                  section: _sections[_index],
                                  onAction: () => _openRoute(_sections[_index].routeName),
                                ),
                              ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                          const SizedBox(height: 2),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Text(
                                  'FoodFinder',
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.watch,
                                color: Colors.white70,
                                size: 11,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
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
                              section: _sections[_index],
                              onAction: () => _openRoute(_sections[_index].routeName),
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
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    section.highlight,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Text(
              section.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                height: 0.95,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 14,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  section.actionLabel,
                  style: const TextStyle(
                    fontSize: 5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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