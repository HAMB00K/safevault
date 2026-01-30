import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/secure_note_entity.dart';
import '../providers/notes_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'add_edit_note_screen.dart';

class SecureNotesScreen extends ConsumerStatefulWidget {
  const SecureNotesScreen({super.key});

  @override
  ConsumerState<SecureNotesScreen> createState() => _SecureNotesScreenState();
}

class _SecureNotesScreenState extends ConsumerState<SecureNotesScreen> {
  String _searchQuery = '';
  NoteCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<SecureNoteEntity> filteredNotes = notesState.notes;

    // Filtrer par catégorie
    if (_selectedCategory != null) {
      filteredNotes = filteredNotes
          .where((note) => note.category == _selectedCategory)
          .toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Notes sécurisées'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
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
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une note...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: isDark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),

          // Chips de catégories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(null, 'Toutes', Icons.all_inclusive),
                ...NoteCategory.values.map((cat) => _buildCategoryChip(
                      cat,
                      cat.displayName,
                      _getCategoryIcon(cat),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // Liste des notes
          Expanded(
            child: notesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return _buildNoteCard(note, index);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNote(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle note'),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildCategoryChip(NoteCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    final color = category != null ? Color(category.colorValue) : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selectedColor: color,
        checkmarkColor: Colors.white,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildNoteCard(SecureNoteEntity note, int index) {
    final categoryColor = Color(note.category.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewNote(note),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.category.displayName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      color: note.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => ref
                        .read(notesProvider.notifier)
                        .toggleFavorite(note),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editNote(note);
                      } else if (value == 'delete') {
                        _deleteNote(note);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.encryptedContent,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.tag, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      note.tags.take(2).join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune note sécurisée',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première note chiffrée',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNote,
            icon: const Icon(Icons.add),
            label: const Text('Créer une note'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  IconData _getCategoryIcon(NoteCategory category) {
    switch (category) {
      case NoteCategory.personal:
        return Icons.person;
      case NoteCategory.work:
        return Icons.work;
      case NoteCategory.finance:
        return Icons.account_balance;
      case NoteCategory.health:
        return Icons.local_hospital;
      case NoteCategory.travel:
        return Icons.flight;
      case NoteCategory.other:
        return Icons.note;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par catégorie',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(null, 'Toutes'),
                ...NoteCategory.values
                    .map((cat) => _buildFilterChip(cat, cat.displayName)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(NoteCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() => _selectedCategory = category);
        Navigator.pop(context);
      },
    );
  }

  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    );
  }

  void _editNote(SecureNoteEntity note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
    );
  }

  void _viewNote(SecureNoteEntity note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
    );
  }

  void _deleteNote(SecureNoteEntity note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: Text('Voulez-vous vraiment supprimer "${note.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
