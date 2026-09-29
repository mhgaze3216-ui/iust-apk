import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/doctor_session.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorEditProfileScreen extends StatefulWidget {
  const DoctorEditProfileScreen({super.key});

  @override
  State<DoctorEditProfileScreen> createState() =>
      _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState extends State<DoctorEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _officeController;

  @override
  void initState() {
    super.initState();
    final profile = DoctorSession.currentProfile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email ?? '');
    _officeController = TextEditingController(text: profile.office ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final office = _officeController.text.trim();

    try {
      await DoctorSession.updateCurrentProfile(office: office);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحديث البيانات: $error',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث البيانات بنجاح', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF2E9B5F),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = DoctorSession.currentProfile;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        safeDoctorPop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          centerTitle: true,
          leading: const DoctorBackButton(),
          title: Text(
            'تعديل البيانات',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Editable fields card
              Text(
                'البيانات القابلة للتعديل',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSub,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'الاسم الكامل',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'البريد الإلكتروني الرسمي',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'المكتب الأكاديمي',
                      controller: _officeController,
                      icon: Icons.meeting_room_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Institution controlled read-only fields
              Text(
                'بيانات الجامعة والتعيين (للقراءة فقط)',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSub,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildReadOnlyRow(
                      label: 'الرقم الوظيفي',
                      value: profile.doctorId,
                    ),
                    const Divider(height: 20, color: _border),
                    _buildReadOnlyRow(
                      label: 'الصفة / الدور',
                      value: 'عضو هيئة تدريسية',
                    ),
                    const Divider(height: 20, color: _border),
                    _buildReadOnlyRow(label: 'الكلية', value: profile.faculty),
                    const Divider(height: 20, color: _border),
                    _buildReadOnlyRow(
                      label: 'القسم الأكاديمي',
                      value: profile.department,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'حفظ التعديلات',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: GoogleFonts.cairo(fontSize: 14, color: _textMain),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _blue, size: 20),
            filled: true,
            fillColor: _lightBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value.isNotEmpty ? value : 'غير متوفر',
            textAlign: TextAlign.start,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
