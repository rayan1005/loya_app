import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'transactions_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsWidget extends StatefulWidget {
  const TransactionsWidget({super.key});

  static String routeName = 'Transactions';
  static String routePath = 'transactions';

  @override
  State<TransactionsWidget> createState() => _TransactionsWidgetState();
}

class _TransactionsWidgetState extends State<TransactionsWidget> {
  late TransactionsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _actionLabel(String action) {
    switch (action) {
      case 'stamp_added':
        return 'Stamp added';
      case 'reward_claimed':
        return 'Reward redeemed';
      default:
        return action;
    }
  }

  Widget _programName(StampCardsRecord? card) {
    if (card == null || card.programId == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<ProgramsRecord>(
      stream: ProgramsRecord.getDocument(card.programId!),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Text(
            'Loading...',
            style: FlutterFlowTheme.of(context).bodySmall,
          );
        }
        return Text(
          snap.data!.title,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionsModel());
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
            'Activity',
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
          child: StreamBuilder<List<TransactionsRecord>>(
            stream: queryTransactionsRecord(
              queryBuilder: (tx) {
                final merchantRef = currentUserDocument?.linkedMerchants;
                if (merchantRef != null) {
                  return tx
                      .where('merchant_id', isEqualTo: merchantRef)
                      .orderBy('created_at', descending: true);
                }
                return tx
                    .where('user_id', isEqualTo: currentUserReference)
                    .orderBy('created_at', descending: true);
              },
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
              final txs = snapshot.data!;
              if (txs.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions yet.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 16.0, 16.0, 32.0),
                itemCount: txs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = txs[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 0.0),
                    child: FutureBuilder<StampCardsRecord?>(
                      future: tx.cardId != null
                          ? StampCardsRecord.getDocumentOnce(tx.cardId!)
                          : Future.value(null),
                      builder: (context, cardSnap) {
                        final card = cardSnap.data;
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Color(0x14000000),
                                offset: Offset(0.0, 6.0),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  tx.action == 'reward_claimed'
                                      ? Icons.card_giftcard
                                      : Icons.check_circle,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _actionLabel(tx.action),
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    _programName(card),
                                    if (tx.createdAt != null)
                                      Text(
                                        dateTimeFormat(
                                            'relative', tx.createdAt),
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              if (tx.value != 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    '${tx.value > 0 ? '+' : ''}${tx.value} stamps',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
