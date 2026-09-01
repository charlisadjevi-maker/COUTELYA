import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models.dart';
import '../repositories.dart';
import '../widgets.dart';
import 'orders_screens.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, required this.onDataChanged});
  final VoidCallback onDataChanged;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final repo = ClientRepository();
  final searchController = TextEditingController();
  late Future<List<Client>> clients = repo.search();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void search(String value) => setState(() => clients = repo.search(value));

  Future<void> addClient() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ClientFormScreen()));
    if (created == true && mounted) {
      search(searchController.text);
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [IconButton(onPressed: () => search(searchController.text), icon: const Icon(Icons.refresh_rounded))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addClient,
        backgroundColor: CoutelyaColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nouveau client'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(children: [
          TextField(controller: searchController, onChanged: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Rechercher un client')),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: clients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final rows = snapshot.data ?? const <Client>[];
                if (rows.isEmpty) {
                  return const EmptyState(icon: Icons.people_outline, title: 'Aucun client', subtitle: 'Ajoutez votre premier client pour commencer à gérer ses mesures et commandes.');
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final client = rows[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: CoutelyaColors.purpleSoft,
                          foregroundColor: CoutelyaColors.purple,
                          child: Text(client.fullName.isEmpty ? '?' : client.fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        title: Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(client.phone?.isNotEmpty == true ? client.phone! : 'Sans téléphone', style: const TextStyle(color: CoutelyaColors.muted))),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: client.id)));
                          if (mounted) search(searchController.text);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key, this.client});
  final Client? client;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final repo = ClientRepository();
  final formKey = GlobalKey<FormState>();
  late final TextEditingController first;
  late final TextEditingController last;
  late final TextEditingController phone;
  late final TextEditingController whatsapp;
  late final TextEditingController email;
  late final TextEditingController address;
  late final TextEditingController notes;
  String gender = 'Femme';
  bool saving = false;

  @override
  void initState() {
    super.initState();
    first = TextEditingController(text: widget.client?.firstName ?? '');
    last = TextEditingController(text: widget.client?.lastName ?? '');
    phone = TextEditingController(text: widget.client?.phone ?? '');
    whatsapp = TextEditingController(text: widget.client?.whatsapp ?? '');
    email = TextEditingController(text: widget.client?.email ?? '');
    address = TextEditingController(text: widget.client?.address ?? '');
    notes = TextEditingController(text: widget.client?.notes ?? '');
    if (widget.client?.gender?.isNotEmpty == true) gender = widget.client!.gender!;
  }

  @override
  void dispose() {
    for (final c in [first, last, phone, whatsapp, email, address, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    await repo.save(
      id: widget.client?.id,
      firstName: first.text,
      lastName: last.text,
      phone: phone.text,
      whatsapp: whatsapp.text,
      email: email.text,
      gender: gender,
      address: address.text,
      notes: notes.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Nouveau client' : 'Modifier le client')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(children: [Expanded(child: _field(first, 'Prénom', required: true)), const SizedBox(width: 10), Expanded(child: _field(last, 'Nom', required: true))]),
            const SizedBox(height: 12),
            _field(phone, 'Téléphone', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _field(whatsapp, 'WhatsApp', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _field(email, 'E-mail', keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(labelText: 'Type de client'),
              items: const ['Femme', 'Homme', 'Enfant'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => gender = v ?? gender),
            ),
            const SizedBox(height: 12),
            _field(address, 'Adresse'),
            const SizedBox(height: 12),
            _field(notes, 'Notes', maxLines: 3),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save_outlined), label: Text(saving ? 'Enregistrement...' : 'Enregistrer')),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null : null,
    );
  }
}

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key, required this.clientId});
  final String clientId;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final clientRepo = ClientRepository();
  final measurementRepo = MeasurementRepository();
  final orderRepo = OrderRepository();
  final paymentRepo = PaymentRepository();
  late Future<Client?> client;

  @override
  void initState() {
    super.initState();
    client = clientRepo.getById(widget.clientId);
  }

  void reload() => setState(() => client = clientRepo.getById(widget.clientId));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Client?>(
      future: client,
      builder: (context, snapshot) {
        final c = snapshot.data;
        if (c == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(c.fullName),
              actions: [
                IconButton(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ClientFormScreen(client: c)));
                    if (updated == true && mounted) reload();
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: [Tab(text: 'Infos'), Tab(text: 'Mesures'), Tab(text: 'Commandes'), Tab(text: 'Paiements')],
              ),
            ),
            body: TabBarView(children: [_info(c), _measurements(c), _orders(c), _payments(c)]),
          ),
        );
      },
    );
  }

  Widget _info(Client c) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(child: CircleAvatar(radius: 42, backgroundColor: CoutelyaColors.purpleSoft, foregroundColor: CoutelyaColors.purple, child: Text(c.fullName.isEmpty ? '?' : c.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)))),
          const SizedBox(height: 18),
          Center(child: Text(c.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            _line(Icons.phone_outlined, 'Téléphone', c.phone),
            const Divider(height: 1),
            _line(Icons.chat_outlined, 'WhatsApp', c.whatsapp),
            const Divider(height: 1),
            _line(Icons.mail_outline, 'E-mail', c.email),
            const Divider(height: 1),
            _line(Icons.location_on_outlined, 'Adresse', c.address),
            const Divider(height: 1),
            _line(Icons.notes_rounded, 'Notes', c.notes),
          ])),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewOrderScreen(preselectedClientId: c.id))),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nouvelle commande'),
          ),
        ],
      );

  Widget _line(IconData icon, String label, String? value) => Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: CoutelyaColors.purple, size: 21),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: CoutelyaColors.muted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value?.trim().isNotEmpty == true ? value! : '—', style: const TextStyle(fontWeight: FontWeight.w700)),
          ])),
        ]),
      );

  Widget _measurements(Client c) => FutureBuilder<Measurement?>(
        future: measurementRepo.latestForClient(c.id),
        builder: (context, snapshot) {
          final m = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (m == null)
                const EmptyState(icon: Icons.straighten_rounded, title: 'Aucune mesure', subtitle: 'Enregistrez les mesures de ce client pour les réutiliser dans ses commandes.')
              else ...[
                Row(children: [Text(m.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), Text(formatDate(m.takenAt), style: const TextStyle(color: CoutelyaColors.muted))]),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: m.values.entries.where((e) => e.value != null).map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: Row(children: [
                        Expanded(child: Text(_measurementLabel(e.key))),
                        Text('${e.value!.toStringAsFixed(e.value! % 1 == 0 ? 0 : 1)} cm', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ]),
                    )).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => MeasurementsScreen(client: c, existing: m)));
                  if (ok == true && mounted) setState(() {});
                },
                icon: const Icon(Icons.straighten_rounded),
                label: Text(m == null ? 'Saisir les mesures' : 'Mettre à jour les mesures'),
              ),
            ],
          );
        },
      );

  Widget _orders(Client c) => FutureBuilder<List<CoutureOrder>>(
        future: orderRepo.forClient(c.id),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <CoutureOrder>[];
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (rows.isEmpty) return ListView(padding: const EdgeInsets.all(18), children: [const EmptyState(icon: Icons.receipt_long_outlined, title: 'Aucune commande', subtitle: 'Les commandes de ce client apparaîtront ici.'), const SizedBox(height: 16), FilledButton.icon(onPressed: () async { final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => NewOrderScreen(preselectedClientId: c.id))); if (ok == true && mounted) setState(() {}); }, icon: const Icon(Icons.add_rounded), label: const Text('Créer une commande pour ce client'))]);
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final o = rows[i];
              return Card(child: ListTile(title: Text(o.reference, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(o.garmentType), trailing: AppStatusChip(status: o.status), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)))));
            },
          );
        },
      );

  Widget _payments(Client c) => FutureBuilder<List<Map<String, Object?>>>(
        future: paymentRepo.forClient(c.id),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Map<String, Object?>>[];
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (rows.isEmpty) return const EmptyState(icon: Icons.payments_outlined, title: 'Aucun paiement', subtitle: 'Les paiements associés aux commandes de ce client apparaîtront ici.');
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final row = rows[i];
              return Card(child: ListTile(leading: const Icon(Icons.payments_rounded, color: CoutelyaColors.green), title: Text(formatMoney((row['amount'] as num?)?.toDouble() ?? 0), style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${row['reference'] ?? ''} • ${formatDate(DateTime.tryParse((row['paid_at'] as String?) ?? ''))}')));
            },
          );
        },
      );

  String _measurementLabel(String key) {
    if (key.startsWith('custom:')) return key.substring(7);
    const labels = {
      'bust': 'Tour de poitrine',
      'waist': 'Tour de taille',
      'hips': 'Tour de hanches',
      'back': 'Longueur dos',
      'shoulder': 'Longueur épaule',
      'sleeve': 'Longueur manche',
      'neck': 'Tour de cou',
      'inseam': 'Entrejambe',
      'thigh': 'Tour de cuisse',
    };
    return labels[key] ?? key;
  }
}

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key, required this.client, this.existing});
  final Client client;
  final Measurement? existing;

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final repo = MeasurementRepository();
  late String category;
  late final Map<String, TextEditingController> fields;
  final notes = TextEditingController();

  static const standardLabels = <String, String>{
    'bust': 'Tour de poitrine',
    'waist': 'Tour de taille',
    'hips': 'Tour de hanches',
    'back': 'Longueur dos',
    'shoulder': 'Longueur épaule',
    'sleeve': 'Longueur manche',
    'neck': 'Tour de cou',
    'inseam': 'Entrejambe',
    'thigh': 'Tour de cuisse',
  };

  String _v(String key) {
    final v = widget.existing?.values[key];
    return v == null ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
  }

  @override
  void initState() {
    super.initState();
    category = widget.existing?.category ?? (widget.client.gender ?? 'Femme');
    fields = {
      for (final key in standardLabels.keys) key: TextEditingController(text: _v(key)),
    };
    for (final entry in widget.existing?.values.entries ?? const <MapEntry<String, double?>>[]) {
      if (!standardLabels.containsKey(entry.key)) {
        fields[entry.key] = TextEditingController(text: entry.value == null ? '' : entry.value!.toStringAsFixed(entry.value! % 1 == 0 ? 0 : 1));
      }
    }
    notes.text = widget.existing?.notes ?? '';
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    notes.dispose();
    super.dispose();
  }

  String _labelFor(String key) => key.startsWith('custom:') ? key.substring(7) : (standardLabels[key] ?? key);

  Future<void> _addCustomMeasurement() async {
    final name = TextEditingController();
    final value = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une mesure personnalisée'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Nom de la mesure', hintText: 'Ex. Longueur tunique')),
          const SizedBox(height: 12),
          TextField(controller: value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valeur', suffixText: 'cm')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(context, {'name': name.text.trim(), 'value': value.text.trim()});
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    name.dispose();
    value.dispose();
    if (result == null) return;
    var key = 'custom:${result['name']}';
    var suffix = 2;
    while (fields.containsKey(key)) {
      key = 'custom:${result['name']} ($suffix)';
      suffix++;
    }
    setState(() => fields[key] = TextEditingController(text: result['value'] ?? ''));
  }

  void _removeCustomMeasurement(String key) {
    final controller = fields.remove(key);
    controller?.dispose();
    setState(() {});
  }

  Future<void> save() async {
    final values = fields.map((key, controller) => MapEntry(key, double.tryParse(controller.text.replaceAll(',', '.'))));
    await repo.save(clientId: widget.client.id, category: category, values: values, notes: notes.text);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesures')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.client.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Femme', 'Homme', 'Enfant'].map((e) => ChoiceChip(label: Text(e), selected: category == e, onSelected: (_) => setState(() => category = e))).toList(),
          ),
          const SizedBox(height: 18),
          ...fields.entries.map((e) {
            final custom = e.key.startsWith('custom:');
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(children: [
                Expanded(child: TextField(controller: e.value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _labelFor(e.key), suffixText: 'cm'))),
                if (custom) ...[
                  const SizedBox(width: 6),
                  IconButton(tooltip: 'Supprimer cette mesure', onPressed: () => _removeCustomMeasurement(e.key), icon: const Icon(Icons.delete_outline_rounded, color: CoutelyaColors.red)),
                ],
              ]),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addCustomMeasurement,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une mesure personnalisée'),
          ),
          const SizedBox(height: 12),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: save, icon: const Icon(Icons.save_outlined), label: const Text('Enregistrer les mesures')),
        ],
      ),
    );
  }
}
