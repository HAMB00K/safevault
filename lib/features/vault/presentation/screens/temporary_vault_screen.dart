import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/services/temporary_vault_service.dart';
import '../../domain/entities/password_entity.dart';
import '../providers/vault_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class TemporaryVaultScreen extends ConsumerWidget {
  const TemporaryVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordsState = ref.watch(passwordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtrer les mots de passe temporaires
    final temporaryPasswords = passwordsState.passwords
        .where((p) => p.isTemporary)
        .toList()
      ..sort((a, b) => (a.deleteAt ?? DateTime.now())
          .compareTo(b.deleteAt ?? DateTime.now()));

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Coffre-fort temporaire'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bannière d'information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeDark.primary,
                  AppThemeDark.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mots de passe temporaires',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${temporaryPasswords.length} mot(s) de passe',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),

          // Liste des mots de passe temporaires
          Expanded(
            child: temporaryPasswords.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: temporaryPasswords.length,
                    itemBuilder: (context, index) {
                      final password = temporaryPasswords[index];
                      return _buildPasswordCard(context, ref, password, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTemporaryPasswordDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter temporaire'),
        backgroundColor: AppThemeDark.primary,
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun mot de passe temporaire',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Les mots de passe temporaires sont automatiquement supprimés après leur délai d\'expiration.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPasswordCard(
    BuildContext context,
    WidgetRef ref,
    PasswordEntity password,
    int index,
  ) {
    final timeLeft = _getTimeLeft(password.deleteAt);
    final isExpiringSoon = password.deleteAt != null &&
        password.deleteAt!.difference(DateTime.now()).inHours < 24;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpiringSoon
              ? Colors.red.withOpacity(0.5)
              : AppThemeDark.primary.withOpacity(0.3),
          width: isExpiringSoon ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppThemeDark.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: isExpiringSoon ? Colors.red : AppThemeDark.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        password.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        password.username,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _deletePassword(context, ref, password),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isExpiringSoon
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isExpiringSoon ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Expire $timeLeft',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpiringSoon ? Colors.red : Colors.grey[600],
                      fontWeight:
                          isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
  }

  String _getTimeLeft(DateTime? deleteAt) {
    if (deleteAt == null) return 'jamais';

    final diff = deleteAt.difference(DateTime.now());

    if (diff.isNegative) return 'bientôt supprimé';

    if (diff.inDays > 0) {
      return 'dans ${diff.inDays} jour(s)';
    } else if (diff.inHours > 0) {
      return 'dans ${diff.inHours} heure(s)';
    } else if (diff.inMinutes > 0) {
      return 'dans ${diff.inMinutes} minute(s)';
    } else {
      return 'dans moins d\'une minute';
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer, color: AppThemeDark.primary),
            const SizedBox(width: 12),
            const Text('Coffre-fort temporaire'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le coffre-fort temporaire vous permet de stocker des mots de passe qui seront automatiquement supprimés après un délai défini.',
            ),
            SizedBox(height: 16),
            Text(
              'Cas d\'utilisation :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Partage temporaire d\'accès'),
            Text('• Mots de passe à usage unique'),
            Text('• Accès invité limité dans le temps'),
            Text('• Tests et démonstrations'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showAddTemporaryPasswordDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    TemporaryDuration selectedDuration = TemporaryDuration.oneDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nouveau mot de passe temporaire',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Durée avant suppression',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TemporaryDuration.values.map((duration) {
                  return ChoiceChip(
                    selected: selectedDuration == duration,
                    label: Text(duration.displayName),
                    onSelected: (_) {
                      setState(() => selectedDuration = duration);
                    },
                    selectedColor: AppThemeDark.primary,
                    labelStyle: TextStyle(
                      color: selectedDuration == duration
                          ? Colors.white
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        usernameController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await ref.read(passwordsProvider.notifier).addPassword(
                          title: titleController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                          category: PasswordCategory.other,
                          isTemporary: true,
                          deleteAt: selectedDuration.deleteAt,
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mot de passe temporaire créé (expire ${selectedDuration.displayName})',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Créer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeDark.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePassword(
    BuildContext context,
    WidgetRef ref,
    PasswordEntity password,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text(
          'Voulez-vous supprimer "${password.title}" maintenant ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(passwordsProvider.notifier).deletePassword(password.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
