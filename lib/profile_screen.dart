import 'package:flutter/material.dart';
import 'database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _defaultName = 'Administrador';
  static const _defaultEmail = 'admin@foodfinder.com';
  static const _defaultPhone = '+598 9 1234 567';
  static const _defaultAddress = 'Av. Italia 2629';
  static const _defaultCity = 'Rivera, Uruguay';
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await _db.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el email para iniciar sesión')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final user = await _db.authenticateUser(email, password);
      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
        return;
      }

      setState(() {
        _user = user;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesión iniciada como ${user['role'] ?? 'usuario'}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() {
      _submitting = true;
    });

    try {
      final user = await _db.signInAsGuest();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresaste como invitado')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _db.logout();
    if (!mounted) return;
    setState(() {
      _user = null;
    });
  }

  Future<void> _deleteAccount() async {
    final userId = _user?['id'] as String?;
    if (userId == null || userId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: const Text(
            'Esta acción borrará tu cuenta y los datos asociados almacenados localmente en el dispositivo. No se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _db.deleteUser(userId);
      if (!mounted) return;
      setState(() {
        _user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta eliminada y sesión cerrada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la cuenta: $e')),
      );
    }
  }

  String _resolveProfileValue(String? currentValue, String defaultValue) {
    if (currentValue == null) {
      return defaultValue;
    }

    final normalizedValue = currentValue.trim().toLowerCase();
    const demoValues = {
      'usuario demo',
      'demo@foodfinder.com',
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

    if (_user == null) {
      return _buildLoginView(context);
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
    final role = (_user?['role'] as String? ?? 'user').toLowerCase();
    final canOpenUsersPanel = role == 'admin' || role == 'manager';

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
                  Text(email, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      role == 'admin'
                          ? 'Administrador'
                          : role == 'manager'
                              ? 'Supervisor'
                              : 'Usuario',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.orange.shade200),
                  ),
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
                  _buildSettingTile(
                    'Privacidad',
                    'Consulta cómo se tratan y eliminan tus datos',
                    Icons.lock,
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy');
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (canOpenUsersPanel) {
                          Navigator.pushNamed(context, '/users');
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Solo administradores o supervisores pueden abrir este panel.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: Text(
                        canOpenUsersPanel
                            ? (role == 'admin'
                                  ? 'Gestionar usuarios'
                                  : 'Ver panel de usuarios')
                            : 'Panel de usuarios (sin permisos)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canOpenUsersPanel
                            ? Colors.orange.shade700
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    canOpenUsersPanel
                        ? 'Tu rol puede acceder al panel de usuarios.'
                        : 'Acceso restringido: solo administradores y supervisores.',
                    style: TextStyle(
                      color: canOpenUsersPanel ? Colors.green.shade700 : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ayuda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildHelpTile('Preguntas frecuentes', Icons.help_outline),
                  _buildHelpTile('Contactar soporte', Icons.mail_outline),
                  _buildHelpTile(
                    'Términos y condiciones',
                    Icons.description,
                    onTap: () {
                      Navigator.pushNamed(context, '/terms');
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteAccount,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Eliminar cuenta y datos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
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

  Widget _buildLoginView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 34, color: Colors.orange),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accede como admin o usuario registrado',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Inicia sesión o crea una cuenta nueva',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Ingresar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submitting ? null : _loginAsGuest,
                child: const Text('Continuar como invitado'),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.28)),
              ),
              child: Text(
                'Tip: si no tienes cuenta, regístrate desde aquí y podrás iniciar sesión con tu nuevo email y contraseña.',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submitting
                    ? null
                    : () async {
                        final created = await Navigator.pushNamed(
                          context,
                          '/signup',
                        );
                        if (created == true) {
                          await _loadSession();
                        }
                      },
                icon: const Icon(Icons.person_add),
                label: const Text('Crear cuenta nueva'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
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

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildHelpTile(String title, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
