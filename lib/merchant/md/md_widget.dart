import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/merchant/components/merchant_nav_bar.dart';

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
    final statusText = program.status ? 'Active' : 'Hidden';
    final stamps = program.stampsRequired > 0 ? program.stampsRequired : 0;
    final subtitle = program.rewardDetails.isNotEmpty
        ? program.rewardDetails
        : (program.description.isNotEmpty ? program.description : '');
    final iconUrl = program.passLogo.isNotEmpty
        ? program.passLogo
        : (program.passIcon.isNotEmpty
            ? program.passIcon
            : (program.businessIcon.isNotEmpty ? program.businessIcon : ''));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  program.title.isNotEmpty ? program.title : 'Program',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'stamps - $stamps',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: iconUrl.isNotEmpty
                ? Image.network(
                    iconUrl,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.store,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      merchant.name.isNotEmpty
                                          ? merchant.name
                                          : 'Merchant dashboard',
                                      textAlign: TextAlign.end,
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
                                        textAlign: TextAlign.end,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).accent1,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: merchant.logoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(
                                          merchant.logoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.storefront,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
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
                                    CreatNewProWidget.routeName,
                                  ),
                                  text: 'Create program',
                                  options: FFButtonOptions(
                                    height: 52,
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
                                          .withOpacity(0.15),
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                    height: 52,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                                    borderRadius: BorderRadius.circular(18),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => context
                                    .pushNamed(ProgramsListWidget.routeName),
                                child: Text(
                                  'See all',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                      ),
                                ),
                              ),
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
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        'You have no loyalty programs yet.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      FFButtonWidget(
                                        onPressed: () => context.pushNamed(
                                            CreatNewProWidget.routeName),
                                        text: 'Create your first program',
                                        options: FFButtonOptions(
                                          height: 48,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                color: Colors.white,
                                              ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          return Column(
                            children: programs
                                .map((p) => InkWell(
                                      onTap: () =>
                                          _showProgramSheet(context, p),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: _programTile(context, p),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _activitySection(context, merchantRef),
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

  Widget _activitySection(
      BuildContext context, DocumentReference<Object?> merchantRef) {
    return StreamBuilder<List<TransactionsRecord>>(
      stream: queryTransactionsRecord(
        queryBuilder: (q) => q
            .where('merchant_id', isEqualTo: merchantRef)
            .orderBy('created_at', descending: true),
        limit: 5,
      ),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent activity',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
            const SizedBox(height: 10),
            ...items.map((t) {
              final action = t.action.isNotEmpty ? t.action : 'stamp';
              final value = t.value;
              final ts = t.createdAt != null
                  ? dateTimeFormat('relative', t.createdAt)
                  : '';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle,
                          color: FlutterFlowTheme.of(context).primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action == 'redeem'
                                ? 'Reward redeemed'
                                : 'Stamp added',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700),
                                ),
                          ),
                          if (ts.isNotEmpty)
                            Text(
                              ts,
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (value != 0)
                      Text(
                        '+$value',
                        style: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700),
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
