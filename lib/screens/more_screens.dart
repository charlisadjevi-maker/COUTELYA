import 'package:flutter/material.dart';

import '../catalogs.dart';
import '../core/app_theme.dart';
import '../models.dart';
import '../repositories.dart';
import '../widgets.dart';
import 'auth_screens.dart';
import 'orders_screens.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key, required this.onDataChanged});
  final VoidCallback onDataChanged;

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  final repo = OrderRepository();
  final clientRepo = ClientRepository();
  late Future<List<CoutureOrder>> orders = repo.deliveries();

  void reload() => setState(() => orders = repo.deliveries());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livraisons')),
      body: FutureBuilder<List<CoutureOrder>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? const <CoutureOrder>[];
          if (rows.isEmpty) {
            return const EmptyState(icon: Icons.local_shipping_outlined, title: 'Aucune livraison en attente', subtitle: 'Les commandes avec une date de livraison apparaîtront ici.');
          }
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);
          final tomorrow = todayStart.add(const Duration(days: 1));
          final late = rows.where((o) => o.deliveryDate != null && o.deliveryDate!.isBefore(todayStart)).toList();
          final dueToday = rows.where((o) => o.deliveryDate != null && !o.deliveryDate!.isBefore(todayStart) && o.deliveryDate!.isBefore(tomorrow)).toList();
          final upcoming = rows.where((o) => o.deliveryDate != null && !o.deliveryDate!.isBefore(tomorrow)).toList();
          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                if (dueToday.isNotEmpty) ...[_section('À livrer aujourd’hui', dueToday, CoutelyaColors.gold), const SizedBox(height: 18)],
                if (upcoming.isNotEmpty) ...[_section('Prochainement', upcoming, CoutelyaColors.purple), const SizedBox(height: 18)],
                if (late.isNotEmpty) _section('En retard', late, CoutelyaColors.red),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(String title, List<CoutureOrder> rows, Color accent) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(width: 5, height: 20, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8))), const SizedBox(width: 8), Text('$title (${rows.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))]),
          const SizedBox(height: 10),
          ...rows.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FutureBuilder<Client?>(
                  future: clientRepo.getById(o.clientId),
                  builder: (context, snap) {
                    final c = snap.data;
                    return Card(
                      child: ListTile(
                        title: Text(o.reference, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('${c?.fullName ?? 'Client'}\n${o.garmentType} • ${formatDate(o.deliveryDate)}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delivered') {
                              await repo.updateStatus(o.id, 'delivered');
                              if (mounted) {
                                reload();
                                widget.onDataChanged();
                              }
                            } else if (value == 'open' && mounted) {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)));
                              if (mounted) reload();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'open', child: Text('Voir la commande')),
                            PopupMenuItem(value: 'delivered', child: Text('Marquer comme livrée')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
        ],
      );
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [CircleAvatar(radius: 28, backgroundColor: CoutelyaColors.purpleSoft, child: Icon(Icons.storefront_rounded, color: CoutelyaColors.purple)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Atelier Élégance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), SizedBox(height: 3), Text('COUTELYA Pro • Mode local', style: TextStyle(color: CoutelyaColors.muted))]))]),
            ),
          ),
          const SizedBox(height: 16),
          _tile(context, Icons.auto_awesome_rounded, 'Assistante Lya', 'Résumé intelligent de votre atelier', const LyaScreen()),
          _tile(context, Icons.workspace_premium_outlined, 'Abonnements', 'Gratuit, Pro et Atelier', const SubscriptionsScreen()),
          _tile(context, Icons.storefront_outlined, 'Profil de l’atelier', 'Coordonnées et informations', const WorkshopProfileScreen()),
          _tile(context, Icons.settings_outlined, 'Paramètres', 'Langue, sécurité et préférences', const SettingsScreen()),
          _tile(context, Icons.wifi_off_rounded, 'Mode hors connexion', 'Données locales et synchronisation', const OfflineModeScreen()),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(foregroundColor: CoutelyaColors.red, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('COUTELYA V0.2.3', style: TextStyle(color: CoutelyaColors.muted, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, Widget screen) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: ListTile(
            leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: CoutelyaColors.purpleSoft, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: CoutelyaColors.purple)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
          ),
        ),
      );
}

