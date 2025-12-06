import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  Future<void> _scanQr() async {
    final result = await FlutterBarcodeScanner.scanBarcode(
      '#4A90E2',
      'إلغاء',
      true,
      ScanMode.QR,
    );

    if (!mounted || result == '-1') return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم مسح الكود: $result')),
    );
  }

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                                              'مرحباً بك',
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
                                      onTap: _scanQr,
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
                                              'قم بمسح الكود',
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
                                          'البرامج',
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
                                        Text(
                                          'إدارة البرامج >',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(),
                                                color:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                              ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    /// ---------------- SINGLE PROGRAM SAMPLE ----------------
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFECECEC),
                                        ),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 14,
                                                vertical: 6),
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      24),
                                            ),
                                            child: Text(
                                              'Active',
                                              style:
                                                  FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                        ),
                                                        color:
                                                            Colors.white,
                                                      ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Coffee Of The Day',
                                                style:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                          fontSize: 18,
                                                        ),
                                              ),
                                              Text(
                                                'stamps 10 . Coffee',
                                                style:
                                                    FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                          ),
                                                        ),
                                              ),
                                            ],
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: Image.asset(
                                              'assets/images/pngtree-coffee-cup-with-steam-png-image_15043854.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                              'إنشاء برنامج جديد',
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
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _navItem(
                                    icon: Icons.settings,
                                    label: 'Settings',
                                    selected: false,
                                    onTap: () {
                                      context.pushNamed(
                                          UserOrMerchantWidget
                                              .routeName);
                                    },
                                  ),
                                  _navItem(
                                    icon: Icons.stars,
                                    label: 'Programs',
                                    selected: false,
                                    onTap: () {
                                      context.pushNamed(
                                        MdPlusWidget.routeName,
                                        queryParameters: {
                                          'marchentsId':
                                              serializeParam(
                                            widget.marchentsId,
                                            ParamType
                                                .DocumentReference,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                  _navItem(
                                    icon: FontAwesomeIcons.home,
                                    label: 'Dashboard',
                                    selected: true,
                                    onTap: () {
                                      context.pushNamed(
                                        MdWidget.routeName,
                                        queryParameters: {
                                          'marchentsId':
                                              serializeParam(
                                            widget.marchentsId,
                                            ParamType
                                                .DocumentReference,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
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

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: selected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x244A90E2), Color(0x234B39EF)],
                ),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : const Color(0xFFAEAEAE)),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                    ),
                    color: selected
                        ? FlutterFlowTheme.of(context).primary
                        : const Color(0xFFAEAEAE),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
