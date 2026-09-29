import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_admin_repository.dart';
import '../../../services/admin_preview_session.dart';
import 'admin_user_details_screen.dart';

class AdminUserManagementScreen extends StatefulWidget {
  final bool isRootTab;
  final String? initialRoleFilter; // 'الكل', 'الطلاب', 'الدكاترة', 'الإداريون'

  const AdminUserManagementScreen({
    super.key,
    this.isRootTab = false,
    this.initialRoleFilter,
  });

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late int _selectedRoleIndex; // 0: الكل, 1: الطلاب, 2: الدكاترة, 3: الإداريون
  String _selectedFaculty = 'الكل';

  static const List<String> _roleFilters = [
    'الكل',
    'الطلاب',
    'الدكاترة',
    'الإداريون',
  ];

  static const List<String> _facultyFilters = [
    'الكل',
    'طب الأسنان',
    'الهندسة المعلوماتية',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialRoleFilter != null) {
      final idx = _roleFilters.indexOf(widget.initialRoleFilter!);
      _selectedRoleIndex = idx >= 0 ? idx : 0;
    } else {
      _selectedRoleIndex = 0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminUserAccount> get _filteredAccounts {
    final all = UniversityAdminRepository.accounts;
    return all.where((acc) {
      // 1. Role filter
      if (_selectedRoleIndex == 1 && acc.role != 'طالب') return false;
      if (_selectedRoleIndex == 2 && acc.role != 'دكتور') return false;
      if (_selectedRoleIndex == 3 && (acc.role != 'إداري' && acc.role != 'موظف')) {
        return false;
      }

      // 2. Faculty filter (for students when filtered)
      if (_selectedRoleIndex == 1 && _selectedFaculty != 'الكل') {
        if (!acc.facultyOrDept.contains(_selectedFaculty)) return false;
      }

      // 3. Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = acc.name.toLowerCase().contains(query);
        final matchNumber = acc.userNumber.toLowerCase().contains(query);
        final matchUsername = acc.username.toLowerCase().contains(query);
        final matchFaculty = acc.facultyOrDept.toLowerCase().contains(query);
        if (!matchName && !matchNumber && !matchUsername && !matchFaculty) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openManageAccountSheet(AdminUserAccount account) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(22),
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
                    width: 44,
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
                      radius: 26,
                      backgroundColor: _getRoleBgColor(account.role),
                      child: Text(
                        account.name.isNotEmpty ? account.name[0] : 'U',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _getRoleColor(account.role),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0B2E3B),
                            ),
                          ),
                          Text(
                            '${account.userNumber} · ${account.facultyOrDept}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFF6F7F89),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Account status toggle option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: account.isActive
                          ? const Color(0xFFEDFAF1)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      account.isActive
                          ? Icons.check_circle_rounded
                          : Icons.block_rounded,
                      color: account.isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    account.isActive ? 'الحساب مفعّل' : 'الحساب موقوف',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    account.isActive
                    ? 'يمكن للمستخدم تسجيل الدخول والوصول لكافة الخدمات'
                    : 'تم تعليق وصول المستخدم للخدمات مؤقتاً',
                    style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF6F7F89)),
                  ),
                  trailing: Switch.adaptive(
                    value: account.isActive,
                    activeThumbColor: const Color(0xFF16A34A),
                    onChanged: (val) {
                      setSheetState(() {
                        account.isActive = val;
                      });
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Edit permissions shortcut
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.security_rounded, color: Color(0xFF0F6CBD), size: 20),
                  ),
                  title: Text(
                    'تعديل الصلاحيات',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    'عدد الصلاحيات الممنوحة حالياً: ${account.permissions.length}',
                    style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF6F7F89)),
                  ),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserDetailsScreen(account: account),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // CTA to open user interface
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5B82E),
                      foregroundColor: const Color(0xFF073B4C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      AdminPreviewSession.launchUserPreview(context, account);
                    },
                    icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                    label: Text(
                      _getRoleActionText(account.role),
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const navyCol = Color(0xFF073B4C);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final accounts = _filteredAccounts;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: widget.isRootTab
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: navyCol, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
          automaticallyImplyLeading: !widget.isRootTab,
          title: Text(
            'إدارة المستخدمين',
            style: GoogleFonts.cairo(
              color: navyCol,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Subtitle & Search Section ───────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة حسابات الطلاب والدكاترة والإداريين والوصول إلى واجهاتهم',
                      style: GoogleFonts.cairo(
                        color: textSec,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم أو الرقم أو اسم المستخدم...',
                        hintStyle: GoogleFonts.cairo(color: textSec, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: navyCol),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: bgCol,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderCol),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: navyCol, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Role Filter Segment Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_roleFilters.length, (i) {
                          final label = _roleFilters[i];
                          final isSelected = _selectedRoleIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedRoleIndex = i;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? navyCol : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? navyCol : borderCol,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : textSec,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Faculty Filter Chips (shown when "الطلاب" is selected)
                    if (_selectedRoleIndex == 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'الكلية: ',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: textSec,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _facultyFilters.map((fac) {
                                  final isFacSelected = _selectedFaculty == fac;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: ChoiceChip(
                                      label: Text(
                                        fac,
                                        style: GoogleFonts.cairo(
                                          fontSize: 10.5,
                                          fontWeight: isFacSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isFacSelected
                                              ? const Color(0xFF0F6CBD)
                                              : textSec,
                                        ),
                                      ),
                                      selected: isFacSelected,
                                      selectedColor: const Color(0xFFEAF4FB),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isFacSelected
                                              ? const Color(0xFF0F6CBD)
                                              : borderCol,
                                        ),
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedFaculty = fac);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Accounts Count Summary ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المستخدمون (${accounts.length})',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: navyCol,
                      ),
                    ),
                    Text(
                      'انقر على أي مستخدم للدخول لواجهته الحقيقية',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: textSec,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Lazy List of User Cards ────────────────────────────────────
              Expanded(
                child: accounts.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد مستخدمون مطابقون للبحث والفلترة',
                          style: GoogleFonts.cairo(color: textSec, fontSize: 13.5),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return _buildUserCard(account);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(AdminUserAccount account) {
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const goldCol = Color(0xFFF5B82E);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(18),
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
          // Row: Avatar, Name, ID, Role Badge, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: _getRoleBgColor(account.role),
                child: Text(
                  account.name.isNotEmpty ? account.name[0] : 'U',
                  style: GoogleFonts.cairo(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _getRoleColor(account.role),
                  ),
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
                            account.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textMain,
                            ),
                          ),
                        ),
                        if (account.isDemo)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DEMO',
                              style: GoogleFonts.cairo(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.userNumber} · ${account.facultyOrDept}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: textSec,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleBgColor(account.role),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            account.role,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: _getRoleColor(account.role),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: account.isActive
                                ? const Color(0xFFEDFAF1)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: account.isActive
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                account.isActive ? 'نشط' : 'معطل',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: account.isActive
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Actions: إدارة الحساب | عرض البيانات | دخول للواجهة ─────────────
          Row(
            children: [
              // 1. إدارة الحساب
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navyCol,
                    side: const BorderSide(color: borderCol),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                  ),
                  onPressed: () => _openManageAccountSheet(account),
                  child: Text(
                    'إدارة الحساب',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 2. عرض البيانات
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navyCol,
                    side: const BorderSide(color: borderCol),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserDetailsScreen(account: account),
                      ),
                    );
                  },
                  child: Text(
                    'عرض البيانات',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 3. دخول للواجهة
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldCol,
                    foregroundColor: navyCol,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                  ),
                  onPressed: () => AdminPreviewSession.launchUserPreview(context, account),
                  child: Text(
                    _getRoleActionText(account.role),
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRoleActionText(String role) {
    switch (role) {
      case 'أدمن':
        return 'واجهة الأدمن';
      case 'طالب':
        return 'دخول لواجهة الطالب';
      case 'دكتور':
        return 'دخول لواجهة الدكتور';
      case 'إداري':
      case 'موظف':
      default:
        return 'دخول لواجهة الإداري';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'أدمن':
        return const Color(0xFFD97706);
      case 'طالب':
        return const Color(0xFF0F6CBD);
      case 'دكتور':
        return const Color(0xFF7C3AED);
      case 'إداري':
      case 'موظف':
      default:
        return const Color(0xFF073B4C);
    }
  }

  Color _getRoleBgColor(String role) {
    switch (role) {
      case 'أدمن':
        return const Color(0xFFFEF3C7);
      case 'طالب':
        return const Color(0xFFEAF4FB);
      case 'دكتور':
        return const Color(0xFFF5F0FF);
      case 'إداري':
      case 'موظف':
      default:
        return const Color(0xFFFFF4D6);
    }
  }
}
