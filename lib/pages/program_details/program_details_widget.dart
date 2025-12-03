import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'program_details_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ProgramDetailsWidget extends StatefulWidget {
  const ProgramDetailsWidget({
    super.key,
    this.programRef,
  });

  final DocumentReference? programRef;

  static String routeName = 'ProgramDetails';
  static String routePath = 'programDetails';

  @override
  State<ProgramDetailsWidget> createState() => _ProgramDetailsWidgetState();
}

class _ProgramDetailsWidgetState extends State<ProgramDetailsWidget> {
  late ProgramDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramDetailsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _joinProgram(ProgramsRecord program) async {
    if (_model.isJoining || currentUserReference == null) return;
    _model.isJoining = true;
    safeSetState(() {});

    try {
      final existingCards = await queryStampCardsRecordOnce(
        queryBuilder: (cards) => cards
            .where('user_id', isEqualTo: currentUserReference)
            .where('program_id', isEqualTo: program.reference)
            .limit(1),
      );

      if (existingCards.isNotEmpty) {
        context.pushNamed(
          CardDetailsWidget.routeName,
          queryParameters: {
            'cardRef': serializeParam(
              existingCards.first.reference,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
        return;
      }

      final cardRef = StampCardsRecord.collection.doc();
      final deepLink =
          'https://loya.live/add-stamp?uid=$currentUserUid&program=${program.reference.id}&serial=${cardRef.id}';

      await cardRef.set({
        ...createStampCardsRecordData(
          cardId: cardRef.id,
          programId: program.reference,
          userId: currentUserReference,
          currentStamps: 0,
          status: 'active',
          qrValue: deepLink,
          walletPassId: '',
          walletPassUrl: '',
        ),
        ...mapToFirestore({
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }),
      });

      context.pushNamed(
        CardDetailsWidget.routeName,
        queryParameters: {
          'cardRef': serializeParam(
            cardRef,
            ParamType.DocumentReference,
          ),
        }.withoutNulls,
      );
    } finally {
      _model.isJoining = false;
      safeSetState(() {});
    }
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
            'Program Details',
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
          child: widget.programRef == null
              ? Center(
                  child: Text(
                    'No program selected',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                )
              : StreamBuilder<ProgramsRecord>(
                  stream: ProgramsRecord.getDocument(widget.programRef!),
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
                    final program = snapshot.data!;
                    final shareUrl =
                        'https://loya.live/program/${program.reference.id}';

                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.title,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            program.description,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                          SizedBox(height: 12.0),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 22.0,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                '${program.stampsRequired} stamps to reward',
                                style:
                                    FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          if (program.hasRewardDetails())
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rewards',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium,
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    program.rewardDetails,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 12.0),
                          if (program.hasTermsConditions())
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terms & Conditions',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium,
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    program.termsConditions,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 12.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate),
                            ),
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share program',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium,
                                ),
                                SizedBox(height: 6.0),
                                SelectableText(
                                  shareUrl,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium,
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: shareUrl));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Link copied'),
                                          ),
                                        );
                                      },
                                      text: 'Copy link',
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                            ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await Share.share(shareUrl,
                                            subject: 'Join this program');
                                      },
                                      text: 'Share',
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                            ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        height: 120,
                                        alignment: Alignment.center,
                                        child: QrImageView(
                                          data: shareUrl,
                                          version: QrVersions.auto,
                                          size: 120,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          FFButtonWidget(
                            onPressed: _model.isJoining
                                ? null
                                : () async => _joinProgram(program),
                            text: _model.isJoining ? '...Loading' : 'Join',
                            options: FFButtonOptions(
                              height: 48.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
