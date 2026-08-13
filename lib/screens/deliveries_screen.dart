import 'package:flutter/material.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livraisons')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _DeliverySection(
            title: "Aujourd'hui",
            icon: Icons.today,
            text: 'Les commandes prévues pour aujourd’hui apparaîtront ici.',
          ),
          _DeliverySection(
            title: 'Prochainement',
            icon: Icons.event,
            text: 'Les prochaines échéances seront regroupées ici.',
          ),
          _DeliverySection(
            title: 'En retard',
            icon: Icons.warning_amber,
            text: 'Les commandes dépassant leur date prévue seront signalées.',
          ),
        ],
      ),
    );
  }
}

class _DeliverySection extends StatelessWidget {
  const _DeliverySection({
    required this.title,
    required this.icon,
    required this.text,
  });

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
