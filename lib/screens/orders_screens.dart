import 'package:flutter/material.dart';

import '../catalogs.dart';
import '../core/app_theme.dart';
import '../models.dart';
import '../repositories.dart';
import '../widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.onDataChanged});
  final VoidCallback onDataChanged;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final repo = OrderRepository();
  final clientRepo = ClientRepository();
  late Future<List<CoutureOrder>> orders = repo.listAll();

  void reload() => setState(() => orders = repo.listAll());

  Future<void> addOrder() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const NewOrderScreen()));
    if (created == true && mounted) {
      reload();
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addOrder,
        backgroundColor: CoutelyaColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle commande'),
      ),
      body: FutureBuilder<List<CoutureOrder>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? const <CoutureOrder>[];
          if (rows.isEmpty) {
            return const EmptyState(icon: Icons.receipt_long_outlined, title: 'Aucune commande', subtitle: 'Créez une commande pour suivre la confection, les paiements et la livraison.');
          }
          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final order = rows[index];
                return FutureBuilder<Client?>(
                  future: clientRepo.getById(order.clientId),
                  builder: (context, clientSnapshot) {
                    final client = clientSnapshot.data;
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)));
                          if (mounted) reload();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(order.reference, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                              AppStatusChip(status: order.status),
                            ]),
                            const SizedBox(height: 8),
                            Text(order.garmentType, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(client?.fullName ?? 'Client', style: const TextStyle(color: CoutelyaColors.muted)),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.payments_outlined, size: 17, color: CoutelyaColors.green),
                              const SizedBox(width: 5),
                              Text(formatMoney(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800)),
                              const Spacer(),
                              const Icon(Icons.event_outlined, size: 17, color: CoutelyaColors.muted),
                              const SizedBox(width: 5),
                              Text(formatDate(order.deliveryDate), style: const TextStyle(color: CoutelyaColors.muted, fontSize: 12.5)),
                            ]),
                          ]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key, this.preselectedClientId});
  final String? preselectedClientId;

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final clientRepo = ClientRepository();
  final orderRepo = OrderRepository();
  final formKey = GlobalKey<FormState>();
  final garment = TextEditingController();
  final description = TextEditingController();
  final fabric = TextEditingController();
  final color = TextEditingController();
  final total = TextEditingController();
  final advance = TextEditingController();
  final notes = TextEditingController();
  late Future<List<Client>> clients = clientRepo.search();
  String? clientId;
  String? garmentChoice;
  String? fabricChoice;
  String? colorChoice;
  DateTime? fittingDate;
  DateTime? deliveryDate;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    clientId = widget.preselectedClientId;
  }

  @override
  void dispose() {
    for (final c in [garment, description, fabric, color, total, advance, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate({required bool fitting}) async {
    final initial = fitting ? (fittingDate ?? DateTime.now()) : (deliveryDate ?? DateTime.now().add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (fitting) {
        fittingDate = picked;
      } else {
        deliveryDate = picked;
      }
    });
  }

  void _selectCatalogValue(String? value, TextEditingController controller, void Function(String?) setChoice) {
    setState(() {
      setChoice(value);
      if (value == null || value == customCatalogOption) {
        controller.clear();
      } else {
        controller.text = value;
      }
    });
  }

  Widget _catalogField({
    required String label,
    required List<String> options,
    required String? choice,
    required TextEditingController controller,
    required void Function(String?) setChoice,
    bool required = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        initialValue: choice,
        decoration: InputDecoration(labelText: label),
        isExpanded: true,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => _selectCatalogValue(v, controller, setChoice),
        validator: required ? (v) => v == null ? 'Choisissez une option' : null : null,
      ),
      if (choice == customCatalogOption) ...[
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: '$label personnalisé'),
          validator: required ? (v) => v == null || v.trim().isEmpty ? 'Précisez votre choix' : null : null,
        ),
      ],
    ]);
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false) || clientId == null) {
      if (clientId == null && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionnez un client.')));
      return;
    }
    setState(() => saving = true);
    await orderRepo.create(
      clientId: clientId!,
      garmentType: garment.text,
      description: description.text,
      fabric: fabric.text,
      color: color.text,
      totalAmount: double.tryParse(total.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0,
      advance: double.tryParse(advance.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0,
      fittingDate: fittingDate,
      deliveryDate: deliveryDate,
      notes: notes.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            FutureBuilder<List<Client>>(
              future: clients,
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const <Client>[];
                return DropdownButtonFormField<String>(
                  initialValue: rows.any((c) => c.id == clientId) ? clientId : null,
                  decoration: const InputDecoration(labelText: 'Client'),
                  isExpanded: true,
                  items: rows.map((c) => DropdownMenuItem(value: c.id, child: Text(c.fullName, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => clientId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            _catalogField(
              label: 'Modèle / type de vêtement',
              options: garmentModels,
              choice: garmentChoice,
              controller: garment,
              setChoice: (v) => garmentChoice = v,
              required: true,
            ),
            const SizedBox(height: 12),
            TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / manches / détails')),
            const SizedBox(height: 12),
            _catalogField(label: 'Tissu', options: fabricTypes, choice: fabricChoice, controller: fabric, setChoice: (v) => fabricChoice = v),
            const SizedBox(height: 12),
            _catalogField(label: 'Couleur', options: fabricColors, choice: colorChoice, controller: color, setChoice: (v) => colorChoice = v),
            const SizedBox(height: 12),
            TextFormField(controller: total, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Prix total', suffixText: 'FCFA'), validator: (v) => (double.tryParse((v ?? '').replaceAll(' ', '').replaceAll(',', '.')) ?? 0) <= 0 ? 'Montant requis' : null),
            const SizedBox(height: 12),
            TextField(controller: advance, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Avance reçue', suffixText: 'FCFA')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _dateTile('Essayage prévu', fittingDate, () => pickDate(fitting: true))),
              const SizedBox(width: 10),
              Expanded(child: _dateTile('Livraison prévue', deliveryDate, () => pickDate(fitting: false))),
            ]),
            const SizedBox(height: 12),
            TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.arrow_forward_rounded), label: Text(saving ? 'Création...' : 'Créer la commande')),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? value, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: CoutelyaColors.border), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: CoutelyaColors.muted)),
            const SizedBox(height: 7),
            Row(children: [const Icon(Icons.event_outlined, size: 18, color: CoutelyaColors.purple), const SizedBox(width: 5), Expanded(child: Text(formatDate(value), style: const TextStyle(fontWeight: FontWeight.w800)))]),
          ]),
        ),
      );
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final orderRepo = OrderRepository();
  final clientRepo = ClientRepository();
  final paymentRepo = PaymentRepository();
  late Future<CoutureOrder?> order;

  @override
  void initState() {
    super.initState();
    order = orderRepo.getById(widget.orderId);
  }

  void reload() => setState(() => order = orderRepo.getById(widget.orderId));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoutureOrder?>(
      future: order,
      builder: (context, snapshot) {
        final o = snapshot.data;
        if (o == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return Scaffold(
          appBar: AppBar(title: const Text('Détail de commande')),
          body: FutureBuilder<Client?>(
            future: clientRepo.getById(o.clientId),
            builder: (context, clientSnapshot) {
              final c = clientSnapshot.data;
              return FutureBuilder<double>(
                future: paymentRepo.totalForOrder(o.id),
                builder: (context, paidSnapshot) {
                  final paid = paidSnapshot.data ?? 0;
                  final balance = (o.totalAmount - paid).clamp(0, double.infinity).toDouble();
                  return ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Row(children: [Expanded(child: Text(o.reference, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))), AppStatusChip(status: o.status)]),
                      const SizedBox(height: 18),
                      Card(child: Column(children: [
                        _detail('Client', c?.fullName ?? '—'),
                        const Divider(height: 1),
                        _detail('Modèle', o.garmentType),
                        const Divider(height: 1),
                        _detail('Description', o.description ?? '—'),
                        const Divider(height: 1),
                        _detail('Tissu', o.fabric ?? '—'),
                        const Divider(height: 1),
                        _detail('Couleur', o.color ?? '—'),
                      ])),
                      const SizedBox(height: 14),
                      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                        _money('Prix total', o.totalAmount, CoutelyaColors.ink),
                        const SizedBox(height: 10),
                        _money('Avance / payé', paid, CoutelyaColors.green),
                        const Divider(height: 22),
                        _money('Reste à payer', balance, balance > 0 ? CoutelyaColors.red : CoutelyaColors.green),
                      ]))),
                      const SizedBox(height: 14),
                      Card(child: Column(children: [
                        _detail('Date de commande', formatDate(o.orderDate)),
                        const Divider(height: 1),
                        _detail('Essayage prévu', formatDate(o.fittingDate)),
                        const Divider(height: 1),
                        _detail('Livraison prévue', formatDate(o.deliveryDate)),
                      ])),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductionTrackingScreen(order: o)));
                          if (mounted) reload();
                        },
                        icon: const Icon(Icons.timeline_rounded),
                        label: const Text('Suivre la confection'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentsScreen(order: o)));
                          if (mounted) reload();
                        },
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Paiements'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 130, child: Text(label, style: const TextStyle(color: CoutelyaColors.muted, fontSize: 12))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)))]),
      );

  Widget _money(String label, double value, Color color) => Row(children: [Expanded(child: Text(label, style: const TextStyle(color: CoutelyaColors.muted))), Text(formatMoney(value), style: TextStyle(fontWeight: FontWeight.w900, color: color))]);
}

