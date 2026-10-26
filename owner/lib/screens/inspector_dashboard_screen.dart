import 'package:flutter/material.dart';
import 'inspector_main_nav.dart';

export 'inspector_main_nav.dart';
export 'inspector_home_screen.dart';
export 'inspector_seal_verification_screen.dart';
export 'inspector_violations_screen.dart';
export 'inspector_profile_screen.dart';

class InspectorDashboardScreen extends StatelessWidget {
  final int initialIndex;
  const InspectorDashboardScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return InspectorMainNav(initialIndex: initialIndex);
  }
}
