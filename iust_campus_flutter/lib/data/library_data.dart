import 'package:flutter/material.dart';
import '../models/library_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Recommended Academic Library References
// Categorized by faculty for faculty-specific student library access.
// ─────────────────────────────────────────────────────────────────────────────

// ── Dentistry References (Hamza / faculty-dentistry) ─────────────────────────
const kDentistryReferences = <LibraryReference>[
  LibraryReference(
    referenceId: 'ref-dent-01',
    facultyId:   'faculty-dentistry',
    title:       'Oxford Handbook of Clinical Dentistry',
    authors:     'Laura Mitchell & David A. Mitchell',
    category:    'مرجع عام',
    icon:        Icons.menu_book_rounded,
    iconColor:   Color(0xFF0F6CBD),
    iconBg:      Color(0xFFEAF4FB),
  ),
  LibraryReference(
    referenceId: 'ref-dent-02',
    facultyId:   'faculty-dentistry',
    title:       "Sturdevant's Art and Science of Operative Dentistry",
    authors:     'Harald O. Heymann et al.',
    category:    'ترميم ولبية',
    icon:        Icons.science_rounded,
    iconColor:   Color(0xFF7C3AED),
    iconBg:      Color(0xFFF5F0FF),
  ),
  LibraryReference(
    referenceId: 'ref-dent-03',
    facultyId:   'faculty-dentistry',
    title:       'Contemporary Oral and Maxillofacial Surgery',
    authors:     'Hupp, Ellis III, & Tucker',
    category:    'جراحة الفم والتخدير',
    icon:        Icons.medical_services_rounded,
    iconColor:   Color(0xFFE53E3E),
    iconBg:      Color(0xFFFFF0F0),
  ),
  LibraryReference(
    referenceId: 'ref-dent-04',
    facultyId:   'faculty-dentistry',
    title:       "Newman and Carranza's Clinical Periodontology",
    authors:     'Michael G. Newman et al.',
    category:    'لثة وتعويضات',
    icon:        Icons.biotech_rounded,
    iconColor:   Color(0xFF2E9B5F),
    iconBg:      Color(0xFFEDFAF1),
  ),
  LibraryReference(
    referenceId: 'ref-dent-05',
    facultyId:   'faculty-dentistry',
    title:       "Berkovitz's Oral Anatomy, Histology and Embryology",
    authors:     'B.K.B. Berkovitz et al.',
    category:    'تشريح وأنسجة وأجنة',
    icon:        Icons.account_tree_rounded,
    iconColor:   Color(0xFFD4900A),
    iconBg:      Color(0xFFFFF8E1),
  ),
  LibraryReference(
    referenceId: 'ref-dent-06',
    facultyId:   'faculty-dentistry',
    title:       "White and Pharoah's Oral Radiology",
    authors:     'Sanjay M. Mallya & Ernest Lam',
    category:    'أشعة وتشخيص',
    icon:        Icons.radar_rounded,
    iconColor:   Color(0xFF0891B2),
    iconBg:      Color(0xFFE6F7FB),
  ),
  LibraryReference(
    referenceId: 'ref-dent-07',
    facultyId:   'faculty-dentistry',
    title:       "Cawson's Essentials of Oral Pathology and Oral Medicine",
    authors:     'R.A. Cawson & E.W. Odell',
    category:    'أمراض الفم',
    icon:        Icons.coronavirus_rounded,
    iconColor:   Color(0xFF7C3AED),
    iconBg:      Color(0xFFF5F0FF),
  ),
];

// ── Informatics References (Mustafa / faculty-engineering) ───────────────────
const kInformaticsReferences = <LibraryReference>[
  LibraryReference(
    referenceId: 'ref-it-01',
    facultyId:   'faculty-engineering',
    title:       'Introduction to Algorithms',
    authors:     'Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein',
    category:    'الخوارزميات وهياكل البيانات',
    icon:        Icons.account_tree_rounded,
    iconColor:   Color(0xFF0F6CBD),
    iconBg:      Color(0xFFEAF4FB),
  ),
  LibraryReference(
    referenceId: 'ref-it-02',
    facultyId:   'faculty-engineering',
    title:       'Computer Networks',
    authors:     'Andrew S. Tanenbaum & David J. Wetherall',
    category:    'شبكات الحاسوب',
    icon:        Icons.hub_rounded,
    iconColor:   Color(0xFF0891B2),
    iconBg:      Color(0xFFE6F7FB),
  ),
  LibraryReference(
    referenceId: 'ref-it-03',
    facultyId:   'faculty-engineering',
    title:       'Operating System Concepts',
    authors:     'Abraham Silberschatz, Peter B. Galvin, Greg Gagne',
    category:    'نظم التشغيل',
    icon:        Icons.terminal_rounded,
    iconColor:   Color(0xFF7C3AED),
    iconBg:      Color(0xFFF5F0FF),
  ),
  LibraryReference(
    referenceId: 'ref-it-04',
    facultyId:   'faculty-engineering',
    title:       'Database System Concepts',
    authors:     'Abraham Silberschatz, Henry F. Korth, S. Sudarshan',
    category:    'قواعد البيانات',
    icon:        Icons.storage_rounded,
    iconColor:   Color(0xFF2E9B5F),
    iconBg:      Color(0xFFEDFAF1),
  ),
  LibraryReference(
    referenceId: 'ref-it-05',
    facultyId:   'faculty-engineering',
    title:       'Computer Organization and Design',
    authors:     'David A. Patterson & John L. Hennessy',
    category:    'معمارية وتنظيم الحاسوب',
    icon:        Icons.memory_rounded,
    iconColor:   Color(0xFFD4900A),
    iconBg:      Color(0xFFFFF8E1),
  ),
  LibraryReference(
    referenceId: 'ref-it-06',
    facultyId:   'faculty-engineering',
    title:       'Artificial Intelligence: A Modern Approach',
    authors:     'Stuart Russell & Peter Norvig',
    category:    'الذكاء الاصطناعي',
    icon:        Icons.psychology_rounded,
    iconColor:   Color(0xFFE53E3E),
    iconBg:      Color(0xFFFFF0F0),
  ),
  LibraryReference(
    referenceId: 'ref-it-07',
    facultyId:   'faculty-engineering',
    title:       'Clean Code',
    authors:     'Robert C. Martin',
    category:    'هندسة البرمجيات',
    icon:        Icons.code_rounded,
    iconColor:   Color(0xFF0F6CBD),
    iconBg:      Color(0xFFEAF4FB),
  ),
];

// Master list of all university library references
const kAllLibraryReferences = <LibraryReference>[
  ...kDentistryReferences,
  ...kInformaticsReferences,
];
