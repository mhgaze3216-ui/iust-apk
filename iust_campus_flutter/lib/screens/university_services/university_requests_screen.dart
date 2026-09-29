import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/university_services_demo_data.dart';
import 'widgets/university_services_header.dart';
import 'subpages/university_request_details_screen.dart';
import 'subpages/new_inquiry_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityRequestsScreen extends StatefulWidget {
  final bool showBackButton;

  const UniversityRequestsScreen({super.key, this.showBackButton = false});

  @override
  State<UniversityRequestsScreen> createState() => _UniversityRequestsScreenState();
}

class _UniversityRequestsScreenState extends State<UniversityRequestsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = 'الكل';

  static const List<String> _statuses = [
    'الكل',
    'جديد',
    'قيد المراجعة',
    'مكتمل',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UniversityRequest> get _filteredRequests {
    final query = _searchCtrl.text.trim().toLowerCase();
    return UniversityServicesRepository.requests.where((req) {
      final matchesStatus = _selectedStatus == 'الكل' || req.statusLabel == _selectedStatus;
      final matchesQuery = query.isEmpty ||
          req.id.toLowerCase().contains(query) ||
          req.title.toLowerCase().contains(query) ||
          req.department.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRequests;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'طلباتي الإدارية',
                showBackButton: widget.showBackButton || Navigator.canPop(context),
                onBack: () => Navigator.of(context).maybePop(),
              ),

              // Search Box & New Request CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                          decoration: InputDecoration(
                            hintText: 'ابحث برقم الطلب أو العنوان...',
                            hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                            prefixIcon: const Icon(Icons.search_rounded, color: _blue, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: _textSub),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NewInquiryScreen()),
                        );
                        if (res == true) setState(() {});
                      },
                      icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      label: Text(
                        'طلب جديد',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Filter Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statuses.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = _statuses[index];
                    final isSelected = _selectedStatus == status;

                    return InkWell(
                      onTap: () => setState(() => _selectedStatus = status),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? _navy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? _navy : _border),
                        ),
                        child: Center(
                          child: Text(
                            status,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : _textMain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Requests List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'لا توجد طلبات مسجلة تطابق التصفية',
                              style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final req = list[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UniversityRequestDetailsScreen(request: req),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
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
                                      Text(
                                        req.id,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _blue,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: req.statusBgColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          req.statusLabel,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: req.statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    req.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _navy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.apartment_rounded, size: 14, color: _textSub),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.department,
                                        style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.access_time_rounded, size: 13, color: _textSub),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.date,
                                        style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
