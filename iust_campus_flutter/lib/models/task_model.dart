// ── Task + StudySession data models ──────────────────────────────────────
// Designed to be replaced with real NestJS API when backend is connected.

enum TaskStatus { pending, completed }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String studentId;
  final String? courseId;
  final String? courseName;
  String title;
  String? description;
  DateTime dueDate;
  int estimatedMinutes;
  TaskPriority priority;
  TaskStatus status;
  DateTime? completedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.studentId,
    this.courseId,
    this.courseName,
    required this.title,
    this.description,
    required this.dueDate,
    this.estimatedMinutes = 30,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.completedAt,
    required this.createdAt,
  });

  bool get isCompleted => status == TaskStatus.completed;

  Task copyWith({
    String? title,
    String? description,
    String? courseId,
    String? courseName,
    DateTime? dueDate,
    int? estimatedMinutes,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? completedAt,
  }) =>
      Task(
        id: id,
        studentId: studentId,
        courseId: courseId ?? this.courseId,
        courseName: courseName ?? this.courseName,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
      );
}

class StudySession {
  final String id;
  final String studentId;
  final String? courseId;
  final String? courseName;
  final String? taskId;
  final String? taskTitle;
  final int focusMinutes;
  final int breakMinutes;
  final DateTime startedAt;
  DateTime? endedAt;
  bool completed;

  StudySession({
    required this.id,
    required this.studentId,
    this.courseId,
    this.courseName,
    this.taskId,
    this.taskTitle,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.startedAt,
    this.endedAt,
    this.completed = false,
  });
}
