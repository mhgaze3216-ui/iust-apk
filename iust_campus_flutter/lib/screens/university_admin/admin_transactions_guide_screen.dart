import 'package:flutter/material.dart';
import '../../data/university_admin_repository.dart';
import 'widgets/university_admin_header.dart';
import 'subpages/admin_transaction_details_screen.dart';

class AdminTransactionsGuideScreen extends StatefulWidget {
  final bool isRootTab;

  const AdminTransactionsGuideScreen({
    super.key,
    this.isRootTab = true,
  });

  @override
  State<AdminTransactionsGuideScreen> createState() => _AdminTransactionsGuideScreenState();
}

class _AdminTransactionsGuideScreenState extends State<AdminTransactionsGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminTransactionDef> get _filteredTransactions {
    final list = UniversityAdminRepository.transactions;
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.department.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    final items = _filteredTransactions;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: widget.isRootTab ? null : 'دليل المعاملات',
                subtitle: widget.isRootTab ? null : 'إجراءات المعاملات الإدارية ومتطلباتها داخل الجامعة',
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
                      hintText: 'ابحث عن معاملة أو قسم...',
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

              // Total count info banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'المعاملات المعتمدة (${items.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'اختر معاملة لعرض متطلباتها',
                      style: TextStyle(fontSize: 11, color: textSec),
                    ),
                  ],
                ),
              ),

              // 12 Transactions List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_off_outlined, size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد معاملات مطابقة للبحث',
                              style: TextStyle(color: textSec, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final trn = items[idx];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminTransactionDetailsScreen(transaction: trn),
                                ),
                              );
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: lightBlue,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: blueCol.withValues(alpha: 0.15)),
                                    ),
                                    child: Icon(trn.icon, color: blueCol, size: 22),
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
                                                trn.title,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: textMain,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                trn.department,
                                                style: const TextStyle(fontSize: 11, color: textSec),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          trn.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: textSec,
                                            height: 1.35,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFF5B82E)),
                                            const SizedBox(width: 4),
                                            Text(
                                              trn.expectedDuration,
                                              style: const TextStyle(fontSize: 11, color: textSec),
                                            ),
                                            const SizedBox(width: 14),
                                            const Icon(Icons.payments_outlined, size: 13, color: blueCol),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                trn.fees,
                                                style: const TextStyle(fontSize: 11, color: textSec),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: blueCol),
                                          ],
                                        ),
                                      ],
                                    ),
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
