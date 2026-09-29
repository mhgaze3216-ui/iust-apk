import 'package:flutter/material.dart';

/// Admin profile information
class AdminProfile {
  final String adminId;
  final String fullName;
  final String jobTitle;
  final String initials;
  final String email;
  final String department;
  final int pendingRequestsCount;
  final int systemReadinessPercent;

  const AdminProfile({
    required this.adminId,
    required this.fullName,
    required this.jobTitle,
    required this.initials,
    required this.email,
    required this.department,
    required this.pendingRequestsCount,
    required this.systemReadinessPercent,
  });
}

/// Dashboard 2x2 stat item
class AdminStatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const AdminStatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

/// University service health status indicator
enum ServiceHealthStatus { healthy, warning, critical }

class AdminServiceHealth {
  final String name;
  final String uptime;
  final String statusText;
  final ServiceHealthStatus status;

  const AdminServiceHealth({
    required this.name,
    required this.uptime,
    required this.statusText,
    required this.status,
  });
}

/// Today's priorities
enum AdminPriorityType { requests, maintenance, announcement }

class AdminPriorityItem {
  final String id;
  final String title;
  final String count;
  final String subtitle;
  final AdminPriorityType type;
  final Color color;
  final IconData icon;

  const AdminPriorityItem({
    required this.id,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.type,
    required this.color,
    required this.icon,
  });
}

/// User account item in administration
enum UserAccountRole { student, doctor, employee }

class AdminAccountItem {
  final String id;
  final String name;
  final String userNumber;
  final String roleLabel;
  final UserAccountRole role;
  bool isActive;
  final String lastLogin;
  final String email;
  final String facultyOrDept;
  List<String> permissions;

  AdminAccountItem({
    required this.id,
    required this.name,
    required this.userNumber,
    required this.roleLabel,
    required this.role,
    required this.isActive,
    required this.lastLogin,
    required this.email,
    required this.facultyOrDept,
    required this.permissions,
  });
}

/// Administrative request / ticket item
enum AdminRequestStatus { newRequest, inReview, completed, rejected }
enum AdminRequestPriority { high, medium, low }

class AdminRequestItem {
  final String id;
  final String title;
  final String requester;
  final String requesterId;
  final String reference;
  final String time;
  AdminRequestStatus status;
  final AdminRequestPriority priority;
  final String description;
  String adminNotes;
  final String contextInfo;
  final String category;

  AdminRequestItem({
    required this.id,
    required this.title,
    required this.requester,
    required this.requesterId,
    required this.reference,
    required this.time,
    required this.status,
    required this.priority,
    required this.description,
    this.adminNotes = '',
    this.contextInfo = '',
    this.category = 'عام',
  });
}

/// Admin Notification
enum AdminNotificationType { request, maintenance, transport, system, account }

class AdminNotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final AdminNotificationType type;

  AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.type,
  });
}

/// Service usage data for reports
class AdminServiceUsage {
  final String name;
  final String visits;
  final int percentage;

  const AdminServiceUsage({
    required this.name,
    required this.visits,
    required this.percentage,
  });
}
