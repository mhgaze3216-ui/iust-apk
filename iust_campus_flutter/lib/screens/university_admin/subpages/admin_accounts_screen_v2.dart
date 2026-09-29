import 'package:flutter/material.dart';
import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminAccountsScreenV2 extends StatefulWidget {
  const AdminAccountsScreenV2({super.key});

  @override
  State<AdminAccountsScreenV2> createState() => _AdminAccountsScreenV2State();
}

class _AdminAccountsScreenV2State extends State<AdminAccountsScreenV2> {
  int _selectedTab = 0; // 0: الطلاب, 1: الدكاترة, 2: الموظفون
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminUserAccount> get _filteredAccounts {
    final accounts = UniversityAdminRepository.accounts;
    String targetRole;
    if (_selectedTab == 0) {
      targetRole = 'طالب';
    } else if (_selectedTab == 1) {
      targetRole = 'دكتور';
    } else {
      targetRole = 'موظف';
    }

    return accounts.where((acc) {
      final matchesRole = _selectedTab == 2
          ? (acc.role == 'إداري' || acc.role == 'موظف')
          : (acc.role == targetRole);
      if (!matchesRole) return false;
      if (_searchQuery.isEmpty) return true;
      return acc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          acc.userNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          acc.facultyOrDept.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _toggleAccountStatus(AdminUserAccount account) {
    setState(() {
      account.isActive = !account.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          account.isActive
              ? 'تم تفعيل حساب ${account.name} بنجاح'
              : 'تم إيقاف حساب ${account.name}',
        ),
        backgroundColor: account.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAccountDetails(AdminUserAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFEAF4FB),
                    child: Text(
                      account.name.isNotEmpty ? account.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F6CBD),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF073B4C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${account.role} • ${account.userNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6F7F89),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: account.isActive ? const Color(0xFFEDFAF1) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      account.isActive ? 'نشط' : 'موقوف',
                      style: TextStyle(
                        color: account.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _buildDetailRow('الكلية / القسم:', account.facultyOrDept),
              const SizedBox(height: 8),
              _buildDetailRow('البريد الجامعي:', account.email),
              const SizedBox(height: 8),
              _buildDetailRow('المعرف الإداري:', account.id),
              const SizedBox(height: 16),
              const Text(
                'الصلاحيات الممنوحة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B4C),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: account.permissions.map((p) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0F6CBD).withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0F6CBD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF073B4C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F7F89),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0B2E3B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showPermissionsDialog(AdminUserAccount account) {
    final availablePermissions = [
      'الوصول إلى البوابة',
      'تسجيل المقررات',
      'متابعة العلامات',
      'إدارة المقررات',
      'رصد العلامات',
      'رفع النتائج للإدارة',
      'قوائم الحرمان',
      'استلام المعاملات',
      'طباعة الكشوف',
      'تسجيل المقبوضات',
    ];

    List<String> currentPerms = List.from(account.permissions);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'صلاحيات ${account.name}',
              style: const TextStyle(
                color: Color(0xFF073B4C),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availablePermissions.map((perm) {
                    final isChecked = currentPerms.contains(perm);
                    return CheckboxListTile(
                      title: Text(perm, style: const TextStyle(fontSize: 13.5)),
                      value: isChecked,
                      activeColor: const Color(0xFF073B4C),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            currentPerms.add(perm);
                          } else {
                            currentPerms.remove(perm);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء', style: TextStyle(color: Color(0xFF6F7F89))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073B4C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    account.permissions = currentPerms;
                  });
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث الصلاحيات بنجاح'),
                      backgroundColor: Color(0xFF073B4C),
                    ),
                  );
                },
                child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final filtered = _filteredAccounts;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: 'إدارة الحسابات',
                subtitle: 'إدارة وتفعيل حسابات الطلاب والدكاترة والموظفين',
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                      hintText: 'ابحث بالاسم أو الرقم...',
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

              // Tabs (الطلاب, الدكاترة, الموظفون)
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
                      _buildTabItem(0, 'الطلاب', navyCol),
                      _buildTabItem(1, 'الدكاترة', navyCol),
                      _buildTabItem(2, 'الموظفون', navyCol),
                    ],
                  ),
                ),
              ),

              // Accounts List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد حسابات مطابقة للبحث',
                              style: TextStyle(color: textSec, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (ctx, idx) {
                          final acc = filtered[idx];
                          return Container(
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
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: lightBlue,
                                      child: Text(
                                        acc.name.isNotEmpty ? acc.name[0] : 'U',
                                        style: const TextStyle(
                                          color: blueCol,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            acc.name,
                                            style: const TextStyle(
                                              color: textMain,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${acc.facultyOrDept} • ${acc.userNumber}',
                                            style: const TextStyle(
                                              color: textSec,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: acc.isActive
                                            ? const Color(0xFFEDFAF1)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        acc.isActive ? 'نشط' : 'موقوف',
                                        style: TextStyle(
                                          color: acc.isActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: blueCol,
                                          side: const BorderSide(color: borderCol),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => _showAccountDetails(acc),
                                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                        label: const Text('فتح الحساب', style: TextStyle(fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: acc.isActive
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF16A34A),
                                          side: BorderSide(
                                            color: acc.isActive
                                                ? const Color(0xFFFCA5A5)
                                                : const Color(0xFF86EFAC),
                                          ),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => _toggleAccountStatus(acc),
                                        icon: Icon(
                                          acc.isActive
                                              ? Icons.block_rounded
                                              : Icons.check_circle_outline_rounded,
                                          size: 16,
                                        ),
                                        label: Text(
                                          acc.isActive ? 'إيقاف' : 'تفعيل',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: lightBlue,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      onPressed: () => _showPermissionsDialog(acc),
                                      tooltip: 'إدارة الصلاحيات',
                                      icon: const Icon(Icons.shield_outlined, color: blueCol, size: 18),
                                    ),
                                  ],
                                ),
                              ],
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
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
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
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
