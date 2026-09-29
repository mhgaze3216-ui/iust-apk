import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_admin_repository.dart';
import '../../../services/admin_preview_session.dart';
import 'admin_user_details_screen.dart';

class AdminAdministrationUsersScreen extends StatefulWidget {
  const AdminAdministrationUsersScreen({super.key});

  @override
  State<AdminAdministrationUsersScreen> createState() =>
      _AdminAdministrationUsersScreenState();
}

class _AdminAdministrationUsersScreenState
    extends State<AdminAdministrationUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminUserAccount> get _adminAccounts {
    return UniversityAdminRepository.accounts.where((acc) {
      final isStaff = acc.role == 'إداري' || acc.role == 'موظف';
      if (!isStaff) return false;
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return acc.name.toLowerCase().contains(query) ||
          acc.userNumber.toLowerCase().contains(query) ||
          acc.username.toLowerCase().contains(query) ||
          acc.jobTitle.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleStatus(AdminUserAccount account) {
    setState(() {
      account.isActive = !account.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          account.isActive
              ? 'تم تفعيل حساب ${account.name} بنجاح'
              : 'تم إيقاف حساب ${account.name}',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor:
            account.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const goldCol = Color(0xFFF5B82E);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final list = _adminAccounts;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: navyCol, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'الكادر الإداري والنظام',
            style: GoogleFonts.cairo(
              color: navyCol,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Search & Summary Bar ───────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم أو الرقم أو المسمى الوظيفي...',
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي الحسابات الإدارية: ${list.length}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textSec,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'الإدارة والخدمات',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: navyCol,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Admin Accounts List ────────────────────────────────────────
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد حسابات إدارية مطابقة للبحث',
                          style: GoogleFonts.cairo(color: textSec, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final acc = list[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFFFFF4D6),
                                      child: Text(
                                        acc.name.isNotEmpty ? acc.name[0] : 'إ',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: navyCol,
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
                                                  acc.name,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: textMain,
                                                  ),
                                                ),
                                              ),
                                              if (acc.isDemo)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
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
                                            '${acc.userNumber} · ${acc.jobTitle.isNotEmpty ? acc.jobTitle : acc.facultyOrDept}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: textSec,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: acc.isActive
                                            ? const Color(0xFFEDFAF1)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        acc.isActive ? 'فعال' : 'معطل',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: acc.isActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 10),

                                // Action Buttons Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: navyCol,
                                          side: const BorderSide(color: borderCol),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AdminUserDetailsScreen(account: acc),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'عرض البيانات',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: acc.isActive
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF16A34A),
                                          side: BorderSide(
                                            color: acc.isActive
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF16A34A),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => _toggleStatus(acc),
                                        child: Text(
                                          acc.isActive ? 'إيقاف الحساب' : 'تفعيل الحساب',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: goldCol,
                                          foregroundColor: navyCol,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () =>
                                            AdminPreviewSession.launchUserPreview(context, acc),
                                        child: Text(
                                          'دخول للواجهة',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
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
}
