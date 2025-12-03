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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0.0,
          title: Text(
            'البرامج المتاحة',
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
          child: StreamBuilder<List<ProgramsRecord>>(
            stream: queryProgramsRecord(
              queryBuilder: (programsRecord) => programsRecord
                  .where('status', isEqualTo: true)
                  .orderBy('created_at', descending: true),
            ),
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
              final programs = snapshot.data!;
              if (programs.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد برامج متاحة حالياً.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                );
              }
              final filteredPrograms = programs
                  .where((p) =>
                      !p.hasExpiryDate() ||
                      (p.expiryDate != null &&
                          p.expiryDate!.isAfter(DateTime.now())))
                  .toList();
              if (filteredPrograms.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد برامج متاحة حالياً.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 32.0),
                itemCount: filteredPrograms.length,
                itemBuilder: (context, index) {
                  final program = filteredPrograms[index];
                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
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
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 16.0,
                              color: Color(0x1F000000),
                              offset: Offset(0.0, 8.0),
                            )
                          ],
                        ),
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 16.0, 16.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (program.hasBusinessIcon())
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  program.businessIcon,
                                  width: double.infinity,
                                  height: 140.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (program.hasBusinessIcon())
                              const SizedBox(
                                height: 10.0,
                              ),
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
                            SizedBox(height: 6.0),
                            Text(
                              program.description,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                SizedBox(width: 6.0),
                                Text(
                                  '${program.stampsRequired} طابع مطلوب',
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.0),
                            FFButtonWidget(
                              onPressed: () async {
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
                              text: 'عرض التفاصيل',
                              options: FFButtonOptions(
                                height: 44.0,
                                color: FlutterFlowTheme.of(context).primary,
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
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                borderRadius: BorderRadius.circular(12.0),
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
          ),
        ),
      ),
    );
  }
}
