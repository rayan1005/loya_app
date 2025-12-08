import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'program_browse_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProgramBrowseWidget extends StatefulWidget {
  const ProgramBrowseWidget({super.key});

  static String routeName = 'ProgramBrowse';
  static String routePath = 'programBrowse';

  @override
  State<ProgramBrowseWidget> createState() => _ProgramBrowseWidgetState();
}

class _ProgramBrowseWidgetState extends State<ProgramBrowseWidget> {
  late ProgramBrowseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramBrowseModel());
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
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Browse programs',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find a loyalty program',
                        style: FlutterFlowTheme.of(context).headlineSmall
                            .override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join, collect stamps, and redeem rewards.',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<ProgramsRecord>>(
                  stream: queryProgramsRecord(
                    queryBuilder: (programsRecord) => programsRecord
                        .where('status', isEqualTo: true)
                        .orderBy('created_at', descending: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final programs = snapshot.data!
                        .where((p) =>
                            !p.hasExpiryDate() ||
                            (p.expiryDate != null &&
                                p.expiryDate!.isAfter(DateTime.now())))
                        .toList();
                    if (programs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No programs available now.',
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: programs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        return _programCard(context, program);
                      },
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

  Widget _programCard(BuildContext context, ProgramsRecord program) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
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
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x14000000),
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (program.hasBusinessIcon())
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  program.businessIcon,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: FlutterFlowTheme.of(context).primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${program.stampsRequired} stamps required',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      const Spacer(),
                      if (program.rewardDetails.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            program.rewardDetails,
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      height: 44,
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
            ),
          ],
        ),
      ),
    );
  }
}
