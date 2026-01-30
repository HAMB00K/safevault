import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/import_export_service.dart';
import '../../../vault/presentation/providers/vault_provider.dart';
import '../../../vault/domain/entities/password_entity.dart';
import 'settings_screen.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passwords = ref.watch(passwordsProvider).passwords;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Import / Export'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Export
          _buildSectionHeader(
            context,
            'Exporter vos données',
            Icons.upload_outlined,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          _buildInfoCard(
            context,
            'Sauvegardez vos ${passwords.length} mots de passe',
            'Exportez vos données dans un format sécurisé pour les sauvegarder ou les transférer.',
            Icons.info_outline,
            Colors.blue,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          const SizedBox(height: 16),

          _buildExportCard(
            context,
            'Export JSON',
            'Format standard, facile à lire',
            Icons.code,
            Colors.orange,
            () => _exportData(ExportFormat.json),
          ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),

          const SizedBox(height: 12),

          _buildExportCard(
            context,
            'Export CSV',
            'Compatible avec Excel et tableurs',
            Icons.table_chart,
            Colors.green,
            () => _exportData(ExportFormat.csv),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

          const SizedBox(height: 12),

          _buildExportCard(
            context,
            'Export chiffré (.svault)',
            'Format sécurisé, recommandé',
            Icons.lock,
            const Color(0xFF7C183C),
            () => _showEncryptedExportDialog(),
            isRecommended: true,
          ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1),

          const SizedBox(height: 32),

          // Section Import
          _buildSectionHeader(
            context,
            'Importer des données',
            Icons.download_outlined,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          _buildImportCard(
            context,
            'Importer un fichier',
            'JSON, CSV ou fichier chiffré .svault',
            Icons.folder_open,
            () => _importData(),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Status Message
          if (_statusMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSuccess
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error,
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().shake(hz: 2, duration: 500.ms),

          const SizedBox(height: 32),

          // Avertissement de sécurité
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.amber[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Les exports non chiffrés contiennent vos mots de passe en clair. Utilisez le format .svault pour une sécurité maximale.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Traitement en cours...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7C183C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF7C183C)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isRecommended = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '★',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : onTap,
                icon: const Icon(Icons.file_upload),
                label: const Text('Sélectionner un fichier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(ExportFormat format) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final passwords = ref.read(passwordsProvider).passwords;
      
      String content;
      String fileName;

      switch (format) {
        case ExportFormat.json:
          content = await ImportExportService.exportToJson(passwords);
          fileName = 'safevault_export_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case ExportFormat.csv:
          content = ImportExportService.exportToCsv(passwords);
          fileName = 'safevault_export_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        default:
          return;
      }

      await ImportExportService.saveAndShare(content, fileName);

      setState(() {
        _isSuccess = true;
        _statusMessage = 'Export réussi ! ${passwords.length} mots de passe exportés.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = 'Erreur lors de l\'export: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showEncryptedExportDialog() async {
    final passwordController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export chiffré'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez un mot de passe pour protéger votre export. Vous en aurez besoin pour importer ces données.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe de chiffrement',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Exporter'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _exportEncrypted(result);
    }
  }

  Future<void> _exportEncrypted(String password) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final passwords = ref.read(passwordsProvider).passwords;
      final content = await ImportExportService.exportEncrypted(passwords, password);
      final fileName = 'safevault_export_${DateTime.now().millisecondsSinceEpoch}.svault';

      await ImportExportService.saveAndShare(content, fileName);

      setState(() {
        _isSuccess = true;
        _statusMessage = 'Export chiffré réussi ! ${passwords.length} mots de passe sécurisés.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = 'Erreur lors de l\'export: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final content = await ImportExportService.pickAndReadFile();
      
      if (content == null) {
        setState(() => _isLoading = false);
        return;
      }

      final format = ImportExportService.detectFormat(content);
      List<PasswordEntity> passwords;

      if (format == ExportFormat.encrypted) {
        final password = await _showDecryptDialog();
        if (password == null) {
          setState(() => _isLoading = false);
          return;
        }
        passwords = await ImportExportService.importEncrypted(content, password);
      } else if (format == ExportFormat.csv) {
        passwords = ImportExportService.importFromCsv(content);
      } else {
        passwords = await ImportExportService.importFromJson(content);
      }

      // Ajouter les mots de passe importés
      final notifier = ref.read(passwordsProvider.notifier);
      for (final password in passwords) {
        await notifier.addPassword(
          title: password.title,
          username: password.username,
          password: password.encryptedPassword,
          category: password.category,
          url: password.url,
          notes: password.notes,
        );
      }

      setState(() {
        _isSuccess = true;
        _statusMessage = 'Import réussi ! ${passwords.length} mots de passe ajoutés.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = 'Erreur lors de l\'import: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showDecryptDialog() async {
    final passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fichier chiffré'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ce fichier est chiffré. Entrez le mot de passe utilisé lors de l\'export.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Déchiffrer'),
          ),
        ],
      ),
    );
  }
}
