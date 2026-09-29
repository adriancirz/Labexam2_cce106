import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Task item in the Food/Task List application.
class TaskModel {
  /// Unique document ID from Firestore.
  final String id;

  /// The task description / food item name.
  final String task;

  /// Timestamp when the task was created.
  final DateTime? createdAt;

  /// Timestamp when the task was last updated.
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.task,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to instantiate a [TaskModel] from Firestore [DocumentSnapshot].
  /// Supports 'task', 'title', or 'name' fields for maximum compatibility.
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final taskText = data['task'] as String? ??
        data['title'] as String? ??
        data['name'] as String? ??
        '';

    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      }
      return null;
    }

    return TaskModel(
      id: doc.id,
      task: taskText,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  /// Converts the model to a Map representation for Firestore creation.
  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
