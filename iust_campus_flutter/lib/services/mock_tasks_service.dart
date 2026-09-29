import '../models/task_model.dart';
import '../data/student_repository.dart';
import 'api_client.dart';
import 'student_session.dart';

class MockTasksService {
  static final Map<String, List<Task>> _cache = {};
  static final Map<String, List<StudySession>> _sessionCache = {};

  static String _resolveStudentId([String? studentId]) =>
      studentId ?? StudentSession.currentStudentId;

  static Map<String, dynamic> _unwrap(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  static Task _taskFromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        studentId: (json['studentId'] as String?) ?? StudentSession.currentStudentId,
        courseId: json['courseId'] as String?,
        courseName: json['courseName'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['dueAt'] as String),
        estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 30,
        priority: TaskPriority.values.firstWhere(
          (value) => value.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        status: TaskStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => TaskStatus.pending,
        ),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static StudySession _sessionFromJson(Map<String, dynamic> json) =>
      StudySession(
        id: json['id'] as String,
        studentId: (json['studentId'] as String?) ?? StudentSession.currentStudentId,
        courseId: json['courseId'] as String?,
        taskId: json['taskId'] as String?,
        focusMinutes: (json['focusMinutes'] as num).toInt(),
        breakMinutes: (json['breakMinutes'] as num).toInt(),
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] == null
            ? null
            : DateTime.parse(json['endedAt'] as String),
        completed: json['completed'] as bool? ?? false,
      );

  static Future<List<Task>> _loadTasks([String? studentId]) async {
    final sid = _resolveStudentId(studentId);
    final response = await ApiClient.instance.get('/students/me/tasks');
    final rows = response['data'];
    if (rows is! List) {
      throw const ApiException(502, 'INVALID_RESPONSE', 'Task list is invalid.');
    }
    final tasks = rows
        .map((row) => _taskFromJson(_unwrap(row)))
        .toList(growable: false);
    _cache[sid] = tasks;
    return tasks;
  }

  static Future<List<Task>> getTodayTasks([String? studentId]) async {
    final tasks = await _loadTasks(studentId);
    final now = DateTime.now();
    return tasks.where((task) =>
      task.dueDate.year == now.year &&
      task.dueDate.month == now.month &&
      task.dueDate.day == now.day).toList();
  }

  static Future<List<Task>> getAllTasks([String? studentId]) =>
      _loadTasks(studentId);

  static int getTodayCompletedCount([String? studentId]) {
    final sid = _resolveStudentId(studentId);
    final now = DateTime.now();
    return (_cache[sid] ?? const <Task>[]).where((task) =>
      task.isCompleted &&
      task.dueDate.year == now.year &&
      task.dueDate.month == now.month &&
      task.dueDate.day == now.day).length;
  }

  static int get todayCompletedCount => getTodayCompletedCount();

  static int getTodayTotalCount([String? studentId]) {
    final sid = _resolveStudentId(studentId);
    final now = DateTime.now();
    return (_cache[sid] ?? const <Task>[]).where((task) =>
      task.dueDate.year == now.year &&
      task.dueDate.month == now.month &&
      task.dueDate.day == now.day).length;
  }

  static int get todayTotalCount => getTodayTotalCount();

  static List<({String id, String name})> getAvailableCourses([String? studentId]) {
    final sid = _resolveStudentId(studentId);
    return StudentRepository.getAvailableCourseTuples(sid);
  }

  static List<({String id, String name})> get availableCourses =>
      getAvailableCourses();

  static String get currentStudentId => StudentSession.currentStudentId;

  static Future<Task> addTask(Task task, [String? studentId]) async {
    final response = await ApiClient.instance.post(
      '/students/me/tasks',
      body: {
        'courseId': task.courseId,
        'title': task.title,
        'description': task.description,
        'dueAt': task.dueDate.toUtc().toIso8601String(),
        'estimatedMinutes': task.estimatedMinutes,
        'priority': task.priority.name,
      },
    );
    final created = _taskFromJson(response);
    await _loadTasks(studentId);
    return created;
  }

  static Future<void> updateTask(Task updated, [String? studentId]) async {
    await ApiClient.instance.patch(
      '/students/me/tasks/${Uri.encodeComponent(updated.id)}',
      body: {
        'courseId': updated.courseId,
        'title': updated.title,
        'description': updated.description,
        'dueAt': updated.dueDate.toUtc().toIso8601String(),
        'estimatedMinutes': updated.estimatedMinutes,
        'priority': updated.priority.name,
        'status': updated.status.name,
      },
    );
    await _loadTasks(studentId);
  }

  static Future<void> deleteTask(String id, [String? studentId]) async {
    await ApiClient.instance.delete(
      '/students/me/tasks/${Uri.encodeComponent(id)}',
    );
    await _loadTasks(studentId);
  }

  static Future<void> toggleComplete(String id, [String? studentId]) async {
    final sid = _resolveStudentId(studentId);
    final tasks = await _loadTasks(sid);
    final task = tasks.firstWhere((value) => value.id == id);
    await updateTask(
      task.copyWith(
        status: task.isCompleted ? TaskStatus.pending : TaskStatus.completed,
        completedAt: task.isCompleted ? null : DateTime.now(),
      ),
      sid,
    );
  }

  static Future<void> saveSession(StudySession session, [String? studentId]) async {
    await ApiClient.instance.post(
      '/students/me/study-sessions',
      body: {
        'courseId': session.courseId,
        'taskId': session.taskId,
        'focusMinutes': session.focusMinutes,
        'breakMinutes': session.breakMinutes,
        'startedAt': session.startedAt.toUtc().toIso8601String(),
        'endedAt': session.endedAt?.toUtc().toIso8601String(),
        'completed': session.completed,
      },
    );
    await _loadSessions(studentId);
  }

  static Future<List<StudySession>> _loadSessions([String? studentId]) async {
    final sid = _resolveStudentId(studentId);
    final response = await ApiClient.instance.get('/students/me/study-sessions');
    final rows = response['data'];
    if (rows is! List) {
      throw const ApiException(502, 'INVALID_RESPONSE', 'Study session list is invalid.');
    }
    final sessions = rows
        .map((row) => _sessionFromJson(_unwrap(row)))
        .toList(growable: false);
    _sessionCache[sid] = sessions;
    return sessions;
  }

  static Future<List<StudySession>> getSessions([String? studentId]) =>
      _loadSessions(studentId);

  static List<StudySession> get sessions =>
      List.unmodifiable(_sessionCache[currentStudentId] ?? const []);
}
