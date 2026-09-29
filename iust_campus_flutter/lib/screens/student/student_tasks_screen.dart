import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../services/mock_tasks_service.dart';
import '../../services/student_session.dart';
import '../../data/student_repository.dart';
import 'student_pomodoro_screen.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);
const _red       = Color(0xFFE53E3E);

extension _PriorityX on TaskPriority {
  String get label { switch(this) { case TaskPriority.high: return 'عالية'; case TaskPriority.medium: return 'متوسطة'; case TaskPriority.low: return 'منخفضة'; } }
  Color get color { switch(this) { case TaskPriority.high: return _red; case TaskPriority.medium: return _gold; case TaskPriority.low: return const Color(0xFF2E9B5F); } }
  Color get bg { switch(this) { case TaskPriority.high: return const Color(0xFFFFF0F0); case TaskPriority.medium: return _goldLight; case TaskPriority.low: return const Color(0xFFEDFAF1); } }
}

class StudentTasksScreen extends StatefulWidget {
  final Task? initialTask;
  final String? studentId;
  const StudentTasksScreen({super.key, this.initialTask, this.studentId});
  @override
  State<StudentTasksScreen> createState() => _StudentTasksScreenState();
}

class _StudentTasksScreenState extends State<StudentTasksScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  late TabController _tabs;

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    final tasks = await MockTasksService.getAllTasks(_studentId);
    if (mounted) setState(() => _tasks = tasks);
  }

  List<Task> get _today => _tasks.where((t) {
    final now = DateTime.now();
    return t.dueDate.year == now.year && t.dueDate.month == now.month && t.dueDate.day == now.day;
  }).toList();

  List<Task> get _week {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return _tasks.where((t) => t.dueDate.isAfter(now) || _sameDay(t.dueDate, now))
        .where((t) => t.dueDate.isBefore(weekEnd)).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _toggleComplete(Task t) async {
    await MockTasksService.toggleComplete(t.id, _studentId);
    await _load();
  }

  Future<void> _deleteTask(Task t) async {
    await MockTasksService.deleteTask(t.id, _studentId);
    await _load();
  }

  void _openTaskForm([Task? existing]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(
        existing: existing,
        studentId: _studentId,
        onSave: (task) async {
          if (existing == null) {
            await MockTasksService.addTask(task, _studentId);
          } else {
            await MockTasksService.updateTask(task, _studentId);
          }
          await _load();
        },
      ),
    );
  }

  void _openPomodoro(Task task) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => StudentPomodoroScreen(
        preselectedTask: task,
        studentId: _studentId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final completed = _today.where((t) => t.isCompleted).length;
    final total = _today.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(children: [
            // ── header ────────────────────────────────────────────────
            Container(
              color: _white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('مهامي', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: _textMain)),
                    Text('نظم يومك الدراسي', style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
                  ])),
                  GestureDetector(
                    onTap: () => _openTaskForm(),
                    child: Container(
                      width: 38, height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add_rounded, color: _white, size: 22),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // progress card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gold.withValues(alpha: 0.35)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.emoji_events_rounded, color: _gold, size: 18),
                      const SizedBox(width: 8),
                      Text('إنجاز اليوم', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
                      const Spacer(),
                      Text('$completed من $total مهام مكتملة',
                          style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: _gold.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                        minHeight: 8,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),

                // tabs
                TabBar(
                  controller: _tabs,
                  labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w500, fontSize: 13),
                  labelColor: _navy,
                  unselectedLabelColor: _textSub,
                  indicatorColor: _navy,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [Tab(text: 'اليوم'), Tab(text: 'الأسبوع')],
                ),
              ]),
            ),

            // ── task list ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _TaskList(tasks: _today, onToggle: _toggleComplete, onEdit: _openTaskForm, onDelete: _deleteTask, onPomodoro: _openPomodoro),
                  _TaskList(tasks: _week, onToggle: _toggleComplete, onEdit: _openTaskForm, onDelete: _deleteTask, onPomodoro: _openPomodoro),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── task list ──────────────────────────────────────────────────────────────
class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, required this.onToggle,
      required this.onEdit, required this.onDelete, required this.onPomodoro});
  final List<Task> tasks;
  final Future<void> Function(Task) onToggle;
  final void Function(Task) onEdit, onPomodoro;
  final Future<void> Function(Task) onDelete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.task_alt_rounded, size: 48, color: _border),
        const SizedBox(height: 12),
        Text('لا توجد مهام', style: GoogleFonts.cairo(color: _textSub, fontSize: 14)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskCard(
        task: tasks[i],
        onToggle: () => onToggle(tasks[i]),
        onEdit: () => onEdit(tasks[i]),
        onDelete: () => onDelete(tasks[i]),
        onPomodoro: () => onPomodoro(tasks[i]),
      ),
    );
  }
}

