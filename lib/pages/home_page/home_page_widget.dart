import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/card_details/card_details_widget.dart';
import '/pages/program_browse/program_browse_widget.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = 'homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
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
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: StreamBuilder<List<StampCardsRecord>>(
            stream: queryStampCardsRecord(
              queryBuilder: (q) =>
                  q.where('user_id', isEqualTo: currentUserReference),
            ),
            builder: (context, cardSnap) {
              if (!cardSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final cards = cardSnap.data!;
              final hasCards = cards.isNotEmpty;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _homeHeader(context),
                    const SizedBox(height: 16),
                    if (!hasCards) ...[
                      _emptyHero(context),
                      const SizedBox(height: 16),
                      SuggestedProgramsList(onTapDiscover: _goDiscover),
                    ] else ...[
                      Text(
                        'My cards',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          if (card.programId == null) {
                            return const SizedBox.shrink();
                          }
                          return StreamBuilder<ProgramsRecord>(
                            stream: ProgramsRecord.getDocument(card.programId!),
                            builder: (context, programSnap) {
                              if (!programSnap.hasData) {
                                return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                );
                              }
                              final program = programSnap.data!;
                              final totalStamps =
                                  program.stampsRequired > 0 ? program.stampsRequired : 1;
                              final filled = card.currentStamps.clamp(0, totalStamps);
                              final status = card.status.isNotEmpty
                                  ? card.status
                                  : 'Active';
                              return PassPreviewCard(
                                program: program,
                                filledStamps: filled,
                                totalStamps: totalStamps,
                                status: status,
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
                              );
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: _goDiscover,
                      text: 'Discover new programs',
                      options: FFButtonOptions(
                        height: 52,
                        width: double.infinity,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _homeHeader(BuildContext context) {
    final avatar =
        currentUserPhoto.isNotEmpty ? NetworkImage(currentUserPhoto) : null;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: FlutterFlowTheme.of(context).accent1,
          backgroundImage: avatar,
          child: avatar == null
              ? Icon(Icons.person,
                  color: FlutterFlowTheme.of(context).primary, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: FlutterFlowTheme.of(context).bodySmall,
              ),
              Text(
                currentUserDisplayName.isNotEmpty
                    ? currentUserDisplayName
                    : (currentUserEmail.isNotEmpty ? currentUserEmail : 'User'),
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

  Widget _emptyHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join loyalty programs and start collecting rewards.',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w800,
                  ),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find nearby programs and add your first card.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 14),
          FFButtonWidget(
            onPressed: _goDiscover,
            text: 'Discover programs',
            options: FFButtonOptions(
              height: 48,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
    );
  }

  void _goDiscover() {
    context.pushNamed(ProgramBrowseWidget.routeName);
  }
}

class PassPreviewCard extends StatelessWidget {
  const PassPreviewCard({
    super.key,
    required this.program,
    this.filledStamps = 0,
    this.totalStamps = 0,
    this.status,
    this.onTap,
    this.compact = false,
  });

  final ProgramsRecord program;
  final int filledStamps;
  final int totalStamps;
  final String? status;
  final VoidCallback? onTap;
  final bool compact;

  Color _parseColor(String raw, Color fallback) {
    if (raw.isEmpty) return fallback;
    try {
      final cleaned = raw.replaceAll('#', '');
      return Color(int.parse('0xFF$cleaned'));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _parseColor(program.passBackgroundColor, const Color(0xFF3478F6));
    final fg = _parseColor(program.passForegroundColor, Colors.white);
    final label =
        _parseColor(program.passLabelColor, fg.withValues(alpha: 0.8));
    final iconUrl = program.passLogo.isNotEmpty
        ? program.passLogo
        : (program.businessIcon.isNotEmpty
            ? program.businessIcon
            : program.passIcon);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x15000000),
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage:
                      iconUrl.isNotEmpty ? NetworkImage(iconUrl) : null,
                  child: iconUrl.isEmpty
                      ? Icon(Icons.store, color: fg, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                      if (program.description.isNotEmpty && compact)
                        Text(
                          program.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: label, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (status != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                       color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status!,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            if (totalStamps > 0) ...[
              const SizedBox(height: 14),
              DynamicStampGrid(
                totalStamps: totalStamps,
                filledStamps: filledStamps,
                color: fg,
                badgeColor: label,
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                'Stamps required: ${program.stampsRequired}',
                style: TextStyle(color: fg, fontWeight: FontWeight.w600),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    'View details',
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DynamicStampGrid extends StatelessWidget {
  const DynamicStampGrid({
    super.key,
    required this.totalStamps,
    required this.filledStamps,
    required this.color,
    required this.badgeColor,
  });

  final int totalStamps;
  final int filledStamps;
  final Color color;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final rows = (totalStamps / 6).ceil().clamp(1, 2);
    final stampsPerRow = List.generate(rows, (i) {
      final start = i * 6;
      final end = (start + 6).clamp(0, totalStamps);
      return end - start;
    });

    return Column(
      children: stampsPerRow.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final count = entry.value;
        final filledBefore =
            stampsPerRow.take(rowIndex).fold<int>(0, (p, c) => p + c);
        return LayoutBuilder(
          builder: (ctx, constraints) {
            final spacing = 8.0;
            final size = (constraints.maxWidth / count) - spacing;
            final stampSize = size.clamp(18.0, 40.0);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: rowIndex == stampsPerRow.length - 1 ? 0 : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (index) {
                  final globalIndex = filledBefore + index;
                  final isFilled = globalIndex < filledStamps;
                  return Padding(
                    padding:
                        EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
                    child: Container(
                      width: stampSize,
                      height: stampSize,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFilled
                              ? badgeColor
                              : badgeColor.withValues(alpha: 0.6),
                          width: 1.3,
                        ),
                      ),
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border_rounded,
                        color: color,
                        size: stampSize * 0.55,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class SuggestedProgramsList extends StatelessWidget {
  const SuggestedProgramsList({super.key, required this.onTapDiscover});

  final VoidCallback onTapDiscover;

  Color _parseColor(String raw, Color fallback) {
    if (raw.isEmpty) return fallback;
    try {
      final cleaned = raw.replaceAll('#', '');
      return Color(int.parse('0xFF$cleaned'));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggested programs',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
            ),
            TextButton(
              onPressed: onTapDiscover,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<ProgramsRecord>>(
          stream: queryProgramsRecord(
            queryBuilder: (q) => q.orderBy('created_at', descending: true).limit(10),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final programs = snapshot.data!;
            if (programs.isEmpty) {
              return Text(
                'No programs yet',
                style: FlutterFlowTheme.of(context).bodyMedium,
              );
            }
            return SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: programs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = programs[index];
                  final bg = _parseColor(p.passBackgroundColor, const Color(0xFF3478F6));
                  final fg = _parseColor(p.passForegroundColor, Colors.white);
                  final label =
                      _parseColor(p.passLabelColor, fg.withValues(alpha: 0.8));
                  final iconUrl = p.passLogo.isNotEmpty
                      ? p.passLogo
                      : (p.businessIcon.isNotEmpty ? p.businessIcon : p.passIcon);
                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color(0x15000000),
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              backgroundImage:
                                  iconUrl.isNotEmpty ? NetworkImage(iconUrl) : null,
                              child: iconUrl.isEmpty
                                  ? Icon(Icons.store, color: fg, size: 18)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: label, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          'Stamps required: ${p.stampsRequired}',
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
