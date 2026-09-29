import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  late String _selectedDepartment;
  late String _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String _selectedTimeSlot = '10:00 صباحاً';
  bool _isDateStep = false;
  bool _isBooking = false;

  final List<String> _timeSlots = [
    '09:00 صباحاً',
    '10:00 صباحاً',
    '11:30 صباحاً',
    '01:00 مساءً',
    '02:30 مساءً',
  ];

  @override
  void initState() {
    super.initState();
    final departments = UniversityServicesRepository.departments;
    _selectedDepartment = departments.isEmpty ? '' : departments.first.name;
    _selectedService = departments.isEmpty || departments.first.services.isEmpty
        ? ''
        : departments.first.services.first;
  }

  void _onDepartmentChanged(String newDept) {
    UniversityDepartment? department;
    for (final item in UniversityServicesRepository.departments) {
      if (item.name == newDept) {
        department = item;
        break;
      }
    }
    setState(() {
      _selectedDepartment = newDept;
      _selectedService = department == null || department.services.isEmpty
          ? ''
          : department.services.first;
    });
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    try {
      await UniversityServicesRepository.addAppointment(
        department: _selectedDepartment,
        service: _selectedService,
        date: _selectedDate.toIso8601String().substring(0, 10),
        time: _selectedTimeSlot,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تأكيد طلب حجز الموعد بنجاح',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر حجز الموعد: $error')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    UniversityDepartment? currentDeptObj;
    for (final department in UniversityServicesRepository.departments) {
      if (department.name == _selectedDepartment) {
        currentDeptObj = department;
        break;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'حجز موعد جديد',
                subtitle: 'إدارة المواعيد والمراجعات مع الإدارات الجامعية',
                showBackButton: true,
                onBack: () {
                  if (_isDateStep) {
                    setState(() => _isDateStep = false);
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // Step Indicator
                    Row(
                      children: [
                        _buildStepIndicator(
                          1,
                          'اختيار الجهة والخدمة',
                          !_isDateStep,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: _isDateStep ? _navy : _border,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStepIndicator(2, 'الموعد والوقت', _isDateStep),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (!_isDateStep) ...[
                      // Description Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBCE0F7)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: _blue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'اختر القسم والجهة والخدمة المطلوبة لمتابعة عملية حجز الموعد وتنسيق المقابلة مسبقاً.',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: _navy,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Department Selection
                      Text(
                        'الجهة / الإدارة المختصة *',
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
                            value:
                                UniversityServicesRepository.departments.any(
                                  (dept) => dept.name == _selectedDepartment,
                                )
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
                            items: UniversityServicesRepository.departments.map(
                              (dept) {
                                return DropdownMenuItem<String>(
                                  value: dept.name,
                                  child: Text(dept.name),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              if (val != null) _onDepartmentChanged(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Selection
                      Text(
                        'نوع الخدمة / الغرض من الموعد *',
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
                            value:
                                currentDeptObj?.services.contains(
                                      _selectedService,
                                    ) ==
                                    true
                                ? _selectedService
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
                            items:
                                (currentDeptObj?.services ?? const <String>[])
                                    .map((srv) {
                                      return DropdownMenuItem<String>(
                                        value: srv,
                                        child: Text(srv),
                                      );
                                    })
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedService = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Next Step Button
                      ElevatedButton(
                        onPressed: () => setState(() => _isDateStep = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'متابعة اختيار التاريخ والوقت',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Date & Time Selection Step
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ملخص الحجز:',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_selectedDepartment - $_selectedService',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _blue,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: Color(0xFFEDF2F7)),
                            const SizedBox(height: 10),

                            // Calendar Picker Trigger
                            Text(
                              'تاريخ الموعد المفضل:',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _navy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 60),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      color: _blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${_selectedDate.day} / ${_selectedDate.month} / ${_selectedDate.year}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _textMain,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'تعديل',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: _blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Available Timeslots
                            Text(
                              'الأوقات المتاحة:',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _navy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _timeSlots.map((slot) {
                                final isSelected = _selectedTimeSlot == slot;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _selectedTimeSlot = slot),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? _navy : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? _navy : _border,
                                      ),
                                    ),
                                    child: Text(
                                      slot,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : _textMain,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirm Button
                      ElevatedButton(
                        onPressed:
                            _isBooking ||
                                _selectedDepartment.isEmpty ||
                                _selectedService.isEmpty
                            ? null
                            : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isBooking
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تأكيد حجز الموعد',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? _navy : const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$step',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? _navy : _textSub,
          ),
        ),
      ],
    );
  }
}