// ── task card ──────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onToggle,
      required this.onEdit, required this.onDelete, required this.onPomodoro});
  final Task task;
  final VoidCallback onToggle, onEdit, onDelete, onPomodoro;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: _red),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: task.isCompleted ? const Color(0xFFF8FAFC) : _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: task.isCompleted ? _border : _border),
          boxShadow: task.isCompleted ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // checkbox
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24, height: 24,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: task.isCompleted ? _navy : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: task.isCompleted ? _navy : _border, width: 2),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, color: _white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // text
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title,
                style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: task.isCompleted ? _textSub : _textMain,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
            if (task.courseName != null) ...[
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(5)),
                  child: Text(task.courseName!,
                      style: GoogleFonts.cairo(fontSize: 10, color: _blue, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: task.priority.bg, borderRadius: BorderRadius.circular(5)),
                  child: Text(task.priority.label,
                      style: GoogleFonts.cairo(fontSize: 10, color: task.priority.color, fontWeight: FontWeight.w600)),
                ),
              ]),
            ],
            if (task.estimatedMinutes > 0) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.timer_rounded, size: 12, color: _textSub),
                const SizedBox(width: 4),
                Text('${task.estimatedMinutes} دقيقة',
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
              ]),
            ],
          ])),

          // actions
          Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: onPomodoro,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _goldLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.timer_rounded, size: 16, color: _gold),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_rounded, size: 16, color: _blue),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── task form sheet ────────────────────────────────────────────────────────
class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.existing, required this.onSave, this.studentId});
  final Task? existing;
  final ValueChanged<Task> onSave;
  final String? studentId;
  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String? _courseId, _courseName;
  int _minutes     = 30;
  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueDate = DateTime.now();
  bool _saving = false;

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  List<({String id, String name})> get _courses =>
      StudentRepository.getAvailableCourseTuples(_studentId);

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _titleCtrl.text = t.title;
      _descCtrl.text  = t.description ?? '';
      _courseId       = t.courseId;
      _courseName     = t.courseName;
      _minutes        = t.estimatedMinutes;
      _priority       = t.priority;
      _dueDate        = t.dueDate;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final task = widget.existing != null
        ? widget.existing!.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            courseId: _courseId,
            courseName: _courseName,
            estimatedMinutes: _minutes,
            priority: _priority,
            dueDate: _dueDate,
          )
        : Task(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            studentId: _studentId,
            courseId: _courseId,
            courseName: _courseName,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            dueDate: _dueDate,
            estimatedMinutes: _minutes,
            priority: _priority,
            createdAt: DateTime.now(),
          );
    widget.onSave(task);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(top: 20, right: 16, left: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'إضافة مهمة' : 'تعديل المهمة',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
            const SizedBox(height: 14),

            _field(_titleCtrl, 'عنوان المهمة *'),
            const SizedBox(height: 10),
            _field(_descCtrl, 'وصف (اختياري)', maxLines: 2),
            const SizedBox(height: 10),

            // course
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              hint: Text('المادة (اختياري)', style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
              decoration: _inputDecoration('المادة'),
              items: [
                const DropdownMenuItem(value: null, child: Text('بدون مادة')),
                ..._courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: GoogleFonts.cairo(fontSize: 13)))),
              ],
              onChanged: (v) {
                final found = v == null ? null : _courses.firstWhere((c) => c.id == v);
                setState(() { _courseId = v; _courseName = found?.name; });
              },
            ),
            const SizedBox(height: 10),

            // priority
            Row(children: [
              Text('الأولوية:', style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
              const SizedBox(width: 10),
              ...TaskPriority.values.map((p) {
                final sel = _priority == p;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? p.bg : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? p.color : _border),
                      ),
                      child: Text(p.label, style: GoogleFonts.cairo(fontSize: 12, color: sel ? p.color : _textSub, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              }),
            ]),
            const SizedBox(height: 10),

            // minutes
            Row(children: [
              Text('الوقت المقدر:', style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.remove_rounded, size: 18), onPressed: () => setState(() => _minutes = (_minutes - 15).clamp(15, 300))),
              Text('$_minutes د', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
              IconButton(icon: const Icon(Icons.add_rounded, size: 18), onPressed: () => setState(() => _minutes = (_minutes + 15).clamp(15, 300))),
            ]),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy, foregroundColor: _white, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _white))
                    : Text('حفظ', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
        decoration: _inputDecoration(hint),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}
