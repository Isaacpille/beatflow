import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/theme/app_theme.dart';
import '../auth/auth_repository.dart';

final languageProvider = StateProvider<String>((ref) => 'Français');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        children: [
          const _SettingsHeader(title: 'Compte'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Informations personnelles'),
            subtitle: const Text('Gérer votre profil et vos données'),
            onTap: () {
              // TODO: Privacy/Info screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Confidentialité'),
            onTap: () {},
          ),
          const Divider(color: Colors.white10),
          const _SettingsHeader(title: 'Application'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: currentLanguage,
              dropdownColor: AppTheme.surfaceColor,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(languageProvider.notifier).state = newValue;
                }
              },
              items: <String>['Français', 'English', 'Español']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => ref.read(authRepositoryProvider).logout(),
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
