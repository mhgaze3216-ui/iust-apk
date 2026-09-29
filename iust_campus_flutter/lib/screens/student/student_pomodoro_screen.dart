import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../services/mock_tasks_service.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';

const _navy      = Color(0xFF073B4C);
const _lightBg   = Color(0xFFF6F9FC);
const _gold      = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

enum _PomodoroMode { focus, shortBreak }

class StudentPomodoroScreen extends StatefulWidget {
  const StudentPomodoroScreen({super.key, this.preselectedTask, this.studentId});
  final Task? preselectedTask;
  final String? studentId;
  @override
  State<StudentPomodoroScreen> createState() => _StudentPomodoroScreenState();
}

class _StudentPomodoroScreenState extends State<StudentPomodoroScreen> {
  // settings
  int _focusMinutes  = 25;
  int _breakMinutes  = 5;

  // state
  _PomodoroMode _mode = _PomodoroMode.focus;
  bool  _running  = false;
  bool  _started  = false;
  int   _secondsLeft = 0;
  Timer? _timer;

  Task?   _task;
  String? _courseId, _courseName;
  DateTime? _sessionStart;

  // available tasks from mock
  List<Task> _availableTasks = [];

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  List<({String id, String name})> get _courses {
    return [
      (id: '', name: 'بدون مادة'),
      ...StudentRepository.getAvailableCourseTuples(_studentId),
    ];
  }

  @override
  void initState() {
    super.initState();
    _task     = widget.preselectedTask;
    _courseId = _task?.courseId;
    _courseName = _task?.courseName;
    _secondsLeft = _focusMinutes * 60;
    _loadTasks();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _loadTasks() async {
    final tasks = await MockTasksService.getAllTasks(_studentId);
    if (mounted) setState(() => _availableTasks = tasks);
  }

  // ── timer logic ────────────────────────────────────────────────────────
  void _start() {
    if (!_started) {
      _sessionStart = DateTime.now();
      _started = true;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _onTimerEnd();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running     = false;
      _started     = false;
      _mode        = _PomodoroMode.focus;
      _secondsLeft = _focusMinutes * 60;
      _sessionStart = null;
    });
  }

  void _onTimerEnd() {
    if (_mode == _PomodoroMode.focus) {
      _saveSession(completed: false);
      setState(() {
        _mode        = _PomodoroMode.shortBreak;
        _secondsLeft = _breakMinutes * 60;
        _running     = false;
      });
      _showSnack('انتهت جلسة التركيز! استرح قليلاً 🎉');
    } else {
      setState(() {
        _mode        = _PomodoroMode.focus;
        _secondsLeft = _focusMinutes * 60;
        _running     = false;
        _started     = false;
      });
      _showSnack('انتهت الاستراحة. مستعد للتركيز؟');
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _saveSession(completed: true);
    _showSnack('تم حفظ الجلسة بنجاح ✅');
    _reset();
  }

  Future<void> _saveSession({required bool completed}) async {
    if (_sessionStart == null) return;
    final session = StudySession(
      id: 'ss${DateTime.now().millisecondsSinceEpoch}',
      studentId: _studentId,
      courseId: _courseId?.isEmpty ?? true ? null : _courseId,
      courseName: _courseName,
      taskId: _task?.id,
      taskTitle: _task?.title,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      startedAt: _sessionStart!,
      endedAt: DateTime.now(),
      completed: completed,
    );
    await MockTasksService.saveSession(session, _studentId);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── display helpers ────────────────────────────────────────────────────
  String get _timeDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = _mode == _PomodoroMode.focus
        ? _focusMinutes * 60
        : _breakMinutes * 60;
    return total == 0 ? 0 : 1 - (_secondsLeft / total);
  }

  Color get _modeColor =>
      _mode == _PomodoroMode.focus ? _navy : const Color(0xFF2E9B5F);

  // ── build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(children: [
            // appbar
            Container(
              color: _white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                if (Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pomodoro', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
                    Text('جلسة تركيز', style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
                  ]),
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // ── task + course selectors ────────────────────────
                  if (!_started) _buildSelectors(),
                  if (_started && _task != null) _buildTaskBadge(),
                  const SizedBox(height: 16),

                  // ── mode pill ──────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: _mode == _PomodoroMode.focus ? _goldLight : const Color(0xFFEDFAF1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _mode == _PomodoroMode.focus ? 'تركيز 🧠' : 'استراحة ☕',
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: _modeColor),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── circular timer ─────────────────────────────────
                  SizedBox(
                    width: 240, height: 240,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 10,
                          backgroundColor: _border,
                          valueColor: AlwaysStoppedAnimation<Color>(_modeColor),
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_timeDisplay,
                            style: GoogleFonts.cairo(fontSize: 52, fontWeight: FontWeight.w800, color: _textMain)),
                        Text(_mode == _PomodoroMode.focus ? 'دقيقة تركيز' : 'دقيقة استراحة',
                            style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // ── controls ──────────────────────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // reset
                    _CircleBtn(
                      icon: Icons.refresh_rounded,
                      color: _textSub,
                      bgColor: _border.withValues(alpha: 0.5),
                      size: 52,
                      onTap: _reset,
                    ),
                    const SizedBox(width: 20),
                    // play/pause
                    _CircleBtn(
                      icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: _white,
                      bgColor: _modeColor,
                      size: 72,
                      onTap: _running ? _pause : _start,
                    ),
                    const SizedBox(width: 20),
                    // complete
                    _CircleBtn(
                      icon: Icons.check_rounded,
                      color: _started ? _white : _textSub,
                      bgColor: _started ? const Color(0xFF2E9B5F) : _border.withValues(alpha: 0.5),
                      size: 52,
                      onTap: _started ? _completeSession : null,
                    ),
                  ]),
                  const SizedBox(height: 32),

