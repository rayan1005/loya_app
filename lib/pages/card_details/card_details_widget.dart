import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'card_details_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardDetailsWidget extends StatefulWidget {
  const CardDetailsWidget({super.key, this.cardRef});

  final DocumentReference? cardRef;

  static String routeName = 'CardDetails';
  static String routePath = 'cardDetails';

  @override
  State<CardDetailsWidget> createState() => _CardDetailsWidgetState();
}

class _CardDetailsWidgetState extends State<CardDetailsWidget> {
  late CardDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CardDetailsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _createWalletPass(
    StampCardsRecord card,
    ProgramsRecord program,
  ) async {
    if (_model.isCreatingPass) return;
    setState(() => _model.isCreatingPass = true);
    try {
      final response =
          await CreateWalletPassCall.call(programId: program.reference.id);
      if (!(response.succeeded)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create Wallet pass. Try again.'),
          ),
        );
        return;
      }

      final serial = CreateWalletPassCall.serialNumber(response.jsonBody) ??
          getJsonField(
            response.jsonBody,
            r'''$.serialNumber''',
          ).toString();
      final downloadURL =
          CreateWalletPassCall.downloadURL(response.jsonBody) ??
              getJsonField(
                response.jsonBody,
                r'''$.downloadURL''',
              ).toString();

      final deepLink = card.qrValue.isNotEmpty
          ? card.qrValue
          : 'https://loya.live/add-stamp?uid=$currentUserUid&program=${program.reference.id}&serial=$serial';

      await card.reference.update({
        ...createStampCardsRecordData(
          walletPassId: serial,
          walletPassUrl: downloadURL,
          qrValue: deepLink,
        ),
        ...mapToFirestore({
          'updated_at': FieldValue.serverTimestamp(),
        }),
      });

      if (downloadURL.isNotEmpty) {
        await launchURL(downloadURL);
      }
    } finally {
      if (mounted) setState(() => _model.isCreatingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
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
          elevation: 0,
          title: Text(
            'Card details',
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
          child: widget.cardRef == null
              ? Center(
                  child: Text(
                    'No card selected.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                )
              : StreamBuilder<StampCardsRecord>(
                  stream: StampCardsRecord.getDocument(widget.cardRef!),
                  builder: (context, cardSnap) {
                    if (!cardSnap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      );
                    }
                    final card = cardSnap.data!;
                    if (card.programId == null) {
                      return Center(
                        child: Text(
                          'Program missing.',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      );
                    }
                    return StreamBuilder<ProgramsRecord>(
                      stream: ProgramsRecord.getDocument(card.programId!),
                      builder: (context, programSnap) {
                        if (!programSnap.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          );
                        }
                        final program = programSnap.data!;
                        final totalSlots =
                            program.stampsRequired > 0 ? program.stampsRequired : 1;
                        final filled = card.currentStamps > totalSlots
                            ? totalSlots
                            : card.currentStamps;
                        final qr = card.qrValue.isNotEmpty
                            ? card.qrValue
                            : 'https://loya.live/add-stamp?uid=$currentUserUid&program=${program.reference.id}&serial=${card.walletPassId.isNotEmpty ? card.walletPassId : card.cardId}';

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _programCard(context, program, filled, totalSlots),
                              const SizedBox(height: 16),
                              _qrCard(context, qr),
                              const SizedBox(height: 12),
                              _actions(context, card, program),
                            ],
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

  Widget _programCard(BuildContext context, ProgramsRecord program,
      int filled, int totalSlots) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 16, color: Color(0x1F000000), offset: Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            program.title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                ),
          ),
          const SizedBox(height: 8),
          Text(program.description,
              style: FlutterFlowTheme.of(context).bodyMedium),
          const SizedBox(height: 12),
          Text('Progress', style: FlutterFlowTheme.of(context).titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalSlots, (index) {
              final filledSlot = index < filled;
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: filledSlot
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).alternate,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  filledSlot ? Icons.check : Icons.star_border,
                  color: filledSlot
                      ? Colors.white
                      : FlutterFlowTheme.of(context).secondaryText,
                  size: 16,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Status: ${program.status ? 'Active' : 'Inactive'}',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 6),
          if (program.rewardDetails.isNotEmpty)
            Text(
              'Reward: ${program.rewardDetails}',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          const SizedBox(height: 4),
          Text(
            'Stamps required: ${program.stampsRequired}',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _qrCard(BuildContext context, String qr) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Color(0x11000000), offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QR code', style: FlutterFlowTheme.of(context).titleSmall),
          const SizedBox(height: 8),
          if (qr.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(blurRadius: 8, color: Color(0x14000000))
                  ],
                ),
                child: QrImageView(
                  data: qr,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
            )
          else
            Text('No QR available', style: FlutterFlowTheme.of(context).bodyMedium),
        ],
      ),
    );
  }

  Widget _actions(
      BuildContext context, StampCardsRecord card, ProgramsRecord program) {
    final remaining =
        (program.stampsRequired - card.currentStamps).clamp(0, 999);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          remaining == 0
              ? 'Reward ready to redeem'
              : '$remaining stamp(s) remaining for reward',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
        const SizedBox(height: 8),
        FFButtonWidget(
          onPressed:
              _model.isCreatingPass ? null : () => _createWalletPass(card, program),
          text: _model.isCreatingPass
              ? 'Creating pass...'
              : 'Add to Apple Wallet',
          options: FFButtonOptions(
            height: 48,
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                  ),
                  color: Colors.white,
                ),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 12),
        FFButtonWidget(
          onPressed: null,
          text: 'Google Wallet (coming soon)',
          options: FFButtonOptions(
            height: 48,
            color: FlutterFlowTheme.of(context).secondaryBackground,
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            elevation: 0,
            borderSide: BorderSide(
              color:
                  FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }
}












