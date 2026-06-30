import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalDocumentScreen(
      title: 'Términos de uso',
      icon: Icons.description_outlined,
      intro:
          'Al crear una cuenta o usar FoodFinder aceptas estas condiciones básicas de uso de la plataforma.',
      sections: const [
        _LegalSection(
          title: 'Uso permitido',
          items: [
            'La aplicación debe usarse para explorar restaurantes, gestionar pedidos y administrar tu cuenta.',
            'No está permitido intentar alterar datos, suplantar identidades o abusar de funciones administrativas.',
          ],
        ),
        _LegalSection(
          title: 'Cuenta y seguridad',
          items: [
            'Eres responsable de mantener tu email y contraseña actualizados y bajo control.',
            'La información que registres debe ser veraz para poder operar correctamente con pedidos y soporte.',
          ],
        ),
        _LegalSection(
          title: 'Pedidos y disponibilidad',
          items: [
            'Las funciones premium, la publicidad y las promociones pueden variar según la versión de la app.',
            'Los datos mostrados en esta demo pueden ser simulados con fines académicos o de evaluación.',
          ],
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalDocumentScreen(
      title: 'Política de privacidad',
      icon: Icons.privacy_tip_outlined,
      intro:
          'FoodFinder trata datos de registro, sesión y pedidos con un enfoque alineado a la LGPD para transparencia, acceso y eliminación.',
      sections: const [
        _LegalSection(
          title: 'Datos que usamos',
          items: [
            'Nombre, email, teléfono y rol de usuario para acceso y personalización básica.',
            'Historial de pedidos y estado de sesión almacenados localmente en el dispositivo o en memoria web.',
          ],
        ),
        _LegalSection(
          title: 'Finalidad del tratamiento',
          items: [
            'Permitir inicio de sesión, registro, historial de pedidos y administración interna de usuarios.',
            'Mostrar contenido adaptado al plan gratuito o premium y simular estrategias de monetización.',
          ],
        ),
        _LegalSection(
          title: 'Tus derechos',
          items: [
            'Puedes consultar esta política antes de registrarte y volver a verla desde tu perfil.',
            'Puedes solicitar la eliminación de tu cuenta desde la propia aplicación, borrando tus datos locales asociados.',
          ],
        ),
      ],
    );
  }
}

class _LegalDocumentScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<_LegalSection> sections;

  const _LegalDocumentScreen({
    required this.title,
    required this.icon,
    required this.intro,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orange.shade700],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 34),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  intro,
                  style: const TextStyle(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final section in sections)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final item in section.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 7),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(item, style: const TextStyle(height: 1.35)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final List<String> items;

  const _LegalSection({required this.title, required this.items});
}