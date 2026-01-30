import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/secure_note_entity.dart';
import '../providers/notes_provider.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final SecureNoteEntity? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  NoteCategory _selectedCategory = NoteCategory.other;
  List<String> _tags = [];
  bool _isLoading = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.encryptedContent;
      _selectedCategory = widget.note!.category;
      _tags = List.from(widget.note!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing && widget.note != null) {
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text,
          encryptedContent: _contentController.text,
          category: _selectedCategory,
          tags: _tags,
        );
        await ref.read(notesProvider.notifier).updateNote(updatedNote);
      } else {
        await ref.read(notesProvider.notifier).addNote(
              title: _titleController.text,
              content: _contentController.text,
              category: _selectedCategory,
              tags: _tags,
            );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Note modifiée !' : 'Note ajoutée !'),
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

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1625) 
          : const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la note' : 'Nouvelle note'),
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(
                widget.note!.isFavorite ? Icons.star : Icons.star_border,
                color: widget.note!.isFavorite ? Colors.amber : null,
              ),
              onPressed: () async {
                await ref
                    .read(notesProvider.notifier)
                    .toggleFavorite(widget.note!);
                Navigator.pop(context);
              },
            ),
        ],
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
            ).animate().fadeIn(duration: 300.ms).slideX(),

            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<NoteCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
              ),
              items: NoteCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 18)),
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
            ).animate().fadeIn(delay: 50.ms).slideX(),

            const SizedBox(height: 16),

            // Contenu
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu sécurisé *',
                prefixIcon: Icon(Icons.lock_outline),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              minLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le contenu est requis';
                }
                return null;
              },
            ).animate().fadeIn(delay: 100.ms).slideX(),

            const SizedBox(height: 24),

            // Tags
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un tag',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms).slideX(),

            const SizedBox(height: 12),

            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                        ))
                    .toList(),
              ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // Bouton Sauvegarder
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Enregistrer' : 'Créer la note'),
              ),
            ).animate().fadeIn(delay: 250.ms).scale(),

            const SizedBox(height: 16),

            // Info de sécurité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cette note sera chiffrée avec AES-256-GCM',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
