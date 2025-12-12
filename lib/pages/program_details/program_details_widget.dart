import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/wallet_stamp_grid.dart';
import '/index.dart';
import 'program_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final target = program.stampsRequired > 0 ? program.stampsRequired : 1;

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
          memberId: cardRef.id,
          stampsToReward: target,
          latestPassUpdate: program.passLatestUpdate,
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

                    final bgColor = _parseColor(
                        program.passBackgroundColor, const Color(0xFF3478F6));
                    final fgColor =
                        _parseColor(program.passForegroundColor, Colors.white);
                    final labelColor = _parseColor(
                        program.passLabelColor, Colors.white.withOpacity(0.8));
                    final backgroundUrl =
                        (program.snapshotData['program_background'] ?? '') as String? ??
                            '';
                    final iconUrl = program.passLogo.isNotEmpty
                        ? program.passLogo
                        : (program.businessIcon.isNotEmpty
                            ? program.businessIcon
                            : program.passIcon);
                    final totalStamps =
                        program.stampsRequired > 0 ? program.stampsRequired : 1;

                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _passPreviewCard(
                              context,
                              program,
                              bgColor,
                              fgColor,
                              labelColor,
                              iconUrl,
                              backgroundUrl,
                              totalStamps),
                          const SizedBox(height: 16.0),
                          _infoRow(context,
                              icon: Icons.star,
                              text: '${program.stampsRequired} stamps to reward'),
                          if (program.hasRewardDetails()) ...[
                            const SizedBox(height: 10),
                            _sectionCard(
                              context,
                              title: 'Reward',
                              child: Text(
                                program.rewardDetails,
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ),
                          ],
                          if (program.hasTermsConditions()) ...[
                            const SizedBox(height: 10),
                            _sectionCard(
                              context,
                              title: 'Terms & Conditions',
                              child: Text(
                                program.termsConditions,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _shareCard(context, shareUrl),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: _model.isJoining
                                      ? null
                                      : () async => _joinProgram(program),
                                  text:
                                      _model.isJoining ? '...Loading' : 'Join',
                                  options: FFButtonOptions(
                                    height: 48.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle:
                                        FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await Share.share(shareUrl,
                                        subject: 'Join this program');
                                  },
                                  text: 'Share',
                                  options: FFButtonOptions(
                                    height: 48.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle:
                                        FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color: FlutterFlowTheme.of(context)
                                                  .primaryText,
                                            ),
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ],
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

  Color _parseColor(String? raw, Color fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    try {
      final cleaned = raw.replaceAll('#', '');
      return Color(int.parse('0xFF$cleaned'));
    } catch (_) {
      return fallback;
    }
  }

  Widget _passPreviewCard(
      BuildContext context,
      ProgramsRecord program,
      Color bg,
      Color fg,
      Color labelColor,
      String iconUrl,
      String backgroundUrl,
      int stampsRequired) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        image: backgroundUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(backgroundUrl),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(bg.withOpacity(0.35), BlendMode.srcATop),
              )
            : null,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x18000000),
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: iconUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(iconUrl, fit: BoxFit.cover),
                      )
                    : Icon(Icons.storefront, color: fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w800,
                            ),
                            color: fg,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.description,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: labelColor,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  program.status ? 'Active' : 'Hidden',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        color: fg,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WalletStampGrid(
            total: stampsRequired,
            filled: 0,
            activeColor: fg,
            inactiveColor: fg.withOpacity(0.35),
            borderColor: labelColor,
            stampIconUrl: program.stampIcon,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show this to join',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: labelColor,
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: 'https://loya.live/program/${program.reference.id}',
                  version: QrVersions.auto,
                  size: 80,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _infoRow(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: FlutterFlowTheme.of(context).primary,
          size: 22.0,
        ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          const SizedBox(height: 6.0),
          child,
        ],
      ),
    );
  }

  Widget _shareCard(BuildContext context, String shareUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share program',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          const SizedBox(height: 6.0),
          SelectableText(
            shareUrl,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              FFButtonWidget(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: shareUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied'),
                    ),
                  );
                },
                text: 'Copy link',
                options: FFButtonOptions(
                  height: 40.0,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight:
                              FlutterFlowTheme.of(context).titleSmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Colors.white,
                      ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  height: 120,
                  alignment: Alignment.centerRight,
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
    );
  }
}
