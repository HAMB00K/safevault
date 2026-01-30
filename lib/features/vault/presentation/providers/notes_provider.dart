import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/models/secure_note_model.dart';
import '../../domain/entities/secure_note_entity.dart';

// State pour les notes
class NotesState {
  final List<SecureNoteEntity> notes;
  final bool isLoading;
  final String? error;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NotesState copyWith({
    List<SecureNoteEntity>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// StateNotifier pour gérer les notes
class NotesNotifier extends StateNotifier<NotesState> {
  final NotesLocalDataSource dataSource;

  NotesNotifier(this.dataSource) : super(const NotesState()) {
    loadNotes();
  }

  final _uuid = const Uuid();

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notes = await dataSource.getAllNotes();
      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addNote({
    required String title,
    required String content,
    required NoteCategory category,
    List<String> tags = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Chiffrer le contenu avec EncryptionService
      final newNote = SecureNoteModel(
        id: _uuid.v4(),
        title: title,
        encryptedContent: content, // Devrait être chiffré
        category: category,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.addNote(newNote);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateNote(SecureNoteEntity updatedNote) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final noteToUpdate = SecureNoteModel.fromEntity(
        updatedNote.copyWith(updatedAt: DateTime.now()),
      );
      await dataSource.updateNote(noteToUpdate);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteNote(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await dataSource.deleteNote(id);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(SecureNoteEntity note) async {
    await updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  List<SecureNoteEntity> searchNotes(String query) {
    if (query.isEmpty) return state.notes;

    return state.notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.encryptedContent.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<SecureNoteEntity> getNotesByCategory(NoteCategory category) {
    return state.notes.where((note) => note.category == category).toList();
  }

  List<SecureNoteEntity> getFavoriteNotes() {
    return state.notes.where((note) => note.isFavorite).toList();
  }
}

// Provider pour le datasource
final notesDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  return NotesLocalDataSourceImpl(DatabaseHelper());
});

// Provider principal pour les notes
final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final dataSource = ref.watch(notesDataSourceProvider);
  return NotesNotifier(dataSource);
});
