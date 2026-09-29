import 'package:flutter/material.dart';
import '../../data/admin_demo_data.dart';
import '../../models/admin_models.dart';
import 'widgets/admin_header.dart';
import 'subpages/admin_notifications_screen.dart';
import 'subpages/admin_user_details_screen.dart';
import 'subpages/admin_add_account_dialog.dart';
import 'subpages/admin_services_screen.dart';

class AdminManagementScreen extends StatefulWidget {
  final String? initialFilter;

  const AdminManagementScreen({super.key, this.initialFilter});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedRoleFilter = 'الكل';
  late List<AdminAccountItem> _accounts;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedRoleFilter = widget.initialFilter!;
    }
    _accounts = List.from(AdminDemoData.recentAccounts);
  }

  @override
  void didUpdateWidget(covariant AdminManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != null && widget.initialFilter != oldWidget.initialFilter) {
      setState(() {
        _selectedRoleFilter = widget.initialFilter!;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminAccountItem> get _filteredAccounts {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _accounts.where((acc) {
      final matchesQuery = query.isEmpty ||
          acc.name.toLowerCase().contains(query) ||
          acc.userNumber.toLowerCase().contains(query) ||
          acc.email.toLowerCase().contains(query) ||
          acc.facultyOrDept.toLowerCase().contains(query);

      final matchesRole = _selectedRoleFilter == 'الكل' ||
          acc.roleLabel == _selectedRoleFilter;

      return matchesQuery && matchesRole;
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
                title: 'الإدارة والحسابات',
                subtitle: 'إدارة شؤون الطلاب والهيئة التدريسية والصلاحيات',
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
                    // 1. 2x2 Management Summary
                    _buildManagementSummaryGrid(),
                    const SizedBox(height: 18),

                    // 2. Action Bar Header & Add Account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'دليل المستخدمين والحسابات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: navyDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AdminAddAccountDialog(
                                onAccountCreated: (newAcc) {
                                  setState(() {
                                    _accounts.insert(0, newAcc);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم إنشاء حساب ${newAcc.name} بنجاح'),
                                      backgroundColor: const Color(0xFF16A34A),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1, size: 17, color: Colors.white),
                          label: const Text(
                            'إضافة حساب',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F6CBD),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Search Field
                    Container(
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
                          hintText: 'ابحث بالاسم، الرقم، البريد، أو الكلية...',
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
                    const SizedBox(height: 10),

                    // 4. Role Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('الكل'),
                          const SizedBox(width: 8),
                          _buildFilterChip('طالب'),
                          const SizedBox(width: 8),
                          _buildFilterChip('هيئة تدريسية'),
                          const SizedBox(width: 8),
                          _buildFilterChip('موظف'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Accounts List
                    if (_filteredAccounts.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.person_search_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'لا توجد حسابات تطابق معايير البحث',
                              style: TextStyle(color: slateGray, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredAccounts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final acc = _filteredAccounts[index];
                          return _buildAccountCard(context, acc, navyDark, slateGray);
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

  Widget _buildManagementSummaryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemCount: AdminDemoData.managementStats.length,
      itemBuilder: (context, index) {
        final stat = AdminDemoData.managementStats[index];
        return InkWell(
          onTap: () {
            if (index == 0) {
              setState(() => _selectedRoleFilter = 'طالب');
            } else if (index == 1) {
              setState(() => _selectedRoleFilter = 'هيئة تدريسية');
            } else if (index == 2) {
              // Show facilities bottom sheet
              _openFacilitiesSheet();
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: stat.iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat.icon, color: stat.iconColor, size: 18),
                  ),
                  Flexible(
                    child: Text(
                      stat.subtitle,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2537),
                    ),
                  ),
                  Text(
                    stat.title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedRoleFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedRoleFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  Widget _buildAccountCard(
    BuildContext context,
    AdminAccountItem acc,
    Color navyDark,
    Color slateGray,
  ) {
    Color roleBadgeBg;
    Color roleBadgeText;
    switch (acc.role) {
      case UserAccountRole.student:
        roleBadgeBg = const Color(0xFFEFF6FF);
        roleBadgeText = const Color(0xFF1D4ED8);
        break;
      case UserAccountRole.doctor:
        roleBadgeBg = const Color(0xFFF5F3FF);
        roleBadgeText = const Color(0xFF6D28D9);
        break;
      case UserAccountRole.employee:
        roleBadgeBg = const Color(0xFFFFF7ED);
        roleBadgeText = const Color(0xFFC2410C);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminUserDetailsScreen(
                  account: acc,
                  onStatusChanged: (val) => setState(() => acc.isActive = val),
                  onPermissionsUpdated: (perms) => setState(() => acc.permissions = perms),
                ),
              ),
            );
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Icon(
                    acc.role == UserAccountRole.doctor
                        ? Icons.school_rounded
                        : acc.role == UserAccountRole.student
                            ? Icons.person_rounded
                            : Icons.badge_rounded,
                    color: navyDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              acc.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: navyDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleBadgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              acc.roleLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: roleBadgeText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${acc.userNumber} · ${acc.facultyOrDept}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'آخر دخول: ${acc.lastLogin}',
                        style: TextStyle(
                          fontSize: 11,
                          color: slateGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Switch(
                      value: acc.isActive,
                      activeThumbColor: const Color(0xFF16A34A),
                      onChanged: (val) {
                        setState(() {
                          acc.isActive = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? 'تم تفعيل حساب ${acc.name}'
                                  : 'تم إيقاف حساب ${acc.name}',
                            ),
                            backgroundColor: val ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    Text(
                      acc.isActive ? 'مفعّل' : 'معطّل',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: acc.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
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

  void _openFacilitiesSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'حالة القاعات والمرافق الجامعية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2537),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ملخص إشغال القاعات والمخابر الدراسية اليوم.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.meeting_room_outlined, color: Color(0xFF0F6CBD)),
                title: Text('المدرجات الرئيسية (A1 - A4)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('قيد الاستخدام بنسبة 75%', style: TextStyle(fontSize: 11)),
                trailing: Chip(label: Text('نشطة', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A)))),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.computer_outlined, color: Color(0xFF073B4C)),
                title: Text('مخابر كلية تكنولوجيا المعلومات (Lab 1 - Lab 6)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('جميع المخابر جاهزة للتدريس', style: TextStyle(fontSize: 11)),
                trailing: Chip(label: Text('متاحة', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