class LyaScreen extends StatefulWidget {
  const LyaScreen({super.key});

  @override
  State<LyaScreen> createState() => _LyaScreenState();
}

class _LyaScreenState extends State<LyaScreen> {
  final orderRepo = OrderRepository();
  final clientRepo = ClientRepository();
  final input = TextEditingController();
  final scrollController = ScrollController();
  final List<_ChatLine> lines = const [
    _ChatLine(false, 'Bonjour 👋 Je suis Lya, votre assistante COUTELYA.'),
    _ChatLine(
      false,
      'Je peux vous donner un résumé de l’atelier, compter les clients, repérer les retards, les commandes prêtes ou livrées et suivre les montants à encaisser.',
    ),
  ].toList();

  static const quickQuestions = <String>[
    'Résumé de l’atelier',
    'Commandes en retard',
    'Commandes prêtes',
    'Commandes livrées',
    'Reste à encaisser',
    'Nombre de clients',
  ];

  @override
  void dispose() {
    input.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> ask(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    setState(() {
      lines.add(_ChatLine(true, cleaned));
      input.clear();
    });
    await _scrollToBottom();

    final stats = await orderRepo.stats();
    final clients = await clientRepo.search();
    final orders = await orderRepo.listAll();
    final lower = cleaned.toLowerCase();
    final readyOrders = orders.where((o) => o.status == 'ready').toList();
    final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();

    String reply;
    if (lower.contains('client')) {
      reply = 'Vous avez ${clients.length} client(s) enregistré(s) dans COUTELYA.';
    } else if (lower.contains('retard')) {
      reply = stats.late == 0
          ? 'Bonne nouvelle : aucune commande n’est actuellement en retard.'
          : '${stats.late} commande(s) sont en retard. Ouvrez la carte « Commandes en retard » sur l’accueil pour voir uniquement ces dossiers.';
    } else if (lower.contains('prêt') || lower.contains('prete') || lower.contains('prête')) {
      reply = readyOrders.isEmpty
          ? 'Aucune commande n’est actuellement prête à livrer.'
          : '${readyOrders.length} commande(s) sont prêtes à livrer. Vous pouvez ouvrir la liste dédiée depuis l’accueil.';
    } else if (lower.contains('livré') || lower.contains('livree') || lower.contains('livrée')) {
      reply = '${deliveredOrders.length} commande(s) sont enregistrées comme livrées.';
    } else if (lower.contains('encaisser') || lower.contains('reste') || lower.contains('argent') || lower.contains('paiement')) {
      reply = 'Le total encaissé est de ${formatMoney(stats.received)} et il reste ${formatMoney(stats.receivable)} à encaisser.';
    } else if (lower.contains('cours')) {
      reply = '${stats.inProgress} commande(s) sont actuellement en cours de confection.';
    } else if (lower.contains('résum') || lower.contains('resume') || lower.contains('atelier')) {
      reply = 'Résumé de l’atelier : ${clients.length} client(s), ${stats.inProgress} commande(s) en cours, ${stats.ready} prête(s) à livrer, ${stats.delivered} livrée(s), ${stats.late} en retard, ${formatMoney(stats.receivable)} restant à encaisser.';
    } else {
      reply = 'Je peux répondre sur les clients, les commandes en cours, les commandes prêtes, les livraisons, les retards et les paiements. Essayez l’un des raccourcis proposés ci-dessus.';
    }

    if (mounted) {
      setState(() => lines.add(_ChatLine(false, reply)));
      await _scrollToBottom();
    }
  }

  Future<void> send() => ask(input.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: CoutelyaColors.purple,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            SizedBox(width: 9),
            Text('Lya'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: CoutelyaColors.border),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: quickQuestions
                    .map(
                      (question) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ActionChip(
                          avatar: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: CoutelyaColors.purple,
                          ),
                          label: Text(question),
                          onPressed: () => ask(question),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: lines.length,
              itemBuilder: (context, i) {
                final line = lines[i];
                return Align(
                  alignment:
                      line.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .82,
                    ),
                    decoration: BoxDecoration(
                      color: line.user
                          ? CoutelyaColors.purple
                          : CoutelyaColors.purpleSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      line.text,
                      style: TextStyle(
                        color: line.user ? Colors.white : CoutelyaColors.ink,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      onSubmitted: (_) => send(),
                      decoration: const InputDecoration(
                        hintText: 'Posez une question sur votre atelier',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: send,
                    icon: const Icon(Icons.arrow_upward_rounded),
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

class _ChatLine {
  const _ChatLine(this.user, this.text);
  final bool user;
  final String text;
}

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abonnements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choisissez votre offre', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _plan('Gratuit', '0 FCFA / mois', CoutelyaColors.purple, ['Jusqu’à 100 clients', 'Mesures illimitées', 'Commandes illimitées', 'Paiements', 'Livraisons', 'Hors connexion']),
          const SizedBox(height: 12),
          _plan('Pro', '5 000 FCFA / mois', CoutelyaColors.gold, ['Tout du Gratuit', 'Sauvegarde Cloud', 'Catalogue modèles', 'Statistiques avancées', 'Exports PDF', 'Multi-appareils']),
          const SizedBox(height: 12),
          _plan('Atelier', '15 000 FCFA / mois', CoutelyaColors.purpleDark, ['Tout du Pro', 'Gestion des employés', 'Dépenses & recettes', 'Stock & produits', 'Rapports & notifications', 'Support prioritaire']),
          const SizedBox(height: 12),
          const Text('Vous pourrez changer d’offre à tout moment.', textAlign: TextAlign.center, style: TextStyle(color: CoutelyaColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _plan(String name, String price, Color color, List<String> features) => Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(Icons.workspace_premium_rounded, color: color)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)), Text(price, style: const TextStyle(fontWeight: FontWeight.w800))]))]),
            const SizedBox(height: 14),
            ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [Icon(Icons.check_circle_rounded, color: color, size: 17), const SizedBox(width: 7), Expanded(child: Text(f))]))),
            const SizedBox(height: 8),
            FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: color), child: Text(name == 'Gratuit' ? 'Commencer' : 'Choisir $name')),
          ]),
        ),
      );
}

