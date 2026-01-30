import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../providers.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';
import '../providers/vault_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'add_edit_password_screen.dart';
import 'password_detail_screen.dart';

class PasswordsListScreen extends ConsumerStatefulWidget {
  const PasswordsListScreen({super.key});

  @override
  ConsumerState<PasswordsListScreen> createState() => _PasswordsListScreenState();
}

class _PasswordsListScreenState extends ConsumerState<PasswordsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<PasswordCategory> _selectedCategories = {};
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PasswordEntity> _filterPasswords(List<PasswordEntity> passwords) {
    var filtered = passwords.where((p) => !p.isTemporary).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.url?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((p) => _selectedCategories.contains(p.category)).toList();
    }

    if (_showFavoritesOnly) {
      filtered = filtered.where((p) => p.isFavorite).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final passwordsState = ref.watch(passwordsProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final filteredPasswords = _filterPasswords(passwordsState.passwords);

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Mots de passe'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPasswordScreen()),
          );
        },
        backgroundColor: AppThemeDark.primary,
        child: const Icon(Icons.add),
      ).animate().scale(delay: 300.ms),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark 
                    ? AppThemeDark.surface 
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.2),

          // Filtres et compteur
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Dropdown multi-select catégories
                Expanded(
                  child: InkWell(
                    onTap: () => _showCategoryFilterDialog(isDark),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeDark.surface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedCategories.isNotEmpty 
                              ? AppThemeDark.primary 
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: _selectedCategories.isNotEmpty 
                                ? AppThemeDark.primary 
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedCategories.isEmpty
                                  ? 'Toutes les catégories'
                                  : '${_selectedCategories.length} catégorie${_selectedCategories.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: _selectedCategories.isNotEmpty 
                                    ? AppThemeDark.primary 
                                    : Colors.grey[600],
                                fontWeight: _selectedCategories.isNotEmpty 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Compteur
                Text(
                  '${filteredPasswords.length}',
                  style: TextStyle(
                    color: AppThemeDark.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_selectedCategories.isNotEmpty || _showFavoritesOnly)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedCategories = {};
                        _showFavoritesOnly = false;
                      });
                    },
                    tooltip: 'Effacer filtres',
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // Liste des mots de passe
          Expanded(
            child: passwordsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPasswords.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPasswords.length,
                        itemBuilder: (context, index) {
                          final password = filteredPasswords[index];
                          return _buildPasswordCard(password, isDark, index);
                        },
                      ),
          ),

          const SizedBox(height: 80), // Espace pour la navbar
        ],
      ),
    );
  }

  void _showCategoryFilterDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppThemeDark.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Filtrer par catégorie',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {});
                              setState(() => _selectedCategories = {});
                            },
                            child: const Text('Tout désélectionner'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: PasswordCategory.values.map((category) {
                            final isSelected = _selectedCategories.contains(category);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setModalState(() {
                                  setState(() {
                                    if (value == true) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  });
                                });
                              },
                              activeColor: AppThemeDark.primary,
                              secondary: Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  category.iconPath,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              title: Text(category.displayName),
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemeDark.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun mot de passe',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategories.isNotEmpty
                ? 'Essayez de modifier vos filtres'
                : 'Ajoutez votre premier mot de passe',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPasswordCard(PasswordEntity password, bool isDark, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppThemeDark.surface : Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordDetailScreen(password: password),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône catégorie (image)
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: password.category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  password.category.iconPath,
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                ),
              ),
              // Logo service si présent
              if (password.serviceLogo != ServiceLogo.none) ...[              
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: password.serviceLogo.brandColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      password.serviceLogo.icon,
                      size: 22,
                      color: password.serviceLogo.brandColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            password.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (password.isFavorite)
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      password.username,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (password.url != null && password.url!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          password.url!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: password.encryptedPassword),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe copié !'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copier le mot de passe',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
  }
}
