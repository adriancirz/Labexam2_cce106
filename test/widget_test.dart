import 'package:flutter_test/flutter_test.dart';
import 'package:labexam2_ponce/models/task_model.dart';

void main() {
  group('TaskModel Unit Tests', () {
    test('TaskModel creates and maps correctly', () {
      final task = TaskModel(
        id: 'test-id-123',
        task: 'Finish Flutter Assignment',
      );

      expect(task.id, 'test-id-123');
      expect(task.task, 'Finish Flutter Assignment');

      final map = task.toMap();
      expect(map['task'], 'Finish Flutter Assignment');
      expect(map.containsKey('createdAt'), isTrue);
    });
  });
}