class WorkshopProfileScreen extends StatelessWidget {
  const WorkshopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil de l’atelier')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Center(child: CircleAvatar(radius: 45, backgroundColor: CoutelyaColors.purpleSoft, child: Icon(Icons.storefront_rounded, color: CoutelyaColors.purple, size: 38))),
          const SizedBox(height: 18),
          const Center(child: Text('Atelier Élégance', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
          const SizedBox(height: 22),
          const Card(child: Column(children: [ListTile(title: Text('Propriétaire'), subtitle: Text('Marie K.')), Divider(height: 1), ListTile(title: Text('Téléphone'), subtitle: Text('+229 97 12 34 56')), Divider(height: 1), ListTile(title: Text('Adresse'), subtitle: Text('Lokossa, Bénin')), Divider(height: 1), ListTile(title: Text('Offre actuelle'), subtitle: Text('COUTELYA Pro'))])),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_outlined), label: const Text('Modifier le profil')),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  Future<void> _language() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Langue de l’application',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: CoutelyaColors.green,
                ),
                title: const Text('Français'),
                subtitle: const Text('Langue active'),
                onTap: () => Navigator.pop(context),
              ),
              const ListTile(
                leading: Icon(Icons.translate_rounded, color: CoutelyaColors.muted),
                title: Text('Autres langues'),
                subtitle: Text('Prévues dans une prochaine version'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CoutelyaColors.purpleSoft,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: CoutelyaColors.purple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.storefront_outlined,
                  title: 'Mon atelier',
                  subtitle: 'Informations et coordonnées',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WorkshopProfileScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Sauvegarde & synchronisation',
                  subtitle: 'État des données locales et du Cloud',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
                  ),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.straighten_rounded,
                  title: 'Catégories de mesures',
                  subtitle: 'Mesures standards et personnalisées',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MeasurementSettingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.checkroom_outlined,
                  title: 'Modèles de commandes',
                  subtitle: 'Vêtements, tissus et couleurs proposés',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrderCatalogSettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: notificationsEnabled ? 'Activées' : 'Désactivées',
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => notificationsEnabled = value),
                  ),
                  onTap: () => setState(
                    () => notificationsEnabled = !notificationsEnabled,
                  ),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.language_rounded,
                  title: 'Langue',
                  subtitle: 'Français',
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Français'),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: _language,
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.security_outlined,
                  title: 'Sécurité',
                  subtitle: 'Protection et stockage des données',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SecuritySettingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _tile(
                  icon: Icons.info_outline_rounded,
                  title: 'À propos de COUTELYA',
                  subtitle: 'Version et informations de l’application',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutCoutelyaScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MeasurementSettingsScreen extends StatelessWidget {
  const MeasurementSettingsScreen({super.key});

  static const labels = [
    'Tour de poitrine',
    'Tour de taille',
    'Tour de hanches',
    'Longueur dos',
    'Longueur épaule',
    'Longueur manche',
    'Tour de cou',
    'Entrejambe',
    'Tour de cuisse',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories de mesures')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: CoutelyaColors.purple),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lors de la fiche d’un client, vous pouvez ajouter librement une mesure personnalisée en plus des mesures standards.',
                      style: TextStyle(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mesures standards',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...labels.map(
            (label) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.straighten_rounded,
                  color: CoutelyaColors.purple,
                ),
                title: Text(label),
                trailing: const Text('cm'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCatalogSettingsScreen extends StatelessWidget {
  const OrderCatalogSettingsScreen({super.key});

  List<String> _withoutCustom(List<String> items) =>
      items.where((item) => item != customCatalogOption).toList();

  Widget _catalog(String title, IconData icon, List<String> values) => Card(
        child: ExpansionTile(
          leading: Icon(icon, color: CoutelyaColors.purple),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${_withoutCustom(values).length} choix proposés'),
          children: _withoutCustom(values)
              .map(
                (value) => ListTile(
                  dense: true,
                  leading: const SizedBox(width: 8),
                  title: Text(value),
                ),
              )
              .toList(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modèles de commandes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Ces listes sont proposées lors de la création ou de la modification d’une commande. Le choix « Autre / personnalisé » permet toujours une saisie libre.',
                style: TextStyle(height: 1.35),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _catalog('Modèles de vêtements', Icons.checkroom_rounded, garmentModels),
          _catalog('Types de tissus', Icons.texture_rounded, fabricTypes),
          _catalog('Couleurs', Icons.palette_outlined, fabricColors),
        ],
      ),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.phone_android_rounded, color: CoutelyaColors.purple),
                  title: Text('Données locales'),
                  subtitle: Text('Les données sont enregistrées dans la base locale de COUTELYA sur cet appareil.'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_outlined, color: CoutelyaColors.purple),
                  title: Text('Synchronisation Cloud'),
                  subtitle: Text('Elle n’est utilisée que lorsqu’elle est configurée et activée.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutCoutelyaScreen extends StatelessWidget {
  const AboutCoutelyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos de COUTELYA')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: CoutelyaColors.purpleSoft,
              child: Icon(Icons.checkroom_rounded, color: CoutelyaColors.purple, size: 38),
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              'COUTELYA',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Votre atelier, simplement.',
              style: TextStyle(color: CoutelyaColors.muted),
            ),
          ),
          SizedBox(height: 22),
          Card(
            child: Column(
              children: [
                ListTile(title: Text('Version'), trailing: Text('0.2.3')),
                Divider(height: 1),
                ListTile(
                  title: Text('Mode de fonctionnement'),
                  trailing: Text('Offline-first'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode hors connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 120, height: 120, decoration: const BoxDecoration(color: CoutelyaColors.purpleSoft, shape: BoxShape.circle), child: const Icon(Icons.wifi_off_rounded, size: 62, color: CoutelyaColors.purple)),
          const SizedBox(height: 24),
          const Text('Vous travaillez hors connexion', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Toutes vos données sont enregistrées localement sur votre téléphone. Elles pourront être synchronisées automatiquement lorsque la connexion Cloud sera activée.', textAlign: TextAlign.center, style: TextStyle(color: CoutelyaColors.muted, height: 1.5)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Vos données locales sont actives. La synchronisation Cloud nécessite une configuration Supabase valide.',
                ),
              ),
            ),
            icon: const Icon(Icons.cloud_sync_outlined),
            label: const Text('Vérifier la synchronisation'),
          ),
        ]),
      ),
    );
  }
}
