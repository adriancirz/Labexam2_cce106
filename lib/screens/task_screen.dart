import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// The main single-page screen for the Task / Food List application.
/// Displays an AppBar, an input TextField with an Add Button, and a real-time Task List.
class TaskScreen extends StatefulWidget {
  /// Default title matching the exam template ("Labexam2_Lastname").
  /// Can be set to "Labexam2_Ponce" if required by the instructor.
  final String title;

  const TaskScreen({
    super.key,
    this.title = 'Labexam2_Ponce',
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Service instance to communicate with Cloud Firestore
  final FirestoreService _firestoreService = FirestoreService();

  // Text controller for the new task input field
  final TextEditingController _taskController = TextEditingController();

  // Loading state while adding a task
  bool _isAdding = false;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  /// [CREATE ACTION]
  /// Validates input and triggers Firestore create operation.
  Future<void> _addTask() async {
    final text = _taskController.text.trim();

    // Input validation: prevent empty or whitespace-only tasks
    if (text.isEmpty) {
      _showSnackBar(
        message: 'Please enter a task before adding.',
        isError: true,
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      await _firestoreService.addTask(text);
      _taskController.clear();
      _showSnackBar(message: 'Task added successfully!');
    } catch (e) {
      _showSnackBar(
        message: 'Failed to add task: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  /// [UPDATE ACTION]
  /// Displays an AlertDialog to edit the task, with validation.
  void _showEditDialog(TaskModel task) {
    final editController = TextEditingController(text: task.task);
    String? validationError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Edit Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Enter updated task...',
                      errorText: validationError,
                      filled: true,
                      fillColor: const Color(0xFFECEFF1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      if (validationError != null && value.trim().isNotEmpty) {
                        setDialogState(() => validationError = null);
                      }
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E627C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    final updatedText = editController.text.trim();
                    if (updatedText.isEmpty) {
                      setDialogState(() {
                        validationError = 'Task cannot be empty.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext);

                    try {
                      await _firestoreService.updateTask(task.id, updatedText);
                      _showSnackBar(message: 'Task updated successfully!');
                    } catch (e) {
                      _showSnackBar(
                        message: 'Failed to update task: ${e.toString()}',
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// [DELETE ACTION]
  /// Displays a confirmation dialog before deleting the task from Firestore.
  void _showDeleteConfirmationDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${task.task}"?',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _firestoreService.deleteTask(task.id);
                  _showSnackBar(message: 'Task deleted successfully!');
                } catch (e) {
                  _showSnackBar(
                    message: 'Failed to delete task: ${e.toString()}',
                    isError: true,
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Helper to display modern floating SnackBars for user feedback.
  void _showSnackBar({required String message, bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor:
            isError ? const Color(0xFFE53E3E) : const Color(0xFF0E627C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Top Input Section (TextField + Add Button)
                _buildInputSection(),

                const SizedBox(height: 12),

                // Real-time Task List [READ OPERATION]
                Expanded(
                  child: _buildTaskList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top section with input TextField and Add Button.
  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Input TextField
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _taskController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
                decoration: const InputDecoration(
                  hintText: 'Add a new task...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _addTask(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Add Button
          Material(
            color: const Color(0xFF0E627C),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _isAdding ? null : _addTask,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                child: _isAdding
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the real-time list of tasks using StreamBuilder.
  Widget _buildTaskList() {
    return StreamBuilder<List<TaskModel>>(
      stream: _firestoreService.getTasksStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0E627C),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Color(0xFFE53E3E),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Error connecting to Firestore',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        // Empty state
        if (tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add your first task using the input field above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // List of task cards matching the provided UI
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskCard(task);
          },
        );
      },
    );
  }

  /// Builds an individual Task Card matching the screenshot styling.
  Widget _buildTaskCard(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Task Title
          Expanded(
            child: Text(
              task.task,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Edit Button (Pencil Icon)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF64748B),
              size: 20,
            ),
            tooltip: 'Edit Task',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => _showEditDialog(task),
          ),

          const SizedBox(width: 8),

          // Delete Button (Trash Icon)
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
              size: 20,
            ),
            tooltip: 'Delete Task',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => _showDeleteConfirmationDialog(task),
          ),
        ],
      ),
    );
  }
}
