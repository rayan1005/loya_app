import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

enum UserNavTab { home, discover, settings }

class UserNavBar extends StatelessWidget {
  const UserNavBar({super.key, required this.currentTab});

  final UserNavTab currentTab;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(
              context,
              icon: Icons.dashboard_rounded,
              label: 'Home',
              selected: currentTab == UserNavTab.home,
              onTap: () => context.goNamed(DashboardWidget.routeName),
            ),
            _item(
              context,
              icon: Icons.explore_rounded,
              label: 'Discover',
              selected: currentTab == UserNavTab.discover,
              onTap: () => context.goNamed(ProgramBrowseWidget.routeName),
            ),
            _item(
              context,
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: currentTab == UserNavTab.settings,
              onTap: () => context.goNamed(UserInfoWidget.routeName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    final color = selected
        ? FlutterFlowTheme.of(context).primary
        : const Color(0xFF9BA1A5);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
