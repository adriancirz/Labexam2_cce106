import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// Service class responsible for handling all Cloud Firestore CRUD operations.
class FirestoreService {
  /// Reference to the 'tasks' collection in Firebase Firestore.
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  /// [CREATE OPERATION]
  /// Adds a new task to Cloud Firestore.
  /// Validates that the input is non-empty before writing to the database.
  Future<void> addTask(String taskText) async {
    final trimmedText = taskText.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Task description cannot be empty.');
    }

    await _tasksCollection.add({
      'task': trimmedText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// [READ OPERATION]
  /// Listens to real-time updates from Cloud Firestore and yields a list of [TaskModel].
  /// Documents are sorted with newest items at the top.
  Stream<List<TaskModel>> getTasksStream() {
    return _tasksCollection.snapshots().map((snapshot) {
      final tasks =
          snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();

      // Sort by creation date descending (newest first).
      // If createdAt is still pending from serverTimestamp, treat it as most recent.
      tasks.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1; // null = just created, place at top
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return tasks;
    });
  }

  /// [UPDATE OPERATION]
  /// Updates an existing task document in Cloud Firestore with new text and an updatedAt timestamp.
  Future<void> updateTask(String docId, String updatedText) async {
    final trimmedText = updatedText.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Task description cannot be empty.');
    }

    await _tasksCollection.doc(docId).update({
      'task': trimmedText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// [DELETE OPERATION]
  /// Removes a task document from Cloud Firestore by its unique document ID.
  Future<void> deleteTask(String docId) async {
    await _tasksCollection.doc(docId).delete();
  }
}
