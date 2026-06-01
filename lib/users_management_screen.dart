import 'package:flutter/material.dart';

import 'database_service.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _db = DatabaseService();
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _currentUser;
  bool _loading = true;
  String _newUserRole = 'user';
  String _roleFilter = 'all';
  String _sortMode = 'created_desc';
  int _currentPage = 1;
  static const int _pageSize = 8;

  bool get _canViewPanel {
    final role = (_currentUser?['role'] as String?) ?? 'user';
    return role == 'admin' || role == 'manager';
  }

  bool get _canManageUsers {
    final role = (_currentUser?['role'] as String?) ?? 'user';
    return role == 'admin';
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    final filteredByRole = _users.where((user) {
      final userRole = ((user['role'] as String?) ?? 'user').toLowerCase();
      return _roleFilter == 'all' || userRole == _roleFilter;
    }).toList();

    if (query.isEmpty) {
      return _sortUsers(filteredByRole);
    }

    final filteredByQuery = filteredByRole.where((user) {
      final name = ((user['name'] as String?) ?? '').toLowerCase();
      final email = ((user['email'] as String?) ?? '').toLowerCase();
      final phone = ((user['phone'] as String?) ?? '').toLowerCase();
      final id = ((user['id'] as String?) ?? '').toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          id.contains(query);
    }).toList();

    return _sortUsers(filteredByQuery);
  }

  List<Map<String, dynamic>> _sortUsers(List<Map<String, dynamic>> users) {
    final sorted = List<Map<String, dynamic>>.from(users);

    int compareValues(String? a, String? b) {
      return (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());
    }

    int compareCreatedAt(Map<String, dynamic> a, Map<String, dynamic> b) {
      final aDate = DateTime.tryParse((a['created_at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse((b['created_at'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    }

    sorted.sort((a, b) {
      switch (_sortMode) {
        case 'name_asc':
          return compareValues(a['name'] as String?, b['name'] as String?);
        case 'name_desc':
          return compareValues(b['name'] as String?, a['name'] as String?);
        case 'role_asc':
          return compareValues(a['role'] as String?, b['role'] as String?);
        case 'role_desc':
          return compareValues(b['role'] as String?, a['role'] as String?);
        case 'id_asc':
          return compareValues(a['id'] as String?, b['id'] as String?);
        case 'id_desc':
          return compareValues(b['id'] as String?, a['id'] as String?);
        case 'created_asc':
          return compareCreatedAt(a, b);
        case 'created_desc':
        default:
          return compareCreatedAt(b, a);
      }
    });

    return sorted;
  }

  int get _totalPages {
    final totalUsers = _filteredUsers.length;
    if (totalUsers == 0) return 1;
    return (totalUsers / _pageSize).ceil();
  }

  List<Map<String, dynamic>> get _pagedUsers {
    final filtered = _filteredUsers;
    final total = filtered.length;
    if (total == 0) return const [];

    final safePage = _currentPage.clamp(1, _totalPages);
    final start = (safePage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, total);
    return filtered.sublist(start, end);
  }

  void _goToPreviousPage() {
    if (_currentPage <= 1) return;
    setState(() {
      _currentPage -= 1;
    });
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages) return;
    setState(() {
      _currentPage += 1;
    });
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _syncCurrentPage() {
    final clamped = _currentPage.clamp(1, _totalPages);
    if (_currentPage != clamped) {
      _currentPage = clamped;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final currentUser = await _db.getCurrentUser();
    final users = await _db.getAllUsers();
    if (!mounted) return;
    setState(() {
      _currentUser = currentUser;
      _users = users;
      _loading = false;
      _currentPage = 1;
    });
  }

  Future<void> _loadUsers() async {
    final users = await _db.getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _syncCurrentPage();
    });
  }

  Future<void> _createUser() async {
    if (!_canManageUsers) {
      _showInfo('Tu rol no permite crear usuarios.');
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty) {
      _showInfo('Completa al menos nombre y email.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showInfo('Ingresa un email válido.');
      return;
    }

    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      _showInfo('Ya existe un usuario con ese email.');
      return;
    }

    try {
      await _db.createUserWithCredentials(
        name,
        email,
        phone,
        password: password,
        role: _newUserRole,
      );

      if (!mounted) return;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      setState(() {
        _newUserRole = 'user';
      });
      await _loadUsers();
      _showInfo('Usuario creado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _showInfo('No se pudo crear el usuario: $e');
    }
  }

  Future<void> _openEditUserDialog(Map<String, dynamic> user) async {
    if (!_canManageUsers) {
      _showInfo('Tu rol no permite editar usuarios.');
      return;
    }

    final nameController = TextEditingController(text: user['name'] as String? ?? '');
    final emailController = TextEditingController(text: user['email'] as String? ?? '');
    final phoneController = TextEditingController(text: user['phone'] as String? ?? '');
    final passwordController = TextEditingController();
    String selectedRole = (user['role'] as String? ?? 'user').toLowerCase();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: DatabaseService.availableRoles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    final updatedEmail = emailController.text.trim();
                    if (updatedEmail.isEmpty || !updatedEmail.contains('@')) {
                      _showInfo('Ingresa un email válido.');
                      return;
                    }

                    final existing = await _db.getUserByEmail(updatedEmail);
                    if (existing != null && existing['id'] != user['id']) {
                      _showInfo('Ese email ya está en uso por otro usuario.');
                      return;
                    }

                    try {
                      await _db.updateUser(
                        user['id'] as String,
                        name: nameController.text,
                        email: updatedEmail,
                        phone: phoneController.text,
                        password: passwordController.text,
                        role: selectedRole,
                      );
                      if (!mounted || !dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      await _loadInitialData();
                      _showInfo('Usuario actualizado.');
                    } catch (e) {
                      if (!mounted) return;
                      _showInfo('No se pudo actualizar: $e');
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  Future<void> _confirmDeleteUser(Map<String, dynamic> user) async {
    if (!_canManageUsers) {
      _showInfo('Tu rol no permite eliminar usuarios.');
      return;
    }

    final userId = user['id'] as String;
    final isCurrentUser = userId == _currentUser?['id'];
    if (isCurrentUser) {
      _showInfo('No puedes eliminar tu propio usuario desde aquí.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text(
            'Se eliminará el usuario ${user['name']} y sus pedidos asociados. ¿Deseas continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _db.deleteUser(userId);
      if (!mounted) return;
      await _loadInitialData();
      _showInfo('Usuario eliminado.');
    } catch (e) {
      if (!mounted) return;
      _showInfo('No se pudo eliminar: $e');
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'manager':
        return 'Supervisor';
      default:
        return 'Usuario';
    }
  }

  String _rolePermissionsText(String role) {
    switch (role) {
      case 'admin':
        return 'CRUD completo de usuarios, cambio de roles y acceso total al panel.';
      case 'manager':
        return 'Solo lectura en panel de usuarios y visualización de roles.';
      default:
        return 'Sin acceso al panel de usuarios.';
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatCreatedAt(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return '-';

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildUserActions(Map<String, dynamic> user) {
    final isCurrent = user['id'] == _currentUser?['id'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Editar',
          onPressed: _canManageUsers ? () => _openEditUserDialog(user) : null,
          icon: const Icon(Icons.edit, color: Colors.orange),
        ),
        IconButton(
          tooltip: 'Eliminar',
          onPressed: _canManageUsers && !isCurrent
              ? () => _confirmDeleteUser(user)
              : null,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }

  Widget _roleChip(String role) {
    final normalized = role.toLowerCase();
    final color = normalized == 'admin'
        ? Colors.deepOrange
        : normalized == 'manager'
            ? Colors.blueGrey
            : Colors.orange;

    return Chip(
      label: Text(
        _roleLabel(normalized),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildUsersCards(List<Map<String, dynamic>> users) {
    return Column(
      children: users.map((user) {
        final role = (user['role'] as String? ?? 'user').toLowerCase();
        final isCurrent = user['id'] == _currentUser?['id'];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: role == 'admin'
                  ? Colors.deepOrange
                  : role == 'manager'
                      ? Colors.blueGrey
                      : Colors.orange,
              child: Icon(
                role == 'admin' ? Icons.shield : Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
            title: Text(
              '${user['name']} ${isCurrent ? '(tú)' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] as String? ?? ''),
                Text('Tel: ${user['phone'] ?? '-'}'),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _roleChip(role),
                ),
                Text(
                  'Creado: ${_formatCreatedAt(user['created_at'] as String?)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'ID: ${user['id']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: _buildUserActions(user),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsersTable(List<Map<String, dynamic>> users) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStatePropertyAll(Colors.orange.shade50),
            columns: const [
              DataColumn(label: Text('Usuario')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Teléfono')),
              DataColumn(label: Text('Rol')),
              DataColumn(label: Text('Creado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: users.map((user) {
              final role = (user['role'] as String? ?? 'user').toLowerCase();
              final isCurrent = user['id'] == _currentUser?['id'];
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: role == 'admin'
                              ? Colors.deepOrange
                              : role == 'manager'
                                  ? Colors.blueGrey
                                  : Colors.orange,
                          child: Icon(
                            role == 'admin' ? Icons.shield : Icons.person,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            '${user['name']} ${isCurrent ? '(tú)' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text((user['email'] as String?) ?? '-')),
                  DataCell(Text((user['phone'] as String?)?.isNotEmpty == true ? user['phone'] as String : '-')),
                  DataCell(_roleChip(role)),
                  DataCell(Text(_formatCreatedAt(user['created_at'] as String?))),
                  DataCell(_buildUserActions(user)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canViewPanel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Usuarios'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tu rol no tiene permisos para abrir este panel.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    final currentRole = (_currentUser?['role'] as String? ?? 'user').toLowerCase();
    final filteredUsers = _filteredUsers;
    final pagedUsers = _pagedUsers;
    final totalPages = _totalPages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Usuarios'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sesión actual',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('Usuario: ${_currentUser?['name'] ?? 'Sin sesión'}'),
                    Text('Rol: ${_roleLabel(currentRole)}'),
                    const SizedBox(height: 8),
                    Text(
                      _rolePermissionsText(currentRole),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Roles y restricciones',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final role in DatabaseService.availableRoles)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• ${_roleLabel(role)}: ${_rolePermissionsText(role)}'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear usuario',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      enabled: _canManageUsers,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      enabled: _canManageUsers,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      enabled: _canManageUsers,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      enabled: _canManageUsers,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _newUserRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: DatabaseService.availableRoles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(),
                      onChanged: _canManageUsers
                          ? (value) {
                              if (value == null) return;
                              setState(() {
                                _newUserRole = value;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _canManageUsers ? _createUser : null,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Crear usuario'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buscar y filtrar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por nombre, email, teléfono o ID',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _resetPagination();
                                },
                                icon: const Icon(Icons.clear),
                              ),
                      ),
                      onChanged: (_) => _resetPagination(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _roleFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por rol',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'all',
                          child: Text('Todos los roles'),
                        ),
                        ...DatabaseService.availableRoles.map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(_roleLabel(role)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _roleFilter = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _sortMode,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sort),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'created_desc', child: Text('Fecha reciente')),
                        DropdownMenuItem(value: 'created_asc', child: Text('Fecha antigua')),
                        DropdownMenuItem(value: 'name_asc', child: Text('Nombre A-Z')),
                        DropdownMenuItem(value: 'name_desc', child: Text('Nombre Z-A')),
                        DropdownMenuItem(value: 'role_asc', child: Text('Rol A-Z')),
                        DropdownMenuItem(value: 'role_desc', child: Text('Rol Z-A')),
                        DropdownMenuItem(value: 'id_asc', child: Text('ID ascendente')),
                        DropdownMenuItem(value: 'id_desc', child: Text('ID descendente')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _sortMode = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Usuarios registrados (${filteredUsers.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Vista automática: tarjetas en móvil y tabla compacta en escritorio.',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 10),
            if (filteredUsers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No hay usuarios registrados.'),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    return _buildUsersTable(pagedUsers);
                  }
                  return _buildUsersCards(pagedUsers);
                },
              ),
            if (filteredUsers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                  Text(
                    'Página $_currentPage de $totalPages',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  OutlinedButton.icon(
                    onPressed: _currentPage < totalPages ? _goToNextPage : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Siguiente'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}