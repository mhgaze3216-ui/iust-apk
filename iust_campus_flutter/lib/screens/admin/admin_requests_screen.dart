import 'package:flutter/material.dart';
import '../../data/admin_demo_data.dart';
import '../../models/admin_models.dart';
import 'widgets/admin_header.dart';
import 'subpages/admin_notifications_screen.dart';
import 'subpages/admin_request_details_screen.dart';
import 'subpages/admin_create_report_sheet.dart';

class AdminRequestsScreen extends StatefulWidget {
  final String? initialFilter;

  const AdminRequestsScreen({super.key, this.initialFilter});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatusFilter = 'الكل';
  late List<AdminRequestItem> _requests;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedStatusFilter = widget.initialFilter!;
    }
    _requests = AdminDemoData.requests;
  }

  @override
  void didUpdateWidget(covariant AdminRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != null && widget.initialFilter != oldWidget.initialFilter) {
      setState(() {
        _selectedStatusFilter = widget.initialFilter!;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminRequestItem> get _filteredRequests {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _requests.where((req) {
      final matchesQuery = query.isEmpty ||
          req.title.toLowerCase().contains(query) ||
          req.requester.toLowerCase().contains(query) ||
          req.requesterId.toLowerCase().contains(query) ||
          req.reference.toLowerCase().contains(query) ||
          req.category.toLowerCase().contains(query);

      bool matchesStatus = true;
      if (_selectedStatusFilter == 'جديد') {
        matchesStatus = req.status == AdminRequestStatus.newRequest;
      } else if (_selectedStatusFilter == 'قيد المراجعة') {
        matchesStatus = req.status == AdminRequestStatus.inReview;
      } else if (_selectedStatusFilter == 'مكتمل') {
        matchesStatus = req.status == AdminRequestStatus.completed;
      } else if (_selectedStatusFilter == 'مرفوض') {
        matchesStatus = req.status == AdminRequestStatus.rejected;
      }

      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0F2537);
    const slateGray = Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              AdminHeader(
                title: 'إدارة الطلبات والمعاملات',
                subtitle: 'معالجة واستجابة المعاملات الأكاديمية والخدمية',
                showNotificationBell: true,
                unreadCount: AdminDemoData.unreadNotificationsCount,
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  children: [
                    // Search & Actions
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'ابحث برقم المعاملة، الاسم، أو المقرر...',
                                hintStyle: const TextStyle(fontSize: 13, color: slateGray),
                                prefixIcon: const Icon(Icons.search, color: slateGray, size: 20),
                                suffixIcon: _searchCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18, color: slateGray),
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
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => const AdminCreateReportSheet(),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F6CBD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('الكل'),
                          const SizedBox(width: 8),
                          _buildFilterChip('جديد'),
                          const SizedBox(width: 8),
                          _buildFilterChip('قيد المراجعة'),
                          const SizedBox(width: 8),
                          _buildFilterChip('مكتمل'),
                          const SizedBox(width: 8),
                          _buildFilterChip('مرفوض'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Requests List
                    if (_filteredRequests.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'لا توجد طلبات تطابق معايير التصفية',
                              style: TextStyle(color: slateGray, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredRequests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final req = _filteredRequests[index];
                          return _buildRequestCard(context, req, navyDark, slateGray);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2537) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F2537) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    AdminRequestItem req,
    Color navyDark,
    Color slateGray,
  ) {
    Color statusBg;
    Color statusColor;
    String statusText;
    switch (req.status) {
      case AdminRequestStatus.newRequest:
        statusBg = const Color(0xFFFEF2F2);
        statusColor = const Color(0xFFDC2626);
        statusText = 'جديد';
        break;
      case AdminRequestStatus.inReview:
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFD97706);
        statusText = 'قيد المراجعة';
        break;
      case AdminRequestStatus.completed:
        statusBg = const Color(0xFFF0FDF4);
        statusColor = const Color(0xFF16A34A);
        statusText = 'مكتمل';
        break;
      case AdminRequestStatus.rejected:
        statusBg = const Color(0xFFF1F5F9);
        statusColor = const Color(0xFF64748B);
        statusText = 'مرفوض';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: req.status == AdminRequestStatus.newRequest
              ? const Color(0xFFFED7AA)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminRequestDetailsScreen(
                  request: req,
                  onStatusChanged: (newSt) {
                    setState(() {
                      req.status = newSt;
                    });
                  },
                ),
              ),
            );
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Ref code, Category, Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req.reference,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·  ${req.category}',
                      style: TextStyle(
                        fontSize: 11,
                        color: slateGray,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  req.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: navyDark,
                  ),
                ),
                if (req.contextInfo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    req.contextInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Requester and Time
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 15, color: slateGray),
                    const SizedBox(width: 4),
                    Text(
                      '${req.requester} (${req.requesterId})',
                      style: TextStyle(fontSize: 12, color: slateGray),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 15, color: slateGray),
                    const SizedBox(width: 4),
                    Text(
                      req.time,
                      style: TextStyle(fontSize: 12, color: slateGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
