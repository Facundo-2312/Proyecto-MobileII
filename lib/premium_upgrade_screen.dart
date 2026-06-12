import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database_service.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final _db = DatabaseService();

  Map<String, dynamic>? _currentUser;
  bool _loading = true;
  bool _updatingPlan = false;
  bool _hasPremiumAccess = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final user = await _db.getCurrentUser();
    final hasPremiumAccess = await _db.hasPremiumAccess();
    if (!mounted) return;

    setState(() {
      _currentUser = user;
      _hasPremiumAccess = hasPremiumAccess;
      _loading = false;
    });
  }

  Future<void> _updatePlan(bool enabled) async {
    setState(() {
      _updatingPlan = true;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      await _db.setPremiumAccess(enabled);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Plan Premium activado correctamente'
                : 'Volviste al plan gratuito',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el plan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingPlan = false;
        });
      }
    }
  }

  Future<void> _selectPremiumPlan() async {
    FocusScope.of(context).unfocus();

    final purchaseResult = await showModalBottomSheet<_PurchaseResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _PremiumPaymentSheet(db: _db),
    );

    if (!mounted || purchaseResult == null) {
      return;
    }

    await _showPurchaseReceipt(purchaseResult);
    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Future<void> _showPurchaseReceipt(_PurchaseResult purchaseResult) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 42,
          ),
          title: const Text('Compra aprobada'),
          content: Text(
            'Tu plan Premium quedó activo. Tarjeta de ${purchaseResult.cardType.toLowerCase()} terminada en ${purchaseResult.last4}.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userName = (_currentUser?['name'] as String?)?.trim();
    final displayName = userName == null || userName.isEmpty
        ? 'Invitado'
        : userName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción Premium'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    _hasPremiumAccess ? 'Plan activo: Premium' : 'Plan actual: Gratuito',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 12),
                Text(
                  'FoodFinder Plus para $displayName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulación de monetización con desbloqueo visual de funciones premium y compra guiada desde un modal de tarjeta.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PlanCard(
                title: 'Plan gratuito',
                price: 'USD 0/mes',
                accentColor: Colors.blueGrey,
                highlighted: !_hasPremiumAccess,
                bullets: const [
                  'Acceso al mapa y catálogo base',
                  'Anuncios promocionales simulados',
                  'Funciones exclusivas bloqueadas',
                ],
                actionLabel: _hasPremiumAccess ? 'Cambiar a gratuito' : 'Plan actual',
                onPressed: _hasPremiumAccess && !_updatingPlan
                    ? () => _updatePlan(false)
                    : null,
              ),
              _PlanCard(
                title: 'Plan premium',
                price: 'USD 4.99/mes',
                accentColor: Colors.orange,
                highlighted: _hasPremiumAccess,
                bullets: const [
                  'Sin anuncios simulados',
                  'Calificaciones y entrega rápida desbloqueadas',
                  'Acceso prioritario a nuevas experiencias',
                ],
                actionLabel: _hasPremiumAccess ? 'Plan activo' : 'Seleccionar Premium',
                onPressed: _hasPremiumAccess || _updatingPlan
                    ? null
                    : _selectPremiumPlan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comparativa de beneficios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(Icons.ads_click, 'Anuncios en home', !_hasPremiumAccess),
                  _buildBenefitRow(Icons.star, 'Calificaciones avanzadas', _hasPremiumAccess),
                  _buildBenefitRow(Icons.flash_on, 'Entrega rápida prioritaria', _hasPremiumAccess),
                  _buildBenefitRow(Icons.workspace_premium, 'Badge Premium en la cuenta', _hasPremiumAccess),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.24)),
            ),
            child: const Text(
              'Simulación académica: la tarjeta se valida localmente y no se almacena ni se procesa contra una pasarela real.',
              style: TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String label, bool enabled) {
    final color = enabled ? Colors.green.shade700 : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(enabled ? Icons.check_circle : icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseResult {
  final String cardType;
  final String last4;

  const _PurchaseResult({required this.cardType, required this.last4});
}

class _PremiumPaymentSheet extends StatefulWidget {
  final DatabaseService db;

  const _PremiumPaymentSheet({required this.db});

  @override
  State<_PremiumPaymentSheet> createState() => _PremiumPaymentSheetState();
}

class _PremiumPaymentSheetState extends State<_PremiumPaymentSheet> {
  final _paymentFormKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _processing = false;
  String _selectedCardType = 'Crédito';

  static String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String? _validateCardholder(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Ingresa el nombre del titular';
    }
    if (normalized.length < 4) {
      return 'Ingresa un nombre válido';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) {
      return 'Ingresa el número de tarjeta';
    }
    if (digits.length < 15 || digits.length > 16) {
      return 'La tarjeta debe tener 15 o 16 dígitos';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    final normalized = value?.trim() ?? '';
    final match = RegExp(r'^(\d{2})\/(\d{2})$').firstMatch(normalized);
    if (match == null) {
      return 'Usa el formato MM/AA';
    }

    final month = int.parse(match.group(1)!);
    final year = int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      return 'Mes inválido';
    }

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'La tarjeta está vencida';
    }

    return null;
  }

  String? _validateCvv(String? value) {
    final digits = _digitsOnly(value ?? '');
    if (digits.length < 3 || digits.length > 4) {
      return 'CVV inválido';
    }
    return null;
  }

  Future<void> _purchasePremium() async {
    final formState = _paymentFormKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final cardDigits = _digitsOnly(_cardNumberController.text);
    final last4 = cardDigits.substring(cardDigits.length - 4);

    setState(() {
      _processing = true;
    });

    try {
      await widget.db.setPremiumAccess(true);
      if (!mounted) return;

      Navigator.of(context).pop(
        _PurchaseResult(cardType: _selectedCardType, last4: last4),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo procesar la compra: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 520;

    final expiryField = TextFormField(
      controller: _expiryController,
      keyboardType: TextInputType.datetime,
      textInputAction: isCompact ? TextInputAction.next : TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: const InputDecoration(
        labelText: 'Vencimiento',
        hintText: 'MM/AA',
        border: OutlineInputBorder(),
      ),
      validator: _validateExpiry,
    );

    final cvvField = TextFormField(
      controller: _cvvController,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: const InputDecoration(
        labelText: 'CVV',
        border: OutlineInputBorder(),
      ),
      validator: _validateCvv,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _paymentFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completa una tarjeta de débito o crédito para aprobar la compra simulada del plan Premium.',
              style: TextStyle(height: 1.35),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCardType,
              decoration: const InputDecoration(
                labelText: 'Tipo de tarjeta',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Crédito', child: Text('Crédito')),
                DropdownMenuItem(value: 'Débito', child: Text('Débito')),
              ],
              onChanged: _processing
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCardType = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardholderController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Titular de la tarjeta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _validateCardholder,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: const InputDecoration(
                labelText: 'Número de tarjeta',
                hintText: '15 o 16 dígitos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              validator: _validateCardNumber,
            ),
            const SizedBox(height: 12),
            if (isCompact) ...[
              expiryField,
              const SizedBox(height: 12),
              cvvField,
            ] else
              Row(
                children: [
                  Expanded(child: expiryField),
                  const SizedBox(width: 12),
                  Expanded(child: cvvField),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pago simulado: no se guarda la tarjeta y la compra se aprueba localmente al validar los campos.',
                style: TextStyle(height: 1.3),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processing ? null : _purchasePremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _processing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_open),
                label: Text(
                  _processing ? 'Procesando compra...' : 'Comprar Premium',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final Color accentColor;
  final bool highlighted;
  final List<String> bullets;
  final String actionLabel;
  final VoidCallback? onPressed;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.accentColor,
    required this.highlighted,
    required this.bullets,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      child: Card(
        elevation: highlighted ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: highlighted ? accentColor : Colors.grey.shade300,
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final bullet in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(bullet)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}