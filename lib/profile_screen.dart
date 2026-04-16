import 'package:flutter/material.dart';
import 'database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseService();
  static const _defaultName = 'Facundo Mederos';
  static const _defaultEmail = 'facundo.mederos@gmail.com';
  static const _defaultPhone = '+598 9 1234 567';
  static const _defaultAddress = 'Av. Italia 2629';
  static const _defaultCity = 'Rivera, Uruguay';
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _db.getUser('user_1');
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  String _resolveProfileValue(String? currentValue, String defaultValue) {
    if (currentValue == null) {
      return defaultValue;
    }

    final normalizedValue = currentValue.trim().toLowerCase();
    const demoValues = {
      'usuario demo',
      'demo@foodfinder.com',
      'user_1',
      '+598 9 1234 567',
      'calle principal 123, rivera',
    };

    if (normalizedValue.isEmpty || demoValues.contains(normalizedValue)) {
      return defaultValue;
    }

    return currentValue;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = _resolveProfileValue(_user?['name'] as String?, _defaultName);
    final email = _resolveProfileValue(
      _user?['email'] as String?,
      _defaultEmail,
    );
    final phone = _resolveProfileValue(
      _user?['phone'] as String?,
      _defaultPhone,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.shade700],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información personal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile('Teléfono', phone, Icons.phone),
                  _buildInfoTile('Dirección', _defaultAddress, Icons.location_on),
                  _buildInfoTile('Ciudad', _defaultCity, Icons.location_city),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuración',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile('Notificaciones', 'Recibe alertas de tus pedidos', Icons.notifications),
                  _buildSettingTile('Métodos de pago', 'Administra tus tarjetas', Icons.credit_card),
                  _buildSettingTile('Privacidad', 'Controla tu privacidad', Icons.lock),
                  const SizedBox(height: 24),
                  const Text(
                    'Ayuda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildHelpTile('Preguntas frecuentes', Icons.help_outline),
                  _buildHelpTile('Contactar soporte', Icons.mail_outline),
                  _buildHelpTile('Términos y condiciones', Icons.description),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildHelpTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
