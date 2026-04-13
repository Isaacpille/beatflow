import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_repository.dart';
import '../../ui/theme/app_theme.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Administrateur'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final isBanned = userData['status'] == 'banned';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isBanned ? Colors.red : AppTheme.primaryColor,
                  child: Text(userData['name']?[0] ?? '?', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(userData['name'] ?? 'Inconnu'),
                subtitle: Text(userData['email'] ?? 'Sans email'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(isBanned ? 'Débannir' : 'Bannir'),
                      onTap: () {
                        FirebaseFirestore.instance.collection('users').doc(userId).update({
                          'status': isBanned ? 'active' : 'banned',
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Réinitialiser MDP'),
                      onTap: () {
                        ref.read(authRepositoryProvider).sendPasswordResetEmail(userData['email']);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
