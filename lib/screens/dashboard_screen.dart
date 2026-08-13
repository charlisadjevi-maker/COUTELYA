import 'package:flutter/material.dart';

import '../repositories/client_repository.dart';
import '../repositories/order_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final clients = ClientRepository();
  final orders = OrderRepository();

  late Future<Map<String, int>> stats = _load();

  Future<Map<String, int>> _load() async => {
        'clients': await clients.count(),
        'orders': await orders.countOpen(),
        'ready': await orders.countByStatus('ready'),
        'late': await orders.countOverdue(),
      };

  Future<void> _refresh() async {
    setState(() => stats = _load());
    await stats;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'COUTELYA',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Text('Votre atelier, simplement.'),
          const SizedBox(height: 22),
          FutureBuilder<Map<String, int>>(
            future: stats,
            builder: (context, snapshot) {
              final data = snapshot.data ??
                  const {'clients': 0, 'orders': 0, 'ready': 0, 'late': 0};

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    label: 'Clients',
                    value: data['clients']!,
                    icon: Icons.people,
                  ),
                  _StatCard(
                    label: 'Commandes en cours',
                    value: data['orders']!,
                    icon: Icons.checkroom,
                  ),
                  _StatCard(
                    label: 'Prêtes',
                    value: data['ready']!,
                    icon: Icons.task_alt,
                  ),
                  _StatCard(
                    label: 'En retard',
                    value: data['late']!,
                    icon: Icons.warning_amber,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(child: Text('L')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lya vous accompagne pour organiser vos clients, '
                      'mesures, commandes, paiements et livraisons.',
                      style: Theme.of(context).textTheme.bodyLarge,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
