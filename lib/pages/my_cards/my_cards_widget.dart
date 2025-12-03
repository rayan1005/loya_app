import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'my_cards_model.dart';
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
            'بطاقاتي',
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
          child: StreamBuilder<List<StampCardsRecord>>(
            stream: queryStampCardsRecord(
              queryBuilder: (cards) => cards
                  .where('user_id', isEqualTo: currentUserReference)
                  .orderBy('updated_at', descending: true),
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
              final cards = snapshot.data!;
              if (cards.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد بطاقات حتى الآن.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 32.0),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 12.0),
                    child: InkWell(
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
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 16.0,
                              color: Color(0x1F000000),
                              offset: Offset(0.0, 8.0),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: StreamBuilder<ProgramsRecord>(
                            stream: ProgramsRecord.getDocument(card.programId!),
                            builder: (context, programSnap) {
                              if (!programSnap.hasData) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '...جارٍ التحميل',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium,
                                    ),
                                    Icon(
                                      Icons.chevron_left,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                  ],
                                );
                              }
                              final program = programSnap.data!;
                              final totalSlots = program.stampsRequired > 0
                                  ? program.stampsRequired
                                  : 1;
                              final filled = card.currentStamps.clamp(
                                0,
                                totalSlots,
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          program.title,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_left,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    program.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                  SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                        size: 18.0,
                                      ),
                                      SizedBox(width: 6.0),
                                      Text(
                                        '${card.currentStamps} / $totalSlots',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children:
                                        List.generate(totalSlots, (slotIndex) {
                                      final isFilled = slotIndex < filled;
                                      return Container(
                                        width: 26.0,
                                        height: 26.0,
                                        decoration: BoxDecoration(
                                          color: isFilled
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .alternate,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFilled
                                              ? Icons.check
                                              : Icons.star_border,
                                          color: isFilled
                                              ? Colors.white
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          size: 16.0,
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'الحالة: ${card.status.isNotEmpty ? card.status : 'غير محددة'}',
                                    style:
                                        FlutterFlowTheme.of(context).bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
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
