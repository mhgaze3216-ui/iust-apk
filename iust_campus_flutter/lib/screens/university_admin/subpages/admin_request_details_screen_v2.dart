import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/university_admin_repository.dart';
import '../widgets/university_admin_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminRequestDetailsScreenV2 extends StatefulWidget {
  final AdminReqItem request;

  const AdminRequestDetailsScreenV2({super.key, required this.request});

  @override
  State<AdminRequestDetailsScreenV2> createState() =>
      _AdminRequestDetailsScreenV2State();
}

class _AdminRequestDetailsScreenV2State
    extends State<AdminRequestDetailsScreenV2> {
  late AdminReqItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.request;
  }

  void _showNoteDialog() {
    final noteCtrl = TextEditingController(text: _item.adminNote ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'إضافة ملاحظة إدارية',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _navy,
            ),
          ),
          content: TextField(
            controller: noteCtrl,
            maxLines: 4,
            style: GoogleFonts.cairo(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'اكتب الملاحظة أو التوجيهات الخاصة بالطلب...',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () async {
                final note = noteCtrl.text.trim();
                if (note.isNotEmpty) {
                  try {
                    await UniversityAdminRepository.updateRequestStatus(
                      _item.id,
                      _item.status,
                      note: note,
                    );
                  } catch (error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تعذر حفظ الملاحظة: $error')),
                    );
                    return;
                  }
                  if (!mounted || !ctx.mounted) return;
                  setState(() => _item.adminNote = note);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حفظ الملاحظة الإدارية',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'حفظ',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    AdminReqStatus newStatus,
    String actionName,
  ) async {
    try {
      await UniversityAdminRepository.updateRequestStatus(_item.id, newStatus);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر تنفيذ الإجراء: $error')));
      return;
    }
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تنفيذ إجراء: $actionName بنجاح',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );
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
              UniversityAdminHeader(
                title: 'تفاصيل المعاملة الإدارية',
                subtitle: _item.id,
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // Main Card with Requester and Status
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _item.statusBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _item.statusLabel,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _item.statusColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF4D6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'أولوية: ${_item.priority}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _item.id,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _item.title,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFEDF2F7)),
                          const SizedBox(height: 8),

                          // Requester Info Row
                          _buildDetailRow(
                            Icons.person_rounded,
                            'مقدم الطلب',
                            '${_item.requesterName} (${_item.requesterRole} - ${_item.requesterId})',
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            Icons.account_balance_rounded,
                            'الجهة الإدارية',
                            _item.department,
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            Icons.schedule_rounded,
                            'تاريخ التقديم',
                            _item.date,
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFEDF2F7)),
                          const SizedBox(height: 8),
                          Text(
                            'شرح وتفاصيل الطلب:',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _item.description,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMain,
                              height: 1.6,
                            ),
                          ),

                          if (_item.adminNote != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFBCE0F7),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ملاحظات وتوجيهات الإدارة:',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _blue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _item.adminNote!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      color: _navy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Attachments Card
                    if (_item.attachments.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_file_rounded,
                                  size: 18,
                                  color: _blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'المرفقات (${_item.attachments.length})',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _navy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ..._item.attachments.map((file) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.insert_drive_file_outlined,
                                      size: 16,
                                      color: _blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        file,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: _textMain,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'مرفق معتمد',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action History Log
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: _blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'سجل الإجراءات والتحديثات',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._item.historyLog.map((log) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 15,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      log,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: _textMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Admin Actions Grid
                    Text(
                      'الإجراءات الإدارية المتاحة:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildActionButton(
                          label: 'بدء المراجعة',
                          icon: Icons.play_arrow_rounded,
                          color: const Color(0xFF0F6CBD),
                          onPressed: () => _updateStatus(
                            AdminReqStatus.inReview,
                            'بدء المراجعة',
                          ),
                        ),
                        _buildActionButton(
                          label: 'اعتماد الطلب',
                          icon: Icons.check_rounded,
                          color: const Color(0xFF16A34A),
                          onPressed: () => _updateStatus(
                            AdminReqStatus.completed,
                            'اعتماد الطلب',
                          ),
                        ),
                        _buildActionButton(
                          label: 'رفض الطلب',
                          icon: Icons.close_rounded,
                          color: const Color(0xFFDC2626),
                          onPressed: () => _updateStatus(
                            AdminReqStatus.rejected,
                            'رفض الطلب',
                          ),
                        ),
                        _buildActionButton(
                          label: 'إضافة ملاحظة',
                          icon: Icons.edit_note_rounded,
                          color: _navy,
                          onPressed: _showNoteDialog,
                        ),
                        _buildActionButton(
                          label: 'إكمال الطلب',
                          icon: Icons.done_all_rounded,
                          color: const Color(0xFF16A34A),
                          onPressed: () => _updateStatus(
                            AdminReqStatus.completed,
                            'إكمال ومعالجة الطلب',
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _textSub,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(fontSize: 12, color: _textMain),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}
