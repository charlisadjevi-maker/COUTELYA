import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models.dart';
import '../repositories.dart';
import '../widgets.dart';
import 'expenses_screen.dart';
import 'more_screens.dart';
import 'orders_screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onDataChanged, required this.onNavigate});
  final VoidCallback onDataChanged;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final repo = OrderRepository();
  final expenseRepo = ExpenseRepository();
  late Future<DashboardStats> stats = repo.stats();
  late Future<double> expenses = expenseRepo.total();

  void reload() => setState(() { stats = repo.stats(); expenses = expenseRepo.total(); });

  Future<void> newOrder() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const NewOrderScreen()));
    if (created == true && mounted) { reload(); widget.onDataChanged(); }
  }

  Future<void> _openCategory(OrderCategory category) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderCategoryScreen(category: category)));
    if (mounted) reload();
  }

  Future<void> _openLya() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LyaScreen()));
    if (mounted) reload();
  }

  Future<void> _openExpenses() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpensesScreen()));
    if (mounted) reload();
  }

  Widget metric({required VoidCallback onTap, required String value, required String label, required IconData icon, required Color background}) => Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: MetricCard(value: value, label: label, icon: icon, background: background)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bonjour 👋', style: TextStyle(color: CoutelyaColors.muted, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Atelier Élégance', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))])),
                Container(width: 42, height: 42, decoration: const BoxDecoration(color: CoutelyaColors.purpleSoft, shape: BoxShape.circle), child: const Icon(Icons.notifications_none_rounded, color: CoutelyaColors.purple)),
              ]),
              const SizedBox(height: 24),
              const Text('Aperçu de votre activité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text('Touchez une carte pour ouvrir la liste correspondant exactement à son intitulé.', style: TextStyle(color: CoutelyaColors.muted, fontSize: 12)),
              const SizedBox(height: 12),
              FutureBuilder<DashboardStats>(
                future: stats,
                builder: (context, snapshot) {
                  final s = snapshot.data ?? const DashboardStats(inProgress: 0, ready: 0, delivered: 0, late: 0, received: 0, receivable: 0);
                  return Column(children: [
                    Row(children: [metric(onTap: () => widget.onNavigate(2), value: '${s.inProgress}', label: 'Commandes\nen cours', icon: Icons.checkroom_rounded, background: CoutelyaColors.purple), const SizedBox(width: 12), metric(onTap: () => _openCategory(OrderCategory.ready), value: '${s.ready}', label: 'Prêtes à\nlivrer', icon: Icons.inventory_2_outlined, background: CoutelyaColors.gold)]),
                    const SizedBox(height: 12),
                    Row(children: [metric(onTap: () => _openCategory(OrderCategory.delivered), value: '${s.delivered}', label: 'Commandes\nlivrées', icon: Icons.local_shipping_outlined, background: CoutelyaColors.green), const SizedBox(width: 12), metric(onTap: () => _openCategory(OrderCategory.late), value: '${s.late}', label: 'Commandes\nen retard', icon: Icons.warning_amber_rounded, background: CoutelyaColors.red)]),
                    const SizedBox(height: 20),
                    const SectionTitle('Finances'),
                    const SizedBox(height: 10),
                    Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: _finance('Avances reçues', formatMoney(s.received), CoutelyaColors.green)), Container(width: 1, height: 54, color: CoutelyaColors.border), const SizedBox(width: 14), Expanded(child: _finance('Reste à encaisser', formatMoney(s.receivable), CoutelyaColors.ink))]))),
                    const SizedBox(height: 10),
                    FutureBuilder<double>(
                      future: expenses,
                      builder: (context, expenseSnapshot) {
                        final totalExpenses = expenseSnapshot.data ?? 0;
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _openExpenses,
                            child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 42, height: 42, decoration: const BoxDecoration(color: CoutelyaColors.redSoft, shape: BoxShape.circle), child: const Icon(Icons.trending_down_rounded, color: CoutelyaColors.red)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Dépenses de l’atelier', style: TextStyle(color: CoutelyaColors.muted, fontSize: 12)), const SizedBox(height: 4), Text(formatMoney(totalExpenses), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))])), const Icon(Icons.chevron_right_rounded, color: CoutelyaColors.purple)])),
                          ),
                        );
                      },
                    ),
                  ]);
                },
              ),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: newOrder, icon: const Icon(Icons.add_rounded), label: const Text('Nouvelle commande')),
              const SizedBox(height: 20),
              Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: _openLya, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 48, height: 48, decoration: const BoxDecoration(color: CoutelyaColors.purpleSoft, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: CoutelyaColors.purple)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Lya', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 3), Text('Consultez vos commandes, retards, paiements, livraisons et clients.', style: TextStyle(color: CoutelyaColors.muted, height: 1.3))])), const Icon(Icons.chevron_right_rounded, color: CoutelyaColors.purple)])))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _finance(String label, String value, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: CoutelyaColors.muted, fontSize: 12)), const SizedBox(height: 7), Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15))]);
}
