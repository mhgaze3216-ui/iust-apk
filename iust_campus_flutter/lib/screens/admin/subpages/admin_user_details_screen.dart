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

class AdminUserDetailsScreen extends StatefulWidget {
  final AdminAccountItem account;
  final ValueChanged<bool>? onStatusChanged;
  final ValueChanged<List<String>>? onPermissionsUpdated;

  const AdminUserDetailsScreen({
    super.key,
    required this.account,
    this.onStatusChanged,
    this.onPermissionsUpdated,
  });

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  late AdminAccountItem _acc;

  @override
  void initState() {
    super.initState();
    _acc = widget.account;
  }

  void _toggleAccountActive(bool active) {
    setState(() {
      _acc.isActive = active;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active
              ? 'تم تفعيل حساب المستخدم ${_acc.name} بنجاح'
              : 'تم إيقاف حساب المستخدم ${_acc.name}',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: active ? const Color(0xFF2E9B5F) : const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPermissionsEditor() {
    final availablePermissions = [
      'الوصول إلى البوابة',
      'تسجيل المقررات',
      'متابعة العلامات',
      'رصد العلامات',
      'تسجيل الحضور',
      'نشر الإعلانات',
      'رفع النماذج',
      'استلام المعاملات',
      'طباعة الكشوف الرسمية',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعديل الصلاحيات الممنوحة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'حدد صلاحيات الحساب ضمن المنصة الجامعية',
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: availablePermissions.map((perm) {
                        final hasPerm = _acc.permissions.contains(perm);
                        return CheckboxListTile(
                          title: Text(perm,
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: hasPerm ? FontWeight.w700 : FontWeight.w500)),
                          value: hasPerm,
                          activeColor: _navy,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                _acc.permissions.add(perm);
                              } else {
                                _acc.permissions.remove(perm);
                              }
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onPermissionsUpdated?.call(List.from(_acc.permissions));
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('حفظ الصلاحيات',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: _white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: const AdminHeader(showBackButton: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // User identity card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _acc.isActive
                          ? const Color(0xFFEDFAF1)
                          : const Color(0xFFFDEDEC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _acc.isActive
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Text(
                      _acc.name.isNotEmpty ? _acc.name[0] : 'U',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _acc.isActive
                            ? const Color(0xFF2E9B5F)
                            : const Color(0xFFE53E3E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _acc.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textMain,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _acc.isActive
                                    ? const Color(0xFFEDFAF1)
                                    : const Color(0xFFFDEDEC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _acc.isActive ? 'فعال' : 'موقوف',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _acc.isActive
                                      ? const Color(0xFF2E9B5F)
                                      : const Color(0xFFE53E3E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_acc.roleLabel} · الرقم: ${_acc.userNumber}',
                          style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  _buildMetaRow('البريد الإلكتروني', _acc.email),
                  const Divider(height: 18, color: _border),
                  _buildMetaRow('الكلية / الدائرة', _acc.facultyOrDept),
                  const Divider(height: 18, color: _border),
                  _buildMetaRow('آخر تسجيل دخول', _acc.lastLogin),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Permissions list
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
                        'الصلاحيات الممنوحة (${_acc.permissions.length})',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openPermissionsEditor,
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: Text(
                          'تعديل الصلاحيات',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _acc.permissions.map((perm) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          perm,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _navy,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAccountActive(!_acc.isActive),
                    icon: Icon(
                      _acc.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _acc.isActive ? 'إيقاف الحساب' : 'تفعيل الحساب',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _acc.isActive ? const Color(0xFFE53E3E) : const Color(0xFF2E9B5F),
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
