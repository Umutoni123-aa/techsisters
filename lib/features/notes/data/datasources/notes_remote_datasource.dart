import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

/// Talks to the `notes` collection in Cloud Firestore. This is the only
/// class in the feature that uses the Firestore API.
///
/// Errors are not caught here; [NotesRepositoryImpl] turns them into
/// friendly messages.
class NotesRemoteDataSource {
  NotesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection('notes');

  /// The learner's notes, newest first. Needs the composite index in
  /// firestore.indexes.json (userId ascending, updatedAt descending).
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _notes
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addNote({
    required String userId,
    String? lessonId,
    required String title,
    required String content,
  }) {
    // lessonId is always written (null when not linked) so every document
    // has the same fields as the ERD.
    return _notes.add({
      'userId': userId,
      'lessonId': lessonId,
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Only title, content and updatedAt change. The security rules do not
  /// allow userId, lessonId or createdAt to change after creation.
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    return _notes.doc(noteId).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) => _notes.doc(noteId).delete();
}
