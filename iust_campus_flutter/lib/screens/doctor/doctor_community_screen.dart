import 'package:flutter/material.dart';

import '../student/student_class_feed_screen.dart';

class DoctorCommunityScreen extends StatelessWidget {
  final bool showBack;

  const DoctorCommunityScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) =>
      const StudentClassFeedScreen(campusOnly: true);
}
