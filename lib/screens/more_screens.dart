import 'package:flutter/material.dart';

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
          const Center(child: Text('COUTELYA V0.2.0', style: TextStyle(color: CoutelyaColors.muted, fontSize: 12))),
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
  final input = TextEditingController();
  final List<_ChatLine> lines = const [
    _ChatLine(false, 'Bonjour 👋'),
    _ChatLine(false, 'Je suis Lya. Je peux résumer les commandes, les retards et les montants à encaisser.'),
  ].toList();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      lines.add(_ChatLine(true, text));
      input.clear();
    });
    final stats = await orderRepo.stats();
    final lower = text.toLowerCase();
    String reply;
    if (lower.contains('retard')) {
      reply = '${stats.late} commande(s) sont actuellement en retard.';
    } else if (lower.contains('encaisser') || lower.contains('reste') || lower.contains('argent')) {
      reply = 'Il reste ${formatMoney(stats.receivable)} à encaisser sur les commandes enregistrées.';
    } else if (lower.contains('prêt') || lower.contains('livr')) {
      reply = '${stats.ready} commande(s) sont prêtes et ${stats.delivered} ont déjà été livrées.';
    } else {
      reply = 'Résumé : ${stats.inProgress} commande(s) en cours, ${stats.ready} prête(s), ${stats.late} en retard et ${formatMoney(stats.receivable)} à encaisser.';
    }
    if (mounted) setState(() => lines.add(_ChatLine(false, reply)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [CircleAvatar(radius: 16, backgroundColor: CoutelyaColors.purple, child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 17)), SizedBox(width: 9), Text('Lya')])),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lines.length,
              itemBuilder: (context, i) {
                final line = lines[i];
                return Align(
                  alignment: line.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                    decoration: BoxDecoration(color: line.user ? CoutelyaColors.purple : CoutelyaColors.purpleSoft, borderRadius: BorderRadius.circular(16)),
                    child: Text(line.text, style: TextStyle(color: line.user ? Colors.white : CoutelyaColors.ink, height: 1.35)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                Expanded(child: TextField(controller: input, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'Comment puis-je vous aider ?'))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: send, icon: const Icon(Icons.arrow_upward_rounded)),
              ]),
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: Column(children: [ListTile(leading: Icon(Icons.storefront_outlined), title: Text('Mon atelier'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.cloud_sync_outlined), title: Text('Sauvegarde & synchronisation'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.straighten_rounded), title: Text('Catégories de mesures'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.checkroom_outlined), title: Text('Modèles de commandes'), trailing: Icon(Icons.chevron_right))])),
          SizedBox(height: 12),
          Card(child: Column(children: [ListTile(leading: Icon(Icons.notifications_none_rounded), title: Text('Notifications'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.language_rounded), title: Text('Langue'), trailing: Text('Français')), Divider(height: 1), ListTile(leading: Icon(Icons.security_outlined), title: Text('Sécurité'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('À propos de COUTELYA'), trailing: Icon(Icons.chevron_right))])),
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
          FilledButton.icon(onPressed: null, icon: Icon(Icons.cloud_sync_outlined), label: Text('Synchronisation Cloud bientôt disponible')),
        ]),
      ),
    );
  }
}
