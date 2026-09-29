import 'package:flutter/material.dart';
import '../../../models/admin_models.dart';

class AdminAddAccountDialog extends StatefulWidget {
  final Function(AdminAccountItem) onAccountCreated;

  const AdminAddAccountDialog({super.key, required this.onAccountCreated});

  @override
  State<AdminAddAccountDialog> createState() => _AdminAddAccountDialogState();
}

class _AdminAddAccountDialogState extends State<AdminAddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();

  UserAccountRole _selectedRole = UserAccountRole.student;
  final List<String> _selectedPermissions = ['الوصول إلى البوابة'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _emailCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0F2537);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة حساب مستخدم جديد',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: navyDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildRoleOption('طالب', UserAccountRole.student),
                      const SizedBox(width: 8),
                      _buildRoleOption('هيئة تدريسية', UserAccountRole.doctor),
                      const SizedBox(width: 8),
                      _buildRoleOption('موظف', UserAccountRole.employee),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'الاسم الكامل',
                    hint: 'مثال: ريم الأحمد',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _numberCtrl,
                    label: 'الرقم الجامعي / الوظيفي',
                    hint: _selectedRole == UserAccountRole.student ? '20251099' : 'EMP-092',
                    icon: Icons.badge_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الرقم مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'البريد الإلكتروني الجامعي',
                    hint: 'username@iust.edu.sy',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'بريد غير صالح' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _deptCtrl,
                    label: 'الكلية / الدائرة',
                    hint: 'مثال: كلية الصيدلة',
                    icon: Icons.domain_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الجهة مطلوبة' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('الصلاحيات المبدئية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      'الوصول إلى البوابة',
                      'تسجيل المقررات',
                      'رصد العلامات',
                      'إدارة الحضور',
                      'استلام المعاملات',
                    ].map((perm) {
                      final has = _selectedPermissions.contains(perm);
                      return FilterChip(
                        label: Text(perm, style: TextStyle(fontSize: 12, color: has ? Colors.white : Colors.black87)),
                        selected: has,
                        selectedColor: const Color(0xFF0F6CBD),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPermissions.add(perm);
                            } else {
                              _selectedPermissions.remove(perm);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('إلغاء', style: TextStyle()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F6CBD),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('إنشاء الحساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String label, UserAccountRole role) {
    final selected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0F2537) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      String roleLabel = 'طالب';
      if (_selectedRole == UserAccountRole.doctor) roleLabel = 'هيئة تدريسية';
      if (_selectedRole == UserAccountRole.employee) roleLabel = 'موظف';

      final newAcc = AdminAccountItem(
        id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        userNumber: _numberCtrl.text.trim(),
        roleLabel: roleLabel,
        role: _selectedRole,
        isActive: true,
        lastLogin: 'لم يسجل بعد',
        email: _emailCtrl.text.trim(),
        facultyOrDept: _deptCtrl.text.trim(),
        permissions: List.from(_selectedPermissions),
      );

      widget.onAccountCreated(newAcc);
      Navigator.pop(context);
    }
  }
}
