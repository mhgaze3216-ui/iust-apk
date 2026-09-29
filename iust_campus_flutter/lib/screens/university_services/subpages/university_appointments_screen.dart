import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';
import 'new_appointment_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityAppointmentsScreen extends StatefulWidget {
  const UniversityAppointmentsScreen({super.key});

  @override
  State<UniversityAppointmentsScreen> createState() => _UniversityAppointmentsScreenState();
}

class _UniversityAppointmentsScreenState extends State<UniversityAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UniversityAppointment> get _upcomingAppointments {
    return UniversityServicesRepository.appointments.where((a) {
      return a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.pending;
    }).toList();
  }

  List<UniversityAppointment> get _pastAppointments {
    return UniversityServicesRepository.appointments.where((a) {
      return a.status == AppointmentStatus.completed || a.status == AppointmentStatus.cancelled;
    }).toList();
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
              UniversityServicesHeader(
                title: 'مواعيدي',
                subtitle: 'إدارة مواعيدك مع الجهات الإدارية في الجامعة',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // Action Banner: New Appointment
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: InkWell(
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewAppointmentScreen()),
                    );
                    if (res == true) setState(() {});
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حجز موعد إداري جديد',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'اختر الإدارة المناسبة والوقت الملائم لمراجعتك',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: _textSub,
                  labelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
                  tabs: const [
                    Tab(text: 'المواعيد القادمة'),
                    Tab(text: 'المواعيد السابقة'),
                  ],
                ),
              ),

              // Tabs content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(_upcomingAppointments, 'لا توجد مواعيد قادمة مسجلة حالياً'),
                    _buildAppointmentsList(_pastAppointments, 'لا توجد مواعيد سابقة مسجلة'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<UniversityAppointment> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              emptyMsg,
              style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final apt = list[index];

        return Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      apt.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: apt.statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      apt.statusLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: apt.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'الغرض: ${apt.purpose}',
                style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFEDF2F7)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: _blue),
                  const SizedBox(width: 6),
                  Text(
                    apt.date,
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time_rounded, size: 14, color: _blue),
                  const SizedBox(width: 4),
                  Text(
                    apt.time,
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: _textSub),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      apt.office,
                      style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
