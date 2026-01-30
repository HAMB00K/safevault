import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';
import '../providers/vault_provider.dart';
import '../../../password_generator/presentation/screens/password_generator_screen.dart';

class AddEditPasswordScreen extends ConsumerStatefulWidget {
  final PasswordEntity? password;

  const AddEditPasswordScreen({super.key, this.password});

  @override
  ConsumerState<AddEditPasswordScreen> createState() =>
      _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState
    extends ConsumerState<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _obscurePassword = true;
  PasswordCategory _selectedCategory = PasswordCategory.other;
  ServiceLogo _selectedServiceLogo = ServiceLogo.none;
  bool _isLoading = false;

  bool get _isEditing => widget.password != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.password != null) {
      // Charger les données du mot de passe à éditer
      _titleController.text = widget.password!.title;
      _usernameController.text = widget.password!.username;
      _passwordController.text = widget.password!.encryptedPassword;
      _urlController.text = widget.password!.url ?? '';
      _notesController.text = widget.password!.notes ?? '';
      _selectedCategory = widget.password!.category;
      _selectedServiceLogo = widget.password!.serviceLogo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing && widget.password != null) {
        // Mettre à jour le mot de passe existant
        final updatedPassword = widget.password!.copyWith(
          title: _titleController.text,
          username: _usernameController.text,
          encryptedPassword: _passwordController.text,
          category: _selectedCategory,
          serviceLogo: _selectedServiceLogo,
          url: _urlController.text.isEmpty ? null : _urlController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        await ref.read(passwordsProvider.notifier).updatePassword(updatedPassword);
      } else {
        // Ajouter un nouveau mot de passe
        await ref.read(passwordsProvider.notifier).addPassword(
              title: _titleController.text,
              username: _usernameController.text,
              password: _passwordController.text,
              category: _selectedCategory,
              serviceLogo: _selectedServiceLogo,
              url: _urlController.text.isEmpty ? null : _urlController.text,
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
            );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Mot de passe modifié !'
              : 'Mot de passe ajouté !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showServiceLogoPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Choisir un logo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedServiceLogo = ServiceLogo.none);
                          Navigator.pop(context);
                        },
                        child: const Text('Aucun'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildLogoSection('Réseaux sociaux', ServiceLogoExtension.socialLogos),
                      _buildLogoSection('Tech & Dev', ServiceLogoExtension.techLogos),
                      _buildLogoSection('Streaming', ServiceLogoExtension.streamingLogos),
                      _buildLogoSection('E-commerce', ServiceLogoExtension.ecommerceLogos),
                      _buildLogoSection('Gaming', ServiceLogoExtension.gamingLogos),
                      _buildLogoSection('Cloud & Outils', ServiceLogoExtension.cloudLogos),
                      _buildLogoSection('Finance', ServiceLogoExtension.financeLogos),
                      _buildLogoSection('Email', ServiceLogoExtension.emailLogos),
                      _buildLogoSection('Autres', ServiceLogoExtension.otherLogos),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLogoSection(String title, List<ServiceLogo> logos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: logos.map((logo) {
            final isSelected = _selectedServiceLogo == logo;
            return InkWell(
              onTap: () {
                setState(() => _selectedServiceLogo = logo);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? logo.brandColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: logo.brandColor, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      logo.icon,
                      size: 24,
                      color: logo.brandColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      logo.displayName,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _generatePassword() async {
    final generated = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const PasswordGeneratorScreen(
          isSelectionMode: true,
        ),
      ),
    );

    if (generated != null) {
      setState(() {
        _passwordController.text = generated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: Text(_isEditing ? 'Éditer' : 'Nouveau mot de passe'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titre
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms).slideX(),

            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<PasswordCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
              ),
              items: PasswordCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Image.asset(
                        category.iconPath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(),

            const SizedBox(height: 16),

            // Logo du service
            InkWell(
              onTap: _showServiceLogoPicker,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Logo du service (optionnel)',
                  prefixIcon: Icon(Icons.image),
                ),
                child: Row(
                  children: [
                    if (_selectedServiceLogo != ServiceLogo.none) ...[
                      FaIcon(
                        _selectedServiceLogo.icon,
                        size: 20,
                        color: _selectedServiceLogo.brandColor,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _selectedServiceLogo.displayName,
                        style: TextStyle(
                          color: _selectedServiceLogo != ServiceLogo.none
                              ? null
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    if (_selectedServiceLogo != ServiceLogo.none)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() => _selectedServiceLogo = ServiceLogo.none);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 75.ms).slideX(),

            const SizedBox(height: 16),

            // Identifiant/Email
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Identifiant / Email *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'identifiant est requis';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(),

            const SizedBox(height: 16),

            // Mot de passe
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe *',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      onPressed: _generatePassword,
                      tooltip: 'Générer',
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est requis';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(),

            const SizedBox(height: 16),

            // URL
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL (optionnel)',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 4,
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideX(),

            const SizedBox(height: 32),

            // Bouton sauvegarder
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).scale(),
          ],
        ),
      ),
    );
  }
}
