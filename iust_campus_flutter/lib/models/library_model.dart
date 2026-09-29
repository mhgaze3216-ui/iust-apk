import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Library Domain Model
// Represents faculty-specific recommended academic references.
// ─────────────────────────────────────────────────────────────────────────────

class LibraryReference {
  final String referenceId;
  final String facultyId;
  final String title;
  final String authors;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const LibraryReference({
    required this.referenceId,
    required this.facultyId,
    required this.title,
    required this.authors,
    required this.category,
    this.icon = Icons.menu_book_rounded,
    this.iconColor = const Color(0xFF0F6CBD),
    this.iconBg = const Color(0xFFEAF4FB),
  });
}
