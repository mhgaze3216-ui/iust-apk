import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/admin_models.dart';
import '../widgets/admin_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class AdminRequestDetailsScreen extends StatefulWidget {
  final AdminRequestItem request;
  final ValueChanged<AdminRequestStatus>? onStatusChanged;

  const AdminRequestDetailsScreen({
    super.key,
    required this.request,
    this.onStatusChanged,
  });

  @override
  State<AdminRequestDetailsScreen> createState() =>
      _AdminRequestDetailsScreenState();
}

class _AdminRequestDetailsScreenState extends State<AdminRequestDetailsScreen> {
  late AdminRequestItem _req;
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _req = widget.request;
    _noteCtrl.text = _req.adminNotes;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _updateStatus(AdminRequestStatus newStatus, String actionName) {
    setState(() {
      _req.status = newStatus;
    });
    widget.onStatusChanged?.call(newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تنفيذ إجراء: $actionName بنجاح على المعاملة ${_req.reference}',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: const Color(0xFF2E9B5F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveNotes() {
    setState(() {
      _req.adminNotes = _noteCtrl.text.trim();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ ملاحظات الإدارة بنجاح', style: GoogleFonts.cairo()),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _statusLabel(AdminRequestStatus s) {
    switch (s) {
      case AdminRequestStatus.newRequest:
        return 'جديد';
      case AdminRequestStatus.inReview:
        return 'قيد المراجعة';
      case AdminRequestStatus.completed:
        return 'مكتمل';
      case AdminRequestStatus.rejected:
        return 'مرفوض';
    }
  }

  Color _statusColor(AdminRequestStatus s) {
    switch (s) {
      case AdminRequestStatus.newRequest:
        return const Color(0xFF0F6CBD);
      case AdminRequestStatus.inReview:
        return const Color(0xFFE67E22);
      case AdminRequestStatus.completed:
        return const Color(0xFF2E9B5F);
      case AdminRequestStatus.rejected:
        return const Color(0xFFE53E3E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_req.status);

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: const AdminHeader(showBackButton: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _req.title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الرقم المرجعي: ${_req.reference}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(_req.status),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
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
                children: [
                  _buildMetaRow('مقدم الطلب', '${_req.requester} (${_req.requesterId})'),
                  const Divider(height: 18, color: _border),
                  _buildMetaRow('نوع المعاملة', _req.category),
                  const Divider(height: 18, color: _border),
                  _buildMetaRow('تاريخ الإرسال', _req.time),
                  const Divider(height: 18, color: _border),
                  _buildMetaRow('درجة الأولوية', _req.priority == AdminRequestPriority.high ? 'عالية' : 'عادية'),
                  if (_req.contextInfo.isNotEmpty) ...[
                    const Divider(height: 18, color: _border),
                    _buildMetaRow('بيانات السياق', _req.contextInfo),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل ووصف المعاملة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _req.description,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Admin Notes card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ملاحظات الإدارة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      TextButton(
                        onPressed: _saveNotes,
                        child: Text(
                          'حفظ الملاحظة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: GoogleFonts.cairo(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'أضف ملاحظات أو توجيهات المتابعة هنا...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      filled: true,
                      fillColor: _lightBg,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Admin Action Buttons
            Text(
              'الإجراءات الإدارية المتاحة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _updateStatus(AdminRequestStatus.inReview, 'بدء المراجعة'),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                  label: Text('بدء المراجعة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _updateStatus(AdminRequestStatus.completed, 'اعتماد'),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: Text('اعتماد',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9B5F),
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _updateStatus(AdminRequestStatus.completed, 'إكمال المعاملة'),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: Text('إكمال',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _updateStatus(AdminRequestStatus.rejected, 'رفض المعاملة'),
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFE53E3E)),
                  label: Text('رفض',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFFE53E3E))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
