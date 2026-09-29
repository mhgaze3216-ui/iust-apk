import 'package:flutter/material.dart';
import '../../data/university_admin_repository.dart';
import 'widgets/university_admin_header.dart';
import 'subpages/admin_request_details_screen_v2.dart';

class AdminRequestsScreenV2 extends StatefulWidget {
  final bool isRootTab;

  const AdminRequestsScreenV2({
    super.key,
    this.isRootTab = true,
  });

  @override
  State<AdminRequestsScreenV2> createState() => _AdminRequestsScreenV2State();
}

class _AdminRequestsScreenV2State extends State<AdminRequestsScreenV2> {
  int _selectedTabIndex = 0; // 0: الكل, 1: جديد, 2: قيد المراجعة, 3: مكتمل
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminReqItem> get _filteredRequests {
    final requests = UniversityAdminRepository.requests;
    return requests.where((req) {
      // Tab filter
      if (_selectedTabIndex == 1 && req.status != AdminReqStatus.newRequest) {
        return false;
      }
      if (_selectedTabIndex == 2 && req.status != AdminReqStatus.inReview) {
        return false;
      }
      if (_selectedTabIndex == 3 && req.status != AdminReqStatus.completed) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return req.id.toLowerCase().contains(q) ||
          req.title.toLowerCase().contains(q) ||
          req.requesterName.toLowerCase().contains(q) ||
          req.department.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final items = _filteredRequests;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: widget.isRootTab ? null : 'الطلبات',
                subtitle: widget.isRootTab ? null : 'متابعة الطلبات والمعاملات الواردة إلى إدارة الجامعة',
                showBack: !widget.isRootTab,
                onBackPressed: widget.isRootTab ? null : () => Navigator.maybePop(context),
              ),

              // Search Box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: cardCol,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ابحث برقم الطلب أو اسم المستخدم...',
                      hintStyle: const TextStyle(color: textSec, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: textSec, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: textSec),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // Status Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'الكل', navyCol),
                      _buildTabItem(1, 'جديد', navyCol),
                      _buildTabItem(2, 'قيد المراجعة', navyCol),
                      _buildTabItem(3, 'مكتمل', navyCol),
                    ],
                  ),
                ),
              ),

              // Requests List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد طلبات مطابقة لمعايير البحث',
                              style: TextStyle(color: textSec, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (ctx, idx) {
                          final req = items[idx];
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminRequestDetailsScreenV2(request: req),
                                ),
                              );
                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardCol,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
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
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF4FB),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          req.id,
                                          style: const TextStyle(
                                            color: blueCol,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        req.department,
                                        style: const TextStyle(color: textSec, fontSize: 12),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: req.statusBgColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          req.statusLabel,
                                          style: TextStyle(
                                            color: req.statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    req.title,
                                    style: const TextStyle(
                                      color: textMain,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    req.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: textSec,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 16, color: textSec),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${req.requesterName} (${req.requesterRole})',
                                        style: const TextStyle(color: textSec, fontSize: 12),
                                      ),
                                      const Spacer(),
                                      Text(
                                        req.date,
                                        style: const TextStyle(color: textSec, fontSize: 11),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: blueCol),
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

  Widget _buildTabItem(int index, String label, Color navyCol) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? navyCol : const Color(0xFF6F7F89),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
