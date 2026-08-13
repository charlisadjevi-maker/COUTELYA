import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4C1266), Color(0xFF2E0D41)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12))],
                ),
                child: Image.asset('assets/brand/coutelya_mark.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 22),
              const CoutelyaBrand(light: true),
              const Spacer(flex: 2),
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(color: Color(0xFFFFC850), strokeWidth: 3),
              ),
              const SizedBox(height: 34),
              const Text('Chargement...', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                width: 150,
                height: 4,
                decoration: BoxDecoration(color: CoutelyaColors.gold, borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool signup = false;
  bool obscure = true;
  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          children: [
            const CoutelyaBrand(),
            const SizedBox(height: 34),
            Text(
              signup ? 'Créer votre atelier' : 'Bienvenue sur COUTELYA',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: CoutelyaColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              signup ? 'Démarrez simplement, même hors connexion.' : 'Connectez-vous à votre atelier',
              style: const TextStyle(color: CoutelyaColors.muted),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: CoutelyaColors.purpleSoft, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(child: _tab('Connexion', !signup, () => setState(() => signup = false))),
                  Expanded(child: _tab('Inscription', signup, () => setState(() => signup = true))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Téléphone ou e-mail', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: phone,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_iphone), hintText: '+229 97 12 34 56'),
            ),
            const SizedBox(height: 16),
            const Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            if (!signup) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: const Text('Mot de passe oublié ?')),
              ),
            ] else
              const SizedBox(height: 18),
            FilledButton(onPressed: _enter, child: Text(signup ? 'Créer mon atelier' : 'Se connecter')),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _enter,
              icon: const Icon(Icons.wifi_off_rounded),
              label: const Text('Continuer hors connexion'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('ou continuer avec')), Expanded(child: Divider())]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, size: 28), label: const Text('Google'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.facebook), label: const Text('Facebook'))),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: CoutelyaColors.goldSoft, borderRadius: BorderRadius.circular(14)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_off_rounded, color: CoutelyaColors.gold),
                  SizedBox(width: 10),
                  Expanded(child: Text('La V0.2 reste utilisable sans internet. Les données sont enregistrées localement sur votre téléphone.', style: TextStyle(height: 1.35, fontSize: 12.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected ? const [BoxShadow(color: Color(0x12000000), blurRadius: 8)] : null,
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? CoutelyaColors.purple : CoutelyaColors.muted)),
      ),
    );
  }
}
