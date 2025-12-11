import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/dashboard/dashboard_widget.dart';
import '/merchant/md/md_widget.dart';
import '/pages/rewards/rewards_widget.dart';
import '/pages/my_cards/my_cards_widget.dart';
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

  Widget _statsRow(BuildContext context) {
    return StreamBuilder<List<StampCardsRecord>>(
      stream: queryStampCardsRecord(
        queryBuilder: (q) =>
            q.where('user_id', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final cards = snapshot.data!;
        final joined = cards.length;
        final completed =
            cards.where((c) => c.status.toLowerCase() == 'completed').length;

        Widget statTile(String title, String value) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return Row(
          children: [
            statTile('Rewards ready', '$completed'),
            const SizedBox(width: 12),
            statTile('Programs joined', '$joined'),
          ],
        );
      },
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
                const SizedBox(height: 16),
                _statsRow(context),
                const SizedBox(height: 20),
                const SizedBox(height: 4),
                ProfileActionItem(
                  label: 'My rewards',
                  icon: Icons.card_giftcard,
                  onTap: () => context.pushNamed(RewardsWidget.routeName),
                ),
                ProfileActionItem(
                  label: 'My cards',
                  icon: Icons.credit_card,
                  onTap: () => context.pushNamed(MyCardsWidget.routeName),
                ),
                if (hasMerchant && !isMerchant)
                  ProfileActionItem(
                    label: 'Switch to Merchant',
                    icon: Icons.store_mall_directory,
                    onTap: () => _switchRole(context, 'merchant'),
                  ),
                if (isMerchant)
                  ProfileActionItem(
                    label: 'Switch to User',
                    icon: Icons.person_outline,
                    onTap: () => _switchRole(context, 'user'),
                  ),
                ProfileActionItem(
                  label: 'Settings',
                  icon: Icons.settings,
                  onTap: () =>
                      context.pushNamed(UserOrMerchantWidget.routeName),
                ),
                ProfileActionItem(
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

class ProfileActionItem extends StatelessWidget {
  const ProfileActionItem({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
}
