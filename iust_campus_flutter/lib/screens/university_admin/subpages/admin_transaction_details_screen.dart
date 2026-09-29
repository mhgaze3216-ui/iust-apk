import 'package:flutter/material.dart';
import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

class AdminTransactionDetailsScreen extends StatelessWidget {
  final AdminTransactionDef transaction;

  const AdminTransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    const bgCol = Color(0xFFF6F9FC);
    const cardCol = Color(0xFFFFFFFF);
    const navyCol = Color(0xFF073B4C);
    const blueCol = Color(0xFF0F6CBD);
    const lightBlue = Color(0xFFEAF4FB);
    const goldCol = Color(0xFFF5B82E);
    const textMain = Color(0xFF0B2E3B);
    const textSec = Color(0xFF6F7F89);
    const borderCol = Color(0xFFDCE8EE);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgCol,
        body: SafeArea(
          child: Column(
            children: [
              UniversityAdminHeader(
                title: transaction.title,
                subtitle: transaction.department,
                showBack: true,
                onBackPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Header card with Icon and Title
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardCol,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: blueCol.withValues(alpha: 0.2)),
                                ),
                                child: Icon(transaction.icon, color: blueCol, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.title,
                                      style: const TextStyle(
                                        color: textMain,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: lightBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        transaction.department,
                                        style: const TextStyle(
                                          color: blueCol,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            transaction.description,
                            style: const TextStyle(
                              color: textSec,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Info Grid (Duration & Fees)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardCol,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4D6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.timer_outlined, color: goldCol, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'المدة المتوقعة',
                                        style: TextStyle(color: textSec, fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        transaction.expectedDuration,
                                        style: const TextStyle(
                                          color: textMain,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardCol,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: lightBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.payments_outlined, color: blueCol, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'الرسوم',
                                        style: TextStyle(color: textSec, fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        transaction.fees,
                                        style: const TextStyle(
                                          color: textMain,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Requirements Card
                    _buildListSection(
                      title: 'المتطلبات الأساسية',
                      icon: Icons.assignment_turned_in_outlined,
                      items: transaction.requirements,
                      navyCol: navyCol,
                      cardCol: cardCol,
                      borderCol: borderCol,
                      textMain: textMain,
                      textSec: textSec,
                      bulletColor: blueCol,
                    ),
                    const SizedBox(height: 16),

                    // Required Documents Card
                    _buildListSection(
                      title: 'الوثائق والمستندات المطلوبة',
                      icon: Icons.folder_open_rounded,
                      items: transaction.documents,
                      navyCol: navyCol,
                      cardCol: cardCol,
                      borderCol: borderCol,
                      textMain: textMain,
                      textSec: textSec,
                      bulletColor: goldCol,
                    ),
                    const SizedBox(height: 16),

                    // Procedural Steps Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardCol,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.format_list_numbered_rounded, color: navyCol, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'خطوات الإجراء',
                                style: TextStyle(
                                  color: navyCol,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(transaction.steps.length, (index) {
                            final step = transaction.steps[index];
                            final isLast = index == transaction.steps.length - 1;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: lightBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: blueCol),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: blueCol,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 32,
                                        color: borderCol,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                                    child: Text(
                                      step,
                                      style: const TextStyle(
                                        color: textMain,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Admin Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyCol,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم فتح نافذة استقبال معاملة: ${transaction.title}'),
                              backgroundColor: navyCol,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_task_rounded, size: 20),
                        label: const Text(
                          'بدء إجراء معاملة جديدة',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color navyCol,
    required Color cardCol,
    required Color borderCol,
    required Color textMain,
    required Color textSec,
    required Color bulletColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: navyCol, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: navyCol,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bulletColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: textMain,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
