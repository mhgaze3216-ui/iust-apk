import 'package:flutter/material.dart';
import '../models/doctor_models.dart';

/// Centralized repository for Doctor Archive and Academic Documents.
/// Stores and operates ONLY on lightweight metadata.
/// Does NOT store binary PDF bytes, image bytes, or base64 strings in memory.
class DoctorArchiveRepository {
  // ── In-memory metadata cache ──────────────────────────────────────────────
  static final List<DoctorArchiveItem> _items = [
    const DoctorArchiveItem(
      id: 'archive-exam-001',
      title: 'امتحان نصفي - معالج دقيق',
      courseName: 'معالج دقيق',
      documentType: 'امتحان نصفي',
      semester: '2025/2026 الصيفي',
      date: '2026-08-15',
      status: 'معتمد',
      statusColor: Color(0xFF2E9B5F),
      filePath: null, // Simulated cloud/backend path
      fileSize: '1.2 MB',
      notes: 'نموذج أسئلة الامتحان النصفي وسلالم التصحيح المعتمدة للشعبة 1.',
    ),
    const DoctorArchiveItem(
      id: 'archive-exam-002',
      title: 'امتحان نهائي - الاحتمالات والإشارات العشوائية',
      courseName: 'الاحتمالات والإشارات العشوائية',
      documentType: 'امتحان نهائي',
      semester: '2025/2026 الصيفي',
      date: '2026-09-02',
      status: 'مسودة',
      statusColor: Color(0xFFE67E22),
      filePath: null,
      fileSize: '850 KB',
      notes: 'مسودة ورقة الأسئلة النهائية بانتظار مراجعة رئيس القسم.',
    ),
    const DoctorArchiveItem(
      id: 'archive-exam-003',
      title: 'امتحان نهائي - معالج دقيق',
      courseName: 'معالج دقيق',
      documentType: 'امتحان نهائي',
      semester: '2025/2026 الفصل الثاني',
      date: '2026-02-10',
      status: 'مؤرشف',
      statusColor: Color(0xFF6F7F89),
      filePath: null,
      fileSize: '1.5 MB',
      notes: 'أرشيف الدورة الامتحانية للفصل الدراسي الثاني 2025/2026.',
    ),
    const DoctorArchiveItem(
      id: 'archive-sub-001',
      title: 'كشف علامات الامتحان النصفي',
      courseName: 'معالج دقيق',
      documentType: 'علامات',
      semester: '2025/2026 الصيفي',
      date: '2026-08-25',
      status: 'معتمد',
      statusColor: Color(0xFF2E9B5F),
      filePath: null,
      fileSize: '420 KB',
      notes: 'تم تدقيق جميع أوراق الإجابة ومطابقة الجمع اليدوي مع الكشف الرقمي.',
    ),
    const DoctorArchiveItem(
      id: 'archive-sub-002',
      title: 'كشف علامات الامتحان النهائي',
      courseName: 'الاحتمالات والإشارات العشوائية',
      documentType: 'علامات',
      semester: '2025/2026 الصيفي',
      date: '2026-09-08',
      status: 'مسودة',
      statusColor: Color(0xFFE67E22),
      filePath: null,
      fileSize: '510 KB',
      notes: 'جاهز للمراجعة بانتظار الاعتماد الرسمي النهائي من الإدارة.',
    ),
    const DoctorArchiveItem(
      id: 'archive-sub-003',
      title: 'كشف علامات الشعبة والعملي',
      courseName: 'معالج دقيق',
      documentType: 'علامات',
      semester: '2025/2026 الصيفي',
      date: '2026-09-09',
      status: 'مسودة',
      statusColor: Color(0xFFE67E22),
      filePath: null,
      fileSize: '390 KB',
      notes: 'كشف درجات الأعمال والمحاضرات العملية بانتظار توقيع العمادة.',
    ),
    const DoctorArchiveItem(
      id: 'archive-att-001',
      title: 'سجل حضور شعبة معالج دقيق (1)',
      courseName: 'معالج دقيق',
      documentType: 'حضور',
      semester: '2025/2026 الصيفي',
      date: '2026-08-30',
      status: 'معتمد',
      statusColor: Color(0xFF2E9B5F),
      filePath: null,
      fileSize: '240 KB',
      notes: 'سجل الحضور والغياب المكتمل حتى الجلسة 12.',
    ),
    const DoctorArchiveItem(
      id: 'archive-dep-001',
      title: 'قائمة الحرمان الأكاديمي المبدئية',
      courseName: 'معالج دقيق',
      documentType: 'معاملات',
      semester: '2025/2026 الصيفي',
      date: '2026-09-01',
      status: 'مسودة',
      statusColor: Color(0xFFE67E22),
      filePath: null,
      fileSize: '180 KB',
      notes: 'حرمان طالبين بسبب تجاوز نسبة الغياب 15%.',
    ),
  ];

  // ── Accessors & Lazy Query Methods ────────────────────────────────────────

  /// Returns only exam archive metadata items
  static List<DoctorArchiveItem> get examArchiveItems =>
      _items.where((i) => i.documentType.contains('امتحان')).toList(growable: false);

  /// Returns all cached archive metadata items
  static List<DoctorArchiveItem> getAllItems() => List.unmodifiable(_items);

  /// In-memory metadata-only filter: zero file decoding, zero byte reads
  static List<DoctorArchiveItem> filterItems({
    String query = '',
    String category = 'الكل',
  }) {
    return _items.where((item) {
      if (category != 'الكل') {
        if (category == 'امتحانات' && !item.documentType.contains('امتحان')) {
          return false;
        }
        if (category == 'علامات' && !item.documentType.contains('علامات')) {
          return false;
        }
        if (category == 'حضور' && !item.documentType.contains('حضور')) {
          return false;
        }
        if (category == 'تكليفات' && !item.documentType.contains('تكليف')) {
          return false;
        }
        if (category == 'معاملات' && !item.documentType.contains('معاملة')) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final match = item.title.toLowerCase().contains(q) ||
            item.courseName.toLowerCase().contains(q) ||
            item.documentType.toLowerCase().contains(q) ||
            item.semester.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList(growable: false);
  }

  /// Prepared for future backend pagination: fetch chunk by offset and limit
  static List<DoctorArchiveItem> getPage({int offset = 0, int limit = 10}) {
    if (offset >= _items.length) return const [];
    final end = (offset + limit).clamp(0, _items.length);
    return _items.sublist(offset, end);
  }

  /// Loads ONE document asynchronously on demand (only when user taps "فتح")
  static Future<DoctorArchiveItem?> loadDocumentById(String id) async {
    // Lightweight simulated delay for opening a single document
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