                  // ── settings (only when not started) ──────────────
                  if (!_started) _buildSettings(),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTaskBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _goldLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.task_alt_rounded, color: _gold, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_task!.title, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
          if (_task!.courseName != null)
            Text(_task!.courseName!, style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
        ])),
      ]),
    );
  }

  Widget _buildSelectors() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // task
      DropdownButtonFormField<String>(
        initialValue: _task?.id,
        hint: Text('اختر مهمة (اختياري)', style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
        decoration: _inputDecoration('المهمة'),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('بدون مهمة')),
          ..._availableTasks.map((t) => DropdownMenuItem(
              value: t.id,
              child: Text(t.title, style: GoogleFonts.cairo(fontSize: 13)))),
        ],
        onChanged: (v) {
          final found = v == null ? null : _availableTasks.firstWhere((t) => t.id == v);
          setState(() {
            _task = found;
            _courseId   = found?.courseId;
            _courseName = found?.courseName;
          });
        },
      ),
      const SizedBox(height: 10),
      // course (independent)
      DropdownButtonFormField<String>(
        initialValue: _courseId ?? '',
        decoration: _inputDecoration('المادة (اختياري)'),
        items: _courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: GoogleFonts.cairo(fontSize: 13)))).toList(),
        onChanged: (v) {
          final found = v == null || v.isEmpty ? null : _courses.firstWhere((c) => c.id == v);
          setState(() { _courseId = v; _courseName = found?.name; });
        },
      ),
    ]);
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('الإعدادات', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
        const SizedBox(height: 12),
        _durationRow('مدة التركيز', _focusMinutes, (v) {
          setState(() { _focusMinutes = v; if (_mode == _PomodoroMode.focus) _secondsLeft = v * 60; });
        }),
        const SizedBox(height: 8),
        _durationRow('مدة الاستراحة', _breakMinutes, (v) {
          setState(() { _breakMinutes = v; if (_mode == _PomodoroMode.shortBreak) _secondsLeft = v * 60; });
        }),
      ]),
    );
  }

  Widget _durationRow(String label, int value, ValueChanged<int> onChange) =>
      Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.cairo(fontSize: 13, color: _textSub))),
        IconButton(icon: const Icon(Icons.remove_rounded, size: 18), onPressed: () => onChange((value - 5).clamp(5, 90))),
        Text('$value د', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
        IconButton(icon: const Icon(Icons.add_rounded, size: 18), onPressed: () => onChange((value + 5).clamp(5, 90))),
      ]);

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(fontSize: 13, color: _textSub),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.color, required this.bgColor, required this.size, this.onTap});
  final IconData icon;
  final Color color, bgColor;
  final double size;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size, height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: size * 0.42),
        ),
      );
}
