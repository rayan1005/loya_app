import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/dashboard/dashboard_widget.dart';
import '/merchant/md/md_widget.dart';
import '/pages/rewards/rewards_widget.dart';
import '/user_or_merchant/user_or_merchant_widget.dart';
import '/sign_in/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_info_model.dart';
export 'user_info_model.dart';

class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  static String routeName = 'UserInfo';
  static String routePath = 'userInfo';

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  late UserInfoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserInfoModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _switchRole(BuildContext context, String role) async {
    if (currentUserReference == null) return;
    await currentUserReference!.update(createUserRecordData(userType: role));
    if (!mounted) return;
    context.goNamed(
        role == 'merchant' ? MdWidget.routeName : DashboardWidget.routeName);
  }

  Widget _profileHeader(BuildContext context) {
    final avatar =
        currentUserPhoto.isNotEmpty ? NetworkImage(currentUserPhoto) : null;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: FlutterFlowTheme.of(context).accent1,
          backgroundImage: avatar,
          child: avatar == null
              ? Icon(Icons.person,
                  color: FlutterFlowTheme.of(context).primary, size: 28)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUserDisplayName.isNotEmpty
                    ? currentUserDisplayName
                    : 'User',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              ),
              Text(
                currentUserEmail,
                style: FlutterFlowTheme.of(context).bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(
        label,
        style: FlutterFlowTheme.of(context).bodyLarge.override(
              font: GoogleFonts.inter(),
              fontWeight: FontWeight.w600,
            ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final hasMerchant = currentUserDocument?.hasLinkedMerchants() ?? false;
    final isMerchant = currentUserDocument?.userType == 'merchant';
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0,
          title: Text(
            'Profile',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w800,
                  ),
                ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileHeader(context),
                const SizedBox(height: 20),
                if (hasMerchant && !isMerchant)
                  FFButtonWidget(
                    onPressed: () => _switchRole(context, 'merchant'),
                    text: 'Switch to Merchant',
                    options: FFButtonOptions(
                      height: 48,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: Colors.white,
                              ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                if (isMerchant)
                  FFButtonWidget(
                    onPressed: () => _switchRole(context, 'user'),
                    text: 'Switch to User',
                    options: FFButtonOptions(
                      height: 48,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                const SizedBox(height: 20),
                _listItem(
                  context: context,
                  label: 'My rewards',
                  icon: Icons.card_giftcard,
                  onTap: () => context.pushNamed(RewardsWidget.routeName),
                ),
                _listItem(
                  context: context,
                  label: 'Settings',
                  icon: Icons.settings,
                  onTap: () =>
                      context.pushNamed(UserOrMerchantWidget.routeName),
                ),
                _listItem(
                  context: context,
                  label: 'Logout',
                  icon: Icons.logout,
                  onTap: () async {
                    GoRouter.of(context).prepareAuthEvent();
                    await authManager.signOut();
                    GoRouter.of(context).clearRedirectLocation();
                    context.goNamedAuth(
                        SignInWidget.routeName, context.mounted);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
