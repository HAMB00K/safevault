import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/utils/password_generator.dart';
import '../../../auth/presentation/widgets/password_strength_indicator.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  final bool isSelectionMode;

  const PasswordGeneratorScreen({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  int _length = 16;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeDigits = true;
  bool _includeSymbols = true;
  bool _excludeAmbiguous = false;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  // Vérifie si au moins une option est activée
  bool get _hasAtLeastOneOption =>
      _includeLowercase || _includeUppercase || _includeDigits || _includeSymbols;

  void _generatePassword() {
    // Ne pas générer si aucune option n'est activée
    if (!_hasAtLeastOneOption) {
      setState(() {
        _generatedPassword = '';
      });
      return;
    }
    
    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        length: _length,
        includeLowercase: _includeLowercase,
        includeUppercase: _includeUppercase,
        includeDigits: _includeDigits,
        includeSymbols: _includeSymbols,
        excludeAmbiguous: _excludeAmbiguous,
      );
    });
  }

  // Empêche de désactiver la dernière option active
  bool _canDisableOption(bool currentValue, bool isThisOption) {
    if (!currentValue) return true; // On peut toujours activer
    
    // Compte les options actives
    int activeCount = 0;
    if (_includeLowercase) activeCount++;
    if (_includeUppercase) activeCount++;
    if (_includeDigits) activeCount++;
    if (_includeSymbols) activeCount++;
    
    // Ne peut pas désactiver si c'est la dernière option active
    return activeCount > 1;
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _generatedPassword));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mot de passe copié !'),
        backgroundColor: AppThemeDark.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectPassword() {
    Navigator.of(context).pop(_generatedPassword);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Générateur'),
        elevation: 0,
        actions: [
          if (widget.isSelectionMode)
            TextButton(
              onPressed: _selectPassword,
              child: const Text('Utiliser'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mot de passe généré
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SelectableText(
                    _generatedPassword,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _generatePassword,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Régénérer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copier'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(),

          const SizedBox(height: 16),

          // Indicateur de force
          if (_generatedPassword.isNotEmpty)
            PasswordStrengthIndicator(
              password: _generatedPassword,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 24),

          // Longueur
          Text(
            'Longueur: $_length caractères',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

          Slider(
            value: _length.toDouble(),
            min: 8,
            max: 64,
            divisions: 56,
            label: _length.toString(),
            onChanged: (value) {
              setState(() {
                _length = value.toInt();
                _generatePassword();
              });
            },
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Options
          Text(
            'Options',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Minuscules (a-z)'),
            subtitle: !_canDisableOption(_includeLowercase, true) && _includeLowercase
                ? const Text('Au moins une option requise', style: TextStyle(color: Colors.orange, fontSize: 12))
                : null,
            value: _includeLowercase,
            onChanged: _canDisableOption(_includeLowercase, true)
                ? (value) {
                    setState(() {
                      _includeLowercase = value;
                      _generatePassword();
                    });
                  }
                : null,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(),

          SwitchListTile(
            title: const Text('Majuscules (A-Z)'),
            subtitle: !_canDisableOption(_includeUppercase, true) && _includeUppercase
                ? const Text('Au moins une option requise', style: TextStyle(color: Colors.orange, fontSize: 12))
                : null,
            value: _includeUppercase,
            onChanged: _canDisableOption(_includeUppercase, true)
                ? (value) {
                    setState(() {
                      _includeUppercase = value;
                      _generatePassword();
                    });
                  }
                : null,
          ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideX(),

          SwitchListTile(
            title: const Text('Chiffres (0-9)'),
            subtitle: !_canDisableOption(_includeDigits, true) && _includeDigits
                ? const Text('Au moins une option requise', style: TextStyle(color: Colors.orange, fontSize: 12))
                : null,
            value: _includeDigits,
            onChanged: _canDisableOption(_includeDigits, true)
                ? (value) {
                    setState(() {
                      _includeDigits = value;
                      _generatePassword();
                    });
                  }
                : null,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(),

          SwitchListTile(
            title: const Text('Symboles (!@#...)'),
            subtitle: !_canDisableOption(_includeSymbols, true) && _includeSymbols
                ? const Text('Au moins une option requise', style: TextStyle(color: Colors.orange, fontSize: 12))
                : null,
            value: _includeSymbols,
            onChanged: _canDisableOption(_includeSymbols, true)
                ? (value) {
                    setState(() {
                      _includeSymbols = value;
                      _generatePassword();
                    });
                  }
                : null,
          ).animate().fadeIn(duration: 400.ms, delay: 450.ms).slideX(),

          const Divider(height: 32),

          SwitchListTile(
            title: const Text('Exclure caractères ambigus'),
            subtitle: const Text('Exclut: 0, O, l, 1, I'),
            value: _excludeAmbiguous,
            onChanged: (value) {
              setState(() {
                _excludeAmbiguous = value;
                _generatePassword();
              });
            },
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(),
        ],
      ),
    );
  }
}
