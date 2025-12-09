import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/merchant/components/merchant_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'md_model.dart';
export 'md_model.dart';
import '/creat_new_pro/creat_new_pro_widget.dart';
import '/merchant/md_plus/md_plus_widget.dart';
import '/merchant/programs_list/programs_list_widget.dart';
import '/merchant/scan/merchant_scan_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final merchantRef = widget.marchentsId ?? currentUserDocument?.linkedMerchants;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        bottomNavigationBar: MerchantNavBar(
          currentTab: MerchantNavTab.dashboard,
          merchantRef: merchantRef,
        ),
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF4B39EF)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.87, -1.0),
              end: AlignmentDirectional(-0.87, 1.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// ---------------------- HEADER --------------------------
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16, 50, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// logout
                      InkWell(
                        onTap: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.signOut();
                          GoRouter.of(context).clearRedirectLocation();

                          context.goNamedAuth(
                              SignInWidget.routeName, context.mounted);
                        },
                        child: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ),

                      /// Title
                      InkWell(
                        onTap: () async {
                          context.pushNamed(UserOrMerchantWidget.routeName);
                        },
                        child: Text(
                          'LOYA.SA',
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                font: GoogleFonts.interTight(),
                                color: Colors.white,
                                fontSize: 16,
                              ),
                        ),
                      ),

                      /// Notifications
                      const Icon(
                        Icons.notifications_sharp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                /// ---------------------- STREAM BUILDER --------------------------
                StreamBuilder<MerchantsRecord>(
                  stream: MerchantsRecord.getDocument(widget.marchentsId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final merchant = snapshot.data!;

                    return Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.9,
                      constraints: const BoxConstraints(maxWidth: 570),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          /// MAIN CONTENT
                          Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    /// ---------------- MERCHANT INFO ----------------

                                    Row(
                                      children: [
                                        /// Logo
                                        if (merchant.logoUrl == null ||
                                            merchant.logoUrl!.isEmpty)
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primaryBackground,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person),
                                          )
                                        else
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              merchant.logoUrl!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                        const SizedBox(width: 8),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              merchant.name,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleLarge
                                                  .override(
                                                    font: GoogleFonts
                                                        .interTight(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ),
                                            Text(
                                              'Welcome back',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    /// ---------------- SCAN QR SECTION ----------------
                                    InkWell(
                                      onTap: () {
                                        context.pushNamed(
                                            MerchantScanWidget.routeName);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0x244A90E2),
                                              Color(0x234B39EF)
                                            ],
                                            stops: [0.0, 1.0],
                                            begin: AlignmentDirectional(
                                                0.87, -1),
                                            end: AlignmentDirectional(
                                                -0.87, 1),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.qr_code_2,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Scan a code',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    /// ---------------- PROGRAMS TITLE ----------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Programs',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font:
                                                    GoogleFonts.openSans(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                                fontSize: 18,
                                              ),
                                        ),
                                        InkWell(
                                          onTap: () => context.pushNamed(
                                              ProgramsListWidget.routeName),
                                          child: Text(
                                            'Manage programs >',
                                            style:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font:
                                                          GoogleFonts.inter(),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    /// ---------------- PROGRAMS LIST (LIVE) ----------------
                                    StreamBuilder<List<ProgramsRecord>>(
                                      stream: queryProgramsRecord(
                                        queryBuilder: (p) => p
                                            .where('merchant_id',
                                                isEqualTo:
                                                    widget.marchentsId)
                                            .orderBy('created_at',
                                                descending: true),
                                      ),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child:
                                                CircularProgressIndicator(),
                                          );
                                        }
                                        final programs = snapshot.data!;
                                        if (programs.isEmpty) {
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .alternate,
                                              ),
                                            ),
                                            child: Text(
                                              'No programs yet. Create your first program to get started.',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          );
                                        }

                                        return Column(
                                          children: [
                                            Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child: Text(
                                                '${programs.length} active program${programs.length > 1 ? 's' : ''}',
                                                style:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...programs.map(
                                              (program) => InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(24),
                                                    ),
                                                    builder: (ctx) {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          bottom: MediaQuery
                                                                  .of(ctx)
                                                              .viewInsets
                                                              .bottom,
                                                        ),
                                                        child: SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      program
                                                                          .title,
                                                                      style: FlutterFlowTheme.of(
                                                                              ctx)
                                                                          .titleLarge
                                                                          .override(
                                                                            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                                                          ),
                                                                    ),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              6),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(ctx)
                                                                            .primary
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'Active',
                                                                        style:
                                                                            TextStyle(fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        10),
                                                                Text(
                                                                  program
                                                                          .description ??
                                                                      '',
                                                                  style: FlutterFlowTheme.of(
                                                                          ctx)
                                                                      .bodyMedium,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        12),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .star_border),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      'Stamps required: ${program.stampsRequired}',
                                                                      style: FlutterFlowTheme.of(
                                                                              ctx)
                                                                          .bodyMedium,
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .redeem_outlined),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        program.rewardDetails ??
                                                                            'Reward',
                                                                        style: FlutterFlowTheme.of(ctx)
                                                                            .bodyMedium,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        8),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .description_outlined),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        program.termsConditions ??
                                                                            '—',
                                                                        style: FlutterFlowTheme.of(ctx)
                                                                            .bodySmall,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        16),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            ctx)
                                                                        .primaryBackground,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16),
                                                                    border:
                                                                        Border.all(
                                                                      color: FlutterFlowTheme.of(
                                                                              ctx)
                                                                          .alternate,
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Share with customers',
                                                                        style: FlutterFlowTheme.of(ctx)
                                                                            .titleMedium,
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        'Program code: ${program.reference.id}',
                                                                        style: FlutterFlowTheme.of(ctx)
                                                                            .bodyMedium,
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Container(
                                                                        width:
                                                                            double.infinity,
                                                                        height:
                                                                            140,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          border:
                                                                              Border.all(color: FlutterFlowTheme.of(ctx).alternate),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            const Icon(Icons.qr_code_2, size: 48),
                                                                            const SizedBox(height: 6),
                                                                            Text(
                                                                              'Show this to customers to join',
                                                                              style: FlutterFlowTheme.of(ctx).labelMedium,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        12),
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            ctx)
                                                                        .pop();
                                                                  },
                                                                  text:
                                                                      'Close',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 48,
                                                                    color: FlutterFlowTheme.of(
                                                                            ctx)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            ctx)
                                                                        .titleSmall
                                                                        .override(
                                                                          font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                          .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16),
                                                  border: Border.all(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                  children: [
                                                    Container(
                                                      width: 54,
                                                      height: 54,
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Color(
                                                          int.tryParse(
                                                                  program
                                                                      .passBackgroundColor
                                                                      .replaceAll(
                                                                          '#',
                                                                          '0xff')) ??
                                                              0xFFEEF2F7,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: program
                                                              .businessIcon
                                                              .isNotEmpty
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child:
                                                                  Image.network(
                                                                program
                                                                    .businessIcon,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons.star,
                                                              color: FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .primary,
                                                            ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            program.title,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            '${program.stampsRequired} stamps • ${program.rewardDetails}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 10,
                                                              vertical: 6),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: program.status
                                                            ? FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                                .withOpacity(
                                                                    0.1)
                                                            : FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        program.status
                                                            ? 'Active'
                                                            : 'Inactive',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodySmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .interTight(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              color: program
                                                                      .status
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    /// ---------------- CREATE NEW PROGRAM ----------------
                                    InkWell(
                                      onTap: () async {
                                        context.pushNamed(
                                          CreatNewProWidget.routeName,
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(
                                                0xFFECECEC),
                                          ),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create new program',
                                              style:
                                                  FlutterFlowTheme.of(
                                                          context)
                                                      .titleMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              Icons.add,
                                              color:
                                                  FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// ---------------------- BOTTOM NAV ---------------------
                          MerchantNavBar(
                            currentTab: MerchantNavTab.dashboard,
                            merchantRef: widget.marchentsId,
                          ),
                        ],
                      ),
                    ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation']!,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}



