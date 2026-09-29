import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminNewAppointmentScreen extends StatefulWidget {
  const AdminNewAppointmentScreen({super.key});

  @override
  State<AdminNewAppointmentScreen> createState() =>
      _AdminNewAppointmentScreenState();
}

class _AdminNewAppointmentScreenState extends State<AdminNewAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> get _departments => UniversityAdminRepository.departmentNames;
  late String _selectedDepartment;
  String _userRole = 'طالب';
  final TextEditingController _userNameCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 صباحاً';

  final List<String> _times = [
    '09:00 صباحاً',
    '10:00 صباحاً',
    '11:30 صباحاً',
    '01:00 مساءً',
    '02:00 مساءً',
    '03:00 مساءً',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDepartment = _departments.isEmpty ? '' : _departments.first;
  }

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _titleCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    final dateStr =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    try {
      await UniversityAdminRepository.addAppointment(
        title: _titleCtrl.text.trim(),
        userName: _userNameCtrl.text.trim(),
        userRole: _userRole,
        reason: _reasonCtrl.text.trim(),
        department: _selectedDepartment,
        date: dateStr,
        time: _selectedTime,
        notes: _notesCtrl.text.trim(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر تسجيل الموعد: $error')));
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تسجيل وحفظ الموعد الإداري بنجاح',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'تسجيل موعد إداري',
                subtitle: 'جدولة موعد مراجعة مع الطلاب أو الأساتذة أو الموظفين',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      // Department
                      Text(
                        'الجهة / القسم الإداري *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _departments.contains(_selectedDepartment)
                                ? _selectedDepartment
                                : null,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _navy,
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMain,
                            ),
                            items: _departments
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedDepartment = v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // User Role Chips
                      Text(
                        'فئة المستخدم *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: ['طالب', 'هيئة تدريسية', 'موظف'].map((role) {
                          final isSel = _userRole == role;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(
                                role,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: isSel ? Colors.white : _textMain,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: _navy,
                              backgroundColor: Colors.white,
                              onSelected: (_) =>
                                  setState(() => _userRole = role),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // User Name
                      Text(
                        'اسم المستخدم أو الرقم الجامعي *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _userNameCtrl,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى إدخال اسم المستخدم'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'مثال: أحمد السالم أو 20251042',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title & Reason
                      Text(
                        'عنوان الموعد والغرض منه *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleCtrl,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        decoration: InputDecoration(
                          hintText: 'مثال: لقاء مع شؤون الطلاب',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _reasonCtrl,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى ذكر سبب المقابلة'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'سبب المقابلة بالتفصيل...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Date Picker
                      Text(
                        'تاريخ الموعد *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                                color: _blue,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_selectedDate.day} / ${_selectedDate.month} / ${_selectedDate.year}',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'تغيير',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: _blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Time Slot
                      Text(
                        'الوقت المحدد *',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _times.map((t) {
                          final isSel = _selectedTime == t;
                          return InkWell(
                            onTap: () => setState(() => _selectedTime = t),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSel ? _navy : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel ? _navy : _border,
                                ),
                              ),
                              child: Text(
                                t,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSel ? Colors.white : _textMain,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Notes
                      Text(
                        'ملاحظات إضافية للموعد',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _textMain,
                        ),
                        decoration: InputDecoration(
                          hintText: 'قاعة المقابلة أو شروط الحضور...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _textSub,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'حفظ وتأكيد الموعد',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
