import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/card_details/card_details_widget.dart';
import 'my_cards_model.dart';
export 'my_cards_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyCardsWidget extends StatefulWidget {
  const MyCardsWidget({super.key});

  static String routeName = 'MyCards';
  static String routePath = 'myCards';

  @override
  State<MyCardsWidget> createState() => _MyCardsWidgetState();
}

class _MyCardsWidgetState extends State<MyCardsWidget> {
  late MyCardsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyCardsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: FlutterFlowTheme.of(context).primaryText,
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'My Cards',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  ),
                ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: StreamBuilder<List<StampCardsRecord>>(
              stream: queryStampCardsRecord(
                queryBuilder: (q) => q.where(
                  'user_id',
                  isEqualTo: currentUserReference,
                ),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cards = snapshot.data!;
                if (cards.isEmpty) {
                  return _emptyState(context);
                }

                final activeCount =
                    cards.where((c) => c.status != 'completed').length;
                final completedCount =
                    cards.where((c) => c.status == 'completed').length;
                final walletLinked =
                    cards.where((c) => c.walletPassUrl.isNotEmpty).length;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statsRow(context,
                          active: activeCount,
                          completed: completedCount,
                          wallet: walletLinked),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          if (card.programId == null) {
                            return _cardSkeleton(context);
                          }
                          return StreamBuilder<ProgramsRecord>(
                            stream:
                                ProgramsRecord.getDocument(card.programId!),
                            builder: (context, programSnap) {
                              if (!programSnap.hasData) {
                                return _cardSkeleton(context);
                              }
                              final program = programSnap.data!;
                              final totalSlots = program.stampsRequired > 0
                                  ? program.stampsRequired
                                  : 1;
                              final filled = card.currentStamps > totalSlots
                                  ? totalSlots
                                  : card.currentStamps;
                              final progress =
                                  (filled / totalSlots).clamp(0.0, 1.0);
                              return _cardItem(context, card, program, progress,
                                  filled, totalSlots);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).accent1,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.credit_card,
                color: FlutterFlowTheme.of(context).primary, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards yet',
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a program to see it here.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context,
      {required int active, required int completed, required int wallet}) {
    return Row(
      children: [
        Expanded(
          child: _statTile(context,
              label: 'Active', value: active, color: FlutterFlowTheme.of(context).primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statTile(context,
              label: 'Completed',
              value: completed,
              color: FlutterFlowTheme.of(context).secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statTile(context,
              label: 'Wallet linked',
              value: wallet,
              color: FlutterFlowTheme.of(context).success),
        ),
      ],
    );
  }

  Widget _statTile(BuildContext context,
      {required String label, required int value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  )),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
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

  Widget _cardSkeleton(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _cardItem(
      BuildContext context,
      StampCardsRecord card,
      ProgramsRecord program,
      double progress,
      int filled,
      int total) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).accent1,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: program.passIcon.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          program.passIcon,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.card_giftcard,
                        color: FlutterFlowTheme.of(context).primary),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      program.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (card.status == 'completed'
                          ? FlutterFlowTheme.of(context).success
                          : FlutterFlowTheme.of(context).primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  card.status == 'completed' ? 'Completed' : 'Active',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        color: card.status == 'completed'
                            ? FlutterFlowTheme.of(context).success
                            : FlutterFlowTheme.of(context).primary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
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
                    height: 44,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.white,
                        ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FFButtonWidget(
                  onPressed: card.walletPassUrl.isNotEmpty
                      ? () => launchURL(card.walletPassUrl)
                      : null,
                  text: card.walletPassUrl.isNotEmpty
                      ? 'Open Wallet pass'
                      : 'No Wallet pass',
                  options: FFButtonOptions(
                    height: 44,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    textStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                          color: FlutterFlowTheme.of(context)
                              .primaryText
                              .withOpacity(0.8),
                        ),
                    elevation: 0,
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.25),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
