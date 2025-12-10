import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/merchant/components/merchant_nav_bar.dart';
import '/creat_new_pro/creat_new_pro_widget.dart';
import '/merchant/scan/merchant_scan_widget.dart';
import '/merchant/programs_list/programs_list_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'md_model.dart';
export 'md_model.dart';

class MdWidget extends StatefulWidget {
  const MdWidget({
    super.key,
    required this.marchentsId,
  });

  final DocumentReference? marchentsId;

  static String routeName = 'MD';
  static String routePath = 'md';

  @override
  State<MdWidget> createState() => _MdWidgetState();
}

class _MdWidgetState extends State<MdWidget> with TickerProviderStateMixin {
  late MdModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MdModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.ms,
            duration: 300.ms,
            begin: 0,
            end: 1,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.ms,
            duration: 300.ms,
            begin: const Offset(0, 140),
            end: const Offset(0, 0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.ms,
            duration: 300.ms,
            begin: const Offset(0.9, 1),
            end: const Offset(1, 1),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _programTile(BuildContext context, ProgramsRecord program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Color(
                int.tryParse(
                        program.passBackgroundColor.replaceAll('#', '0xff')) ??
                    0xFFEEF2F7,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: program.businessIcon.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      program.businessIcon,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.star,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  program.description ?? '',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                Text(
                  '${program.stampsRequired} stamps - ${program.rewardDetails ?? ''}',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: program.status
                  ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                  : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              program.status ? 'Active' : 'Inactive',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                    ),
                    color: program.status
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgramSheet(BuildContext context, ProgramsRecord program) {
    final joinValue =
        program.programId.isNotEmpty ? program.programId : program.reference.id;
    final joinLink = 'https://loya.live/join?program=$joinValue';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: FlutterFlowTheme.of(ctx).titleLarge.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  program.description ?? '',
                  style: FlutterFlowTheme.of(ctx).bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Stamps required: ${program.stampsRequired}'),
                Text('Reward: ${program.rewardDetails ?? '-'}'),
                Text('Terms: ${program.termsConditions ?? '-'}'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: FlutterFlowTheme.of(ctx).alternate),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                                blurRadius: 10,
                                color: Color(0x14000000),
                                offset: Offset(0, 6))
                          ],
                        ),
                        child: QrImageView(
                          data: joinLink,
                          size: 150,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Show this to customers to join'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FFButtonWidget(
                  onPressed: () => Navigator.of(ctx).pop(),
                  text: 'Close',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 48,
                    color: FlutterFlowTheme.of(ctx).primary,
                    textStyle: FlutterFlowTheme.of(ctx).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchantRef =
        widget.marchentsId ?? currentUserDocument?.linkedMerchants;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: merchantRef == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No merchant selected. Please log in with a merchant account.',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : StreamBuilder<MerchantsRecord>(
                stream: MerchantsRecord.getDocument(merchantRef),
                builder: (context, merchantSnap) {
                  if (!merchantSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final merchant = merchantSnap.data!;
                  return SafeArea(
                    top: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                                child: merchant.logoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          merchant.logoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Icons.storefront,
                                        color: FlutterFlowTheme.of(context)
                                            .primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      merchant.name.isNotEmpty
                                          ? merchant.name
                                          : 'Merchant dashboard',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                    ),
                                    if (merchant.email.isNotEmpty)
                                      Text(
                                        merchant.email,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: () => context.pushNamed(
                                    MerchantScanWidget.routeName,
                                    queryParameters: {
                                      'merchantRef': serializeParam(
                                        merchantRef,
                                        ParamType.DocumentReference,
                                      ),
                                    }.withoutNulls,
                                  ),
                                  text: 'Scan & stamp',
                                  options: FFButtonOptions(
                                    height: 48,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FFButtonWidget(
                                  onPressed: () => context.pushNamed(
                                    CreatNewProWidget.routeName,
                                  ),
                                  text: 'Create program',
                                  options: FFButtonOptions(
                                    height: 48,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.2),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your programs',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              ),
                              TextButton(
                                onPressed: () => context
                                    .pushNamed(ProgramsListWidget.routeName),
                                child: const Text('See all'),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<List<ProgramsRecord>>(
                            stream: queryProgramsRecord(
                              queryBuilder: (q) => q.where('merchant_id',
                                  isEqualTo: merchantRef),
                              limit: 10,
                            ),
                            builder: (context, programSnap) {
                              if (!programSnap.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final programs = programSnap.data!;
                              if (programs.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate),
                                  ),
                                  child: Text(
                                    'No programs yet. Tap "Create program" to get started.',
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                );
                              }
                              return Column(
                                children: programs
                                    .map((p) => InkWell(
                                          onTap: () =>
                                              _showProgramSheet(context, p),
                                          child: _programTile(context, p),
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: MerchantNavBar(
          currentTab: MerchantNavTab.dashboard,
          merchantRef: merchantRef,
        ),
      ),
    );
  }
}
