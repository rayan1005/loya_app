import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

enum MerchantNavTab { dashboard, programs, settings }

class MerchantNavBar extends StatelessWidget {
  const MerchantNavBar({
    super.key,
    required this.currentTab,
    this.merchantRef,
  });

  final MerchantNavTab currentTab;
  final DocumentReference? merchantRef;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + bottomInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _navItem(
              context,
              icon: Icons.home_filled,
              label: 'Dashboard',
              selected: currentTab == MerchantNavTab.dashboard,
              onTap: () => context.goNamed(
                MdWidget.routeName,
                queryParameters: {
                  'marchentsId': serializeParam(
                    merchantRef ?? currentUserDocument?.linkedMerchants,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
              ),
            ),
          ),
          Expanded(
            child: _navItem(
              context,
              icon: Icons.star_rounded,
              label: 'Programs',
              selected: currentTab == MerchantNavTab.programs,
              onTap: () => context.goNamed(ProgramsListWidget.routeName),
            ),
          ),
          Expanded(
            child: _navItem(
              context,
              icon: Icons.settings_rounded,
              label: 'Settings',
              selected: currentTab == MerchantNavTab.settings,
              onTap: () => context.goNamed(MerchantProfileWidget.routeName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected
        ? FlutterFlowTheme.of(context).primary
        : const Color(0xFFAEAEAE);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        constraints: const BoxConstraints(minHeight: 48, maxHeight: 64),
        decoration: selected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x244A90E2), Color(0x234B39EF)],
                ),
                borderRadius: BorderRadius.circular(14),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
