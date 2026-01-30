import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auto_lock_service.dart';
import '../../../../providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/app_lock_wrapper.dart';
import '../../../vault/presentation/providers/vault_provider.dart';
import '../../../auth/presentation/screens/splash_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final authState = ref.watch(authProvider);
    final autoLockState = ref.watch(autoLockProvider);
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section Sécurité
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sécurité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppThemeDark.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(),

          SwitchListTile(
            title: const Text('Authentification biométrique'),
            subtitle: Text(
              authState.biometricAvailable 
                  ? 'Touch ID / Face ID / Empreinte'
                  : 'Non disponible sur cet appareil',
            ),
            secondary: Icon(
              Icons.fingerprint,
              color: authState.biometricAvailable ? null : Colors.grey,
            ),
            value: authState.biometricEnabled,
            onChanged: authState.biometricAvailable
                ? (value) async {
                    if (value) {
                      await ref.read(authProvider.notifier).enableBiometric();
                    } else {
                      await ref.read(authProvider.notifier).disableBiometric();
                    }
                  }
                : null,
          ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(),

          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Verrouillage automatique'),
            subtitle: Text(_getAutoLockText(autoLockState.timeoutSeconds)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (autoLockState.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemeDark.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      autoLockState.formattedRemaining,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppThemeDark.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showAutoLockDialog(autoLockState.timeoutSeconds),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(),

          // Bouton de verrouillage manuel - Style Power Off
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLockConfirmation(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeDark.primary.withOpacity(0.15),
                        AppThemeDark.error.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemeDark.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icône Power
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppThemeDark.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemeDark.error.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.power_settings_new,
                          color: AppThemeDark.error,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Texte
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verrouiller le coffre',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Appuyez pour verrouiller maintenant',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flèche
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 120.ms).slideX(),

          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Changer le master password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangeMasterPasswordDialog,
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(),

          const Divider(),

          // Section Apparence
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Apparence',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppThemeDark.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(),

          SwitchListTile(
            title: const Text('Thème sombre'),
            secondary: const Icon(Icons.dark_mode),
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideX(),

          const Divider(),

          // Section Compte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Compte',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppThemeDark.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(),

          ListTile(
            leading: Icon(Icons.delete_forever, color: AppThemeDark.error),
            title: Text(
              'Supprimer toutes les données',
              style: TextStyle(color: AppThemeDark.error),
            ),
            subtitle: const Text('Action irréversible'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDeleteAllDialog,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(),

          const Divider(),

          // Section À propos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'À propos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppThemeDark.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(AppConstants.appVersion),
          ).animate().fadeIn(duration: 400.ms, delay: 550.ms).slideX(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getAutoLockText(int timeout) {
    if (timeout == 30) return '30 secondes';
    if (timeout == 60) return '1 minute';
    if (timeout == 120) return '2 minutes';
    if (timeout == 300) return '5 minutes';
    if (timeout == 600) return '10 minutes';
    return 'Jamais';
  }

  Future<void> _showAutoLockDialog(int currentTimeout) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer, color: AppThemeDark.primary),
            SizedBox(width: 12),
            Text('Verrouillage automatique'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Après cette durée d\'inactivité, le coffre-fort sera automatiquement verrouillé.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            RadioListTile<int>(
              title: const Text('30 secondes'),
              subtitle: const Text('Très sécurisé'),
              value: 30,
              groupValue: currentTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('1 minute'),
              value: 60,
              groupValue: currentTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('2 minutes'),
              subtitle: const Text('Recommandé'),
              value: 120,
              groupValue: currentTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('5 minutes'),
              value: 300,
              groupValue: currentTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('10 minutes'),
              subtitle: const Text('Moins sécurisé'),
              value: 600,
              groupValue: currentTimeout,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await ref.read(autoLockProvider.notifier).setAutoLockTimeout(result);
    }
  }

  void _showLockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeDark.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.power_settings_new,
                color: AppThemeDark.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Verrouiller'),
          ],
        ),
        content: const Text(
          'Voulez-vous verrouiller le coffre-fort maintenant ?\n\nVous devrez entrer votre master password pour y accéder à nouveau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              appLockWrapperKey.currentState?.manualLock();
            },
            icon: const Icon(Icons.power_settings_new, size: 18),
            label: const Text('Verrouiller'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeDark.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ATTENTION :'),
        content: const Text(
          'Cette action supprimera TOUTES vos données de manière irréversible. Confirmez-vous ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeDark.error,
            ),
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Supprimer tous les mots de passe
      await ref.read(passwordsProvider.notifier).deleteAllPasswords();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les données ont été supprimées'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showChangeMasterPasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer le master password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureCurrent = !obscureCurrent);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureNew = !obscureNew);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureConfirm = !obscureConfirm);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Vérifier que les champs sont remplis
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Vérifier que les nouveaux mots de passe correspondent
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les nouveaux mots de passe ne correspondent pas'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Vérifier le mot de passe actuel
                final isCurrentValid = await ref
                    .read(authProvider.notifier)
                    .verifyMasterPassword(currentPasswordController.text);

                if (!isCurrentValid) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mot de passe actuel incorrect'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Créer le nouveau mot de passe
                final success = await ref
                    .read(authProvider.notifier)
                    .createMasterPassword(newPasswordController.text);

                if (context.mounted) {
                  Navigator.pop(context, success);
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Master password modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Rediriger vers l'écran de splash après 1 seconde
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }
}
