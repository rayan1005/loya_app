import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/card_details/card_details_widget.dart';
import '/user_or_merchant/user_or_merchant_widget.dart';
import '/sign_in/sign_in_widget.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'dashboard';
  static String routePath = 'dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<Map<String, int>>? _metricsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
    _metricsFuture = _loadMetrics();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<Map<String, int>> _loadMetrics() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final firestore = FirebaseFirestore.instance;

    final stampCardsCount = await queryStampCardsRecordCount();
    final walletPassesCount =
        (await firestore.collection('wallet_passes').count().get()).count ?? 0;
    final stampsThisWeek = await queryStampCardsRecordCount(
      queryBuilder: (q) => q.where('created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo)),
    );
    final rewardsRedeemed = (await firestore
                .collection('rewards')
                .where('reward_status', isEqualTo: 'completed')
                .count()
                .get())
            .count ??
        0;

    return {
      'cards': stampCardsCount,
      'passes': walletPassesCount,
      'stampsWeek': stampsThisWeek,
      'rewards': rewardsRedeemed,
    };
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 16),
                _walletStatusCard(context),
                const SizedBox(height: 16),
                _metricsSection(context),
                const SizedBox(height: 16),
                _myCardsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.pushNamed(UserOrMerchantWidget.routeName),
              child: Text(
                'LOYA.SA',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
            ),
            Text(
              'Discover loyalty programs',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).accent1,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () async {
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();
              context.goNamedAuth(SignInWidget.routeName, context.mounted);
            },
            child: Icon(
              Icons.logout,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _walletStatusCard(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: WalletHealthCall.call(),
      builder: (context, snapshot) {
        final ok = snapshot.hasData && (snapshot.data?.succeeded ?? false);
        final statusText =
            ok ? 'Wallet API connected' : 'Wallet API not reachable';
        final statusColor =
            ok ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.error_outline,
                  color: statusColor),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.interTight(),
                      color: statusColor,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricsSection(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _metricsFuture,
      builder: (context, snapshot) {
        final metrics = snapshot.data;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricCard(
              context,
              label: 'Active cards',
              value: metrics?['cards'] ?? 0,
              color: FlutterFlowTheme.of(context).primary,
            ),
            _metricCard(
              context,
              label: 'Wallet passes',
              value: metrics?['passes'] ?? 0,
              color: FlutterFlowTheme.of(context).secondary,
            ),
            _metricCard(
              context,
              label: 'Stamps this week',
              value: metrics?['stampsWeek'] ?? 0,
              color: FlutterFlowTheme.of(context).accent1,
            ),
            _metricCard(
              context,
              label: 'Rewards redeemed',
              value: metrics?['rewards'] ?? 0,
              color: FlutterFlowTheme.of(context).success,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(BuildContext context,
      {required String label, required int value, required Color color}) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Color(0x12000000), offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  )),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                  ),
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _myCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My cards',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<StampCardsRecord>>(
          stream: queryStampCardsRecord(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final cards = snapshot.data!;
            if (cards.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No cards yet.',
                    style: FlutterFlowTheme.of(context).bodyMedium),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StreamBuilder<ProgramsRecord>(
                      stream: ProgramsRecord.getDocument(card.programId!),
                      builder: (context, programSnap) {
                        if (!programSnap.hasData) {
                          return const SizedBox(
                              width: 260,
                              height: 160,
                              child: Center(child: CircularProgressIndicator()));
                        }
                        final program = programSnap.data!;
                        final totalSlots = program.stampsRequired > 0
                            ? program.stampsRequired
                            : 1;
                        final filled = card.currentStamps > totalSlots
                            ? totalSlots
                            : card.currentStamps;
                        final progress = filled / totalSlots;
                        return _cardItem(context, card, program, progress,
                            filled, totalSlots);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _cardItem(
      BuildContext context,
      StampCardsRecord card,
      ProgramsRecord program,
      double progress,
      int filled,
      int total) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          CardDetailsWidget.routeName,
          queryParameters: {
            'cardRef': serializeParam(
              card.reference,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Color(0x1A000000), offset: Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              program.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor:
                  FlutterFlowTheme.of(context).alternate.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary),
            ),
            const SizedBox(height: 6),
          Text(
            '$filled / $total stamps',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primary,
                ),
          ),
            const Spacer(),
            FFButtonWidget(
              onPressed: () {
                context.pushNamed(
                  CardDetailsWidget.routeName,
                  queryParameters: {
                    'cardRef': serializeParam(
                      card.reference,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              },
              text: 'View details',
              options: FFButtonOptions(
                height: 40,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                      color: Colors.white,
                    ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
