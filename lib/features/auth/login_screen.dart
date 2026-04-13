import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import '../../ui/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignup = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isSignup) {
        await repo.signup(_nameController.text, _emailController.text, _passwordController.text);
        _showMessage("Compte créé avec succès !");
      } else {
        await repo.login(_emailController.text, _passwordController.text);
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.music_note, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 32),
            Text(
              _isSignup ? 'Créer un compte' : 'Prêt pour de la musique ?',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (_isSignup) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  hintText: 'Nom complet',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceColor,
                hintText: 'E-mail',
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceColor,
                hintText: 'Mot de passe',
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            if (!_isSignup)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (_emailController.text.isNotEmpty) {
                      ref.read(authRepositoryProvider).sendPasswordResetEmail(_emailController.text);
                      _showMessage("Lien de réinitialisation envoyé par email.");
                    } else {
                      _showMessage("Entre ton email d'abord.");
                    }
                  },
                  child: const Text('Mot de passe oublié ?', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isSignup ? 'S\'inscrire' : 'Se connecter', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isSignup = !_isSignup),
              child: Text(
                _isSignup ? 'J\'ai déjà un compte' : 'Créer un compte', 
                style: const TextStyle(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
