import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/card_details/card_details_widget.dart';
import '/components/user_nav_bar.dart';
import '/components/stamp_card_widget.dart';
import '/user_or_merchant/user_or_merchant_widget.dart';
import '/user_info/user_info_widget.dart';
import '/sign_in/sign_in_widget.dart';
import '/pages/program_browse/program_browse_widget.dart';
import '/pages/program_details/program_details_widget.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'dashboard';
  static String routePath = 'dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
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
        bottomNavigationBar: UserNavBar(currentTab: UserNavTab.home),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 16),
                _myCardsSection(context),
                const SizedBox(height: 14),
                _discoverCta(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final avatar =
        currentUserPhoto.isNotEmpty ? NetworkImage(currentUserPhoto) : null;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: FlutterFlowTheme.of(context).accent1,
          backgroundImage: avatar,
          child: avatar == null
              ? Icon(Icons.person,
                  color: FlutterFlowTheme.of(context).primary, size: 22)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              Text(
                currentUserDisplayName.isNotEmpty
                    ? currentUserDisplayName
                    : currentUserEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _myCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My cards',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<StampCardsRecord>>(
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
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card,
                            size: 48,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(height: 10),
                        Text(
                          'Join loyalty programs and start collecting rewards.',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        FFButtonWidget(
                          onPressed: () =>
                              context.pushNamed(ProgramBrowseWidget.routeName),
                          text: 'Discover programs',
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
                      ],
                    ),
                  ),
                  _suggestedPrograms(context),
                ],
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StreamBuilder<ProgramsRecord>(
                      stream: ProgramsRecord.getDocument(card.programId!),
                      builder: (context, programSnap) {
                        if (!programSnap.hasData) {
                          return SizedBox(
                              width: math.min(
                                  MediaQuery.sizeOf(context).width * 0.9,
                                  420.0),
                              height: 220,
                              child: const Center(
                                  child: CircularProgressIndicator()));
                        }
                        final program = programSnap.data!;
                        final totalSlots = program.stampsRequired > 0
                            ? program.stampsRequired
                            : 1;
                        final filled = card.currentStamps > totalSlots
                            ? totalSlots
                            : card.currentStamps;
                        final progress = filled / totalSlots;
                        return _cardItem(context, card, program, progress,
                            filled, totalSlots);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _discoverCta(BuildContext context) {
    return FFButtonWidget(
      onPressed: () => context.pushNamed(ProgramBrowseWidget.routeName),
      text: 'Discover new programs',
      options: FFButtonOptions(
        height: 48,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
            ),
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
      ),
    );
  }

  Widget _suggestedPrograms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Suggested programs',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                ),
          ),
        ),
        StreamBuilder<List<ProgramsRecord>>(
          stream: queryProgramsRecord(
            queryBuilder: (q) => q
                .where('status', isEqualTo: true)
                .orderBy('created_at', descending: true),
            limit: 6,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final programs = snapshot.data!;
            if (programs.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: programs
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _miniProgramCard(context, p),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _miniProgramCard(BuildContext context, ProgramsRecord program) {
    Color _bg() {
      final raw = program.passBackgroundColor;
      if (raw.isEmpty) return const Color(0xFF4A90E2);
      try {
        return Color(int.parse('0xFF${raw.replaceAll('#', '')}'));
      } catch (_) {
        return const Color(0xFF4A90E2);
      }
    }

    Color _fg() {
      final raw = program.passForegroundColor;
      if (raw.isEmpty) return Colors.white;
      try {
        return Color(int.parse('0xFF${raw.replaceAll('#', '')}'));
      } catch (_) {
        return Colors.white;
      }
    }

    final bg = _bg();
    final fg = _fg();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x1A000000),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: program.businessIcon.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          program.businessIcon,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.storefront, color: fg, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w800,
                            ),
                            color: fg,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: fg.withOpacity(0.85),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Stamps required: ${program.stampsRequired}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: fg,
                    ),
              ),
              const Spacer(),
              FFButtonWidget(
                onPressed: () {
                  context.pushNamed(
                    ProgramDetailsWidget.routeName,
                    queryParameters: {
                      'programRef': serializeParam(
                        program.reference,
                        ParamType.DocumentReference,
                      ),
                    }.withoutNulls,
                  );
                },
                text: 'View details',
                options: FFButtonOptions(
                  height: 36,
                  color: Colors.white,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        color: bg,
                      ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardItem(BuildContext context, StampCardsRecord card,
      ProgramsRecord program, double progress, int filled, int total) {
    Color _bgColor() {
      final raw = program.passBackgroundColor;
      if (raw.isEmpty) return const Color(0xFF4A90E2);
      try {
        final cleaned = raw.replaceAll('#', '');
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return const Color(0xFF4A90E2);
      }
    }

    final bg = _bgColor();
    Color _fgColor() {
      final raw = program.passForegroundColor;
      if (raw.isEmpty) return Colors.white;
      try {
        return Color(int.parse('0xFF${raw.replaceAll('#', '')}'));
      } catch (_) {
        return Colors.white;
      }
    }

    Color _labelColor() {
      final raw = program.passLabelColor;
      if (raw.isEmpty) return Colors.white.withOpacity(0.8);
      try {
        return Color(int.parse('0xFF${raw.replaceAll('#', '')}'));
      } catch (_) {
        return Colors.white.withOpacity(0.8);
      }
    }

    final fg = _fgColor();
    final labelColor = _labelColor();

    return StampCardWidget(
      title: program.title,
      stampCount: total,
      filledStamps: filled,
      statusPrimary: card.status == 'completed' ? 'Completed' : 'Active',
      statusSecondary: 'Reward pending',
      backgroundColor: bg,
      foregroundColor: fg,
      labelColor: labelColor,
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
      onDetails: () {
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
    );
  }
}