class ProductionTrackingScreen extends StatefulWidget {
  const ProductionTrackingScreen({super.key, required this.order});
  final CoutureOrder order;

  @override
  State<ProductionTrackingScreen> createState() => _ProductionTrackingScreenState();
}

class _ProductionTrackingScreenState extends State<ProductionTrackingScreen> {
  final repo = OrderRepository();
  static const statuses = ['registered', 'cutting', 'sewing', 'fitting', 'finishing', 'ready', 'delivered'];
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.order.status;
  }

  Future<void> changeStatus() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: statuses.map((s) => ListTile(leading: Icon(Icons.circle, color: statusColor(s), size: 18), title: Text(statusLabel(s)), trailing: status == s ? const Icon(Icons.check_rounded, color: CoutelyaColors.green) : null, onTap: () => Navigator.pop(context, s))).toList(),
        ),
      ),
    );
    if (selected == null) return;
    await repo.updateStatus(widget.order.id, selected);
    if (mounted) setState(() => status = selected);
  }

  @override
  Widget build(BuildContext context) {
    final current = statuses.indexOf(status);
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de confection')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.order.reference, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          ...List.generate(statuses.length, (i) {
            final s = statuses[i];
            final done = i <= current;
            final active = i == current;
            final color = done ? statusColor(s) : const Color(0xFFC9C3CC);
            return IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(width: 38, child: Column(children: [
                  Container(width: active ? 24 : 20, height: active ? 24 : 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: active ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8)] : null), child: done ? const Icon(Icons.check, color: Colors.white, size: 12) : null),
                  if (i < statuses.length - 1) Expanded(child: Container(width: 3, color: done && i < current ? statusColor(statuses[i + 1]) : const Color(0xFFE0DCE2))),
                ])),
                const SizedBox(width: 10),
                Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 23), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(statusLabel(s), style: TextStyle(fontWeight: FontWeight.w900, color: done ? CoutelyaColors.ink : CoutelyaColors.muted)),
                  const SizedBox(height: 4),
                  Text(active ? 'Étape actuelle' : done ? 'Terminée' : 'En attente', style: TextStyle(color: active ? CoutelyaColors.purple : CoutelyaColors.muted, fontSize: 12)),
                ]))),
              ]),
            );
          }),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: changeStatus, icon: const Icon(Icons.swap_vert_rounded), label: const Text('Changer le statut')),
        ],
      ),
    );
  }
}

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.order});
  final CoutureOrder order;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final repo = PaymentRepository();
  late Future<List<Payment>> payments;
  final amount = TextEditingController();
  String method = 'cash';

  @override
  void initState() {
    super.initState();
    payments = repo.forOrder(widget.order.id);
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  void reload() => setState(() => payments = repo.forOrder(widget.order.id));

  Future<void> addPayment() async {
    amount.clear();
    method = 'cash';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nouveau paiement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Montant', suffixText: 'FCFA')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Mode de paiement'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Espèces')),
                DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Virement')),
                DropdownMenuItem(value: 'other', child: Text('Autre')),
              ],
              onChanged: (v) => setSheetState(() => method = v ?? 'cash'),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(amount.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
                if (value <= 0) return;
                await repo.add(orderId: widget.order.id, amount: value, method: method);
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Enregistrer le paiement'),
            ),
          ]),
        ),
      ),
    );
    if (ok == true && mounted) reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: FutureBuilder<List<Payment>>(
        future: payments,
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Payment>[];
          final paid = rows.fold<double>(0, (sum, p) => sum + p.amount);
          final remaining = (widget.order.totalAmount - paid).clamp(0, double.infinity).toDouble();
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(widget.order.reference, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 14),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                _row('Total', widget.order.totalAmount, CoutelyaColors.ink),
                const SizedBox(height: 10),
                _row('Déjà payé', paid, CoutelyaColors.green),
                const Divider(height: 24),
                _row('Reste à payer', remaining, remaining > 0 ? CoutelyaColors.red : CoutelyaColors.green),
              ]))),
              const SizedBox(height: 14),
              FilledButton.icon(onPressed: addPayment, icon: const Icon(Icons.add_rounded), label: const Text('Nouveau paiement')),
              const SizedBox(height: 20),
              const SectionTitle('Historique des paiements'),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Aucun paiement enregistré.', style: TextStyle(color: CoutelyaColors.muted))))
              else
                ...rows.map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(child: ListTile(leading: const Icon(Icons.payments_rounded, color: CoutelyaColors.green), title: Text(formatMoney(p.amount), style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${_method(p.method)} • ${formatDate(p.paidAt)}'))))),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, double value, Color color) => Row(children: [Expanded(child: Text(label, style: const TextStyle(color: CoutelyaColors.muted))), Text(formatMoney(value), style: TextStyle(fontWeight: FontWeight.w900, color: color))]);

  String _method(String m) {
    switch (m) {
      case 'mobile_money': return 'Mobile Money';
      case 'bank_transfer': return 'Virement';
      case 'other': return 'Autre';
      default: return 'Espèces';
    }
  }
}
