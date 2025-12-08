import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'rewards_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RewardsWidget extends StatefulWidget {
  const RewardsWidget({super.key});

  static String routeName = 'Rewards';
  static String routePath = 'rewards';

  @override
  State<RewardsWidget> createState() => _RewardsWidgetState();
}

class _RewardsWidgetState extends State<RewardsWidget> {
  late RewardsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'claimed':
        return 'Claimed';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RewardsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0.0,
          title: Text(
            'Rewards',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<List<RewardsRecord>>(
            stream: queryRewardsRecord(
              queryBuilder: (r) =>
                  r.where('user_id', isEqualTo: currentUserReference),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                );
              }
              final rewards = snapshot.data!;
              if (rewards.isEmpty) {
                return Center(
                  child: Text(
                    'No rewards yet.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 32.0),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Color(0x1F000000),
                            offset: Offset(0.0, 6.0),
                          )
                        ],
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<ProgramsRecord>(
                            stream: reward.programId != null
                                ? ProgramsRecord.getDocument(reward.programId!)
                                : null,
                            builder: (context, programSnap) {
                              if (!programSnap.hasData) {
                                return Text(
                                  'Reward',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium,
                                );
                              }
                              return Text(
                                programSnap.data?.title ?? 'Reward',
                                style:
                                    FlutterFlowTheme.of(context).titleMedium,
                              );
                            },
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Status: ${_statusLabel(reward.rewardStatus)}',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                          if (reward.hasExpiryDate())
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(top: 6.0),
                              child: Text(
                                'Expires on ${dateTimeFormat('yMMMd', reward.expiryDate)}',
                                style:
                                    FlutterFlowTheme.of(context).labelMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
