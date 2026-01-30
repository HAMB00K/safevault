import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../providers.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';
import '../providers/vault_provider.dart';
import 'add_edit_password_screen.dart';

class PasswordDetailScreen extends ConsumerStatefulWidget {
  final PasswordEntity password;

  const PasswordDetailScreen({super.key, required this.password});

  @override
  ConsumerState<PasswordDetailScreen> createState() =>
      _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends ConsumerState<PasswordDetailScreen> {
  bool _passwordVisible = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copié !'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deletePassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Supprimer'),
        content: Text(
            'Voulez-vous vraiment supprimer "${widget.password.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(passwordsProvider.notifier)
          .deletePassword(widget.password.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _editPassword() {
    // Récupérer le mot de passe à jour depuis le provider
    final passwordsState = ref.read(passwordsProvider);
    final foundPassword = passwordsState.passwords.cast<PasswordEntity>().where(
      (p) => p.id == widget.password.id,
    );
    final currentPassword = foundPassword.isNotEmpty ? foundPassword.first : widget.password;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPasswordScreen(password: currentPassword),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    // Utiliser le provider pour avoir l'état à jour (notamment isFavorite)
    final passwordsState = ref.watch(passwordsProvider);
    final foundPassword = passwordsState.passwords.cast<PasswordEntity>().where(
      (p) => p.id == widget.password.id,
    );
    final password = foundPassword.isNotEmpty ? foundPassword.first : widget.password;
    final createdDate = DateFormat('dd/MM/yyyy à HH:mm').format(password.createdAt);
    final updatedDate = DateFormat('dd/MM/yyyy à HH:mm').format(password.updatedAt);

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          IconButton(
            icon: Icon(
              password.isFavorite ? Icons.star : Icons.star_border,
              color: password.isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              ref.read(passwordsProvider.notifier).toggleFavorite(password.id);
            },
            tooltip: password.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPassword,
            tooltip: 'Éditer',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePassword,
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec catégorie
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: password.category.color.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: password.category.color.withOpacity(0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Logos catégorie + service
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo catégorie
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: password.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Image.asset(
                            password.category.iconPath,
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Logo service si présent
                      if (password.serviceLogo != ServiceLogo.none) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: password.serviceLogo.brandColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: FaIcon(
                              password.serviceLogo.icon,
                              size: 32,
                              color: password.serviceLogo.brandColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    password.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: password.category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      password.category.displayName,
                      style: TextStyle(
                        color: password.category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Informations
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identifiant
                  _buildInfoCard(
                    icon: Icons.person,
                    label: 'Identifiant / Email',
                    value: password.username,
                    onCopy: () => _copyToClipboard(password.username, 'Identifiant'),
                    delay: 100,
                  ),

                  const SizedBox(height: 12),

                  // Mot de passe
                  _buildInfoCard(
                    icon: Icons.lock,
                    label: 'Mot de passe',
                    value: _passwordVisible
                        ? password.encryptedPassword
                        : '•' * 12,
                    onCopy: () =>
                        _copyToClipboard(password.encryptedPassword, 'Mot de passe'),
                    trailing: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                    delay: 150,
                  ),

                  const SizedBox(height: 12),

                  // URL (si disponible)
                  if (password.url != null && password.url!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildInfoCard(
                        icon: Icons.link,
                        label: 'URL',
                        value: password.url!,
                        onCopy: () => _copyToClipboard(password.url!, 'URL'),
                        delay: 200,
                      ),
                    ),

                  // Notes (si disponibles)
                  if (password.notes != null && password.notes!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.notes,
                      label: 'Notes',
                      value: password.notes!,
                      onCopy: () => _copyToClipboard(password.notes!, 'Notes'),
                      delay: 250,
                      maxLines: 5,
                    ),

                  const SizedBox(height: 24),

                  // Métadonnées
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppThemeDark.textSecondary,
                        ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),

                  _buildMetaInfoTile(
                    icon: Icons.calendar_today,
                    label: 'Créé le',
                    value: createdDate,
                    delay: 350,
                  ),
                  const SizedBox(height: 8),
                  _buildMetaInfoTile(
                    icon: Icons.update,
                    label: 'Modifié le',
                    value: updatedDate,
                    delay: 400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
    Widget? trailing,
    int delay = 0,
    int maxLines = 1,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppThemeDark.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppThemeDark.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: onCopy,
                  tooltip: 'Copier',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX();
  }

  Widget _buildMetaInfoTile({
    required IconData icon,
    required String label,
    required String value,
    int delay = 0,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppThemeDark.textSecondary),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppThemeDark.textSecondary,
              ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX();
  }
}