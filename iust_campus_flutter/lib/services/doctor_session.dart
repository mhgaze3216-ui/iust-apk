// ─────────────────────────────────────────────────────────────────────────────
// Doctor Session Service
// Manages the currently logged-in doctor session.
// Completely isolated from StudentSession.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import '../models/doctor_models.dart';

import '../data/doctor_repository.dart';

class DoctorSession {
  static String? _activeDoctorId;

  static final ValueNotifier<String?> activeDoctorIdNotifier =
      ValueNotifier<String?>(null);

  /// Current logged-in doctorId
  static String get currentDoctorId => _activeDoctorId ?? '';

  static bool get hasActiveSession =>
      _activeDoctorId != null && _activeDoctorId!.isNotEmpty;

  /// Set the active doctorId upon login
  static void setActiveDoctorId(String doctorId) {
    _activeDoctorId = doctorId;
    activeDoctorIdNotifier.value = doctorId;
  }

  /// Current doctor profile
  static DoctorProfile get currentProfile {
    final did = _activeDoctorId;
    if (did == null || did.isEmpty) return DoctorProfile.empty();
    return DoctorRepository.profile;
  }

  /// Alias for currentProfile
  static DoctorProfile get currentDoctorProfile => currentProfile;

  /// Update active doctor profile details
  static Future<void> updateCurrentProfile({
    String? fullName,
    String? email,
    String? office,
  }) async {
    final did = currentDoctorId;
    await DoctorRepository.updateProfile(
      fullName: fullName,
      email: email,
      office: office,
    );
    activeDoctorIdNotifier.value =
        '$did-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Clear session upon logout or when another user logs in
  static void clearSession() {
    _activeDoctorId = null;
    activeDoctorIdNotifier.value = null;
  }
}
