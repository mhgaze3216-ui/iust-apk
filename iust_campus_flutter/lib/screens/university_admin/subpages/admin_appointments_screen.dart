import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';
import 'admin_new_appointment_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _gold = Color(0xFFF5B82E);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  int _selectedTab = 0; // 0: القادمة, 1: السابقة

  List<AdminAppointmentItem> get _upcoming =>
      UniversityAdminRepository.appointments.where((a) => a.isUpcoming).toList();

  List<AdminAppointmentItem> get _past =>
      UniversityAdminRepository.appointments.where((a) => !a.isUpcoming).toList();

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0 ? _upcoming : _past;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              UniversityAdminHeader(
                title: 'المواعيد الإدارية',
                subtitle: 'تنظيم المواعيد والمراجعات مع الطلاب والأساتذة',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // Compact Action Bar: Simple Filter + Small Navy Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Simple Filter Row (القادمة / السابقة)
                    Row(
                      children: [
                        _buildFilterTab(
                          label: 'القادمة',
                          count: _upcoming.length,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 18),
                        _buildFilterTab(
                          label: 'السابقة',
                          count: _past.length,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ],
                    ),

                    // Small rounded navy button (+ موعد جديد)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminNewAppointmentScreen()),
                        );
                        if (res == true) setState(() {});
                      },
                      icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      label: Text(
                        'موعد جديد',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Appointment List Starts Immediately
              Expanded(
                child: currentList.isEmpty
                    ? Center(
                        child: Text(
                          _selectedTab == 0
                              ? 'لا توجد مواعيد قادمة مجدولة'
                              : 'لا توجد مواعيد سابقة مسجلة',
                          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                        itemCount: currentList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final apt = currentList[index];
                          return _buildAppointmentCard(apt);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              '$label ($count)',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? _navy : _textSub,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2.5,
            width: 28,
            decoration: BoxDecoration(
              color: isSelected ? _gold : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AdminAppointmentItem apt) {
    final isConfirmed = apt.status == 'مؤكد';
    final isPending = apt.status == 'قيد الانتظار';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP ROW: Title + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  apt.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFFEDFAF1)
                      : isPending
                          ? const Color(0xFFFDF2E9)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.status,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isConfirmed
                        ? const Color(0xFF16A34A)
                        : isPending
                            ? const Color(0xFFE67E22)
                            : _textSub,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. SECOND ROW: Person Icon + Person Name + Department Chip (Using Wrap to prevent overflow)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline_rounded, size: 15, color: _blue),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${apt.userRole}: ${apt.userName}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: _textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.department,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 3. THIRD ROW: Reason
          Text(
            'السبب: ${apt.reason}',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: _textSub,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDF2F7)),
          const SizedBox(height: 10),

          // 4. BOTTOM ROW: Date + Time
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: _blue),
              const SizedBox(width: 5),
              Text(
                apt.date,
                style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, size: 13, color: _blue),
              const SizedBox(width: 5),
              Text(
                apt.time,
                style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
              ),
            ],
          ),

          // 5. FINAL LINE: Notes (if any)
          if (apt.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F9FC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'ملاحظات: ${apt.notes}',
                style: GoogleFonts.cairo(fontSize: 11.5, color: _blue, height: 1.3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
