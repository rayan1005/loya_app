import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MerchantProgramDetailsWidget extends StatelessWidget {
  const MerchantProgramDetailsWidget({
    super.key,
    required this.programRef,
  });

  final DocumentReference programRef;

  static String routeName = 'MerchantProgramDetails';
  static String routePath = 'merchantProgramDetails';

  Color _parseColor(String input, Color fallback) {
    try {
      if (input.trim().isEmpty) return fallback;
      final value =
          int.tryParse(input.trim().replaceAll('#', ''), radix: 16);
      if (value == null) return fallback;
      return Color(0xFF000000 | value);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgramsRecord>(
      stream: ProgramsRecord.getDocument(programRef),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final program = snapshot.data!;
        final bgColor =
            _parseColor(program.passBackgroundColor, const Color(0xFF0A84FF));
        final fgColor = _parseColor(program.passForegroundColor, Colors.white);
        final labelColor =
            _parseColor(program.passLabelColor, Colors.white70);

        return Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              program.title.isNotEmpty ? program.title : 'Program',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PassPreview(
                    program: program,
                    backgroundColor: bgColor,
                    foregroundColor: fgColor,
                    labelColor: labelColor,
                  ),
                  const SizedBox(height: 20),
                  FFButtonWidget(
                    onPressed: () => context.pushNamed(
                      MerchantScanWidget.routeName,
                      queryParameters: {
                        'programRef': serializeParam(
                          program.reference,
                          ParamType.DocumentReference,
                        ),
                        'programTitle': serializeParam(
                          program.title,
                          ParamType.String,
                        ),
                      }.withoutNulls,
                    ),
                    text: 'Scan & Stamp',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: Colors.white,
                              ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FFButtonWidget(
                    onPressed: () => context.pushNamed(
                      EditProgramWidget.routeName,
                      queryParameters: {
                        'programRef': serializeParam(
                          program.reference,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    ),
                    text: 'Edit Program',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete program?'),
                                content: const Text(
                                    'This will remove the program for all users.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (confirm) {
                          await program.reference.delete();
                          if (context.mounted) {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Program deleted'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Delete Program',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                              ),
                              color: FlutterFlowTheme.of(context).error,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PassPreview extends StatelessWidget {
  const _PassPreview({
    required this.program,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.labelColor,
  });

  final ProgramsRecord program;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final iconUrl = program.passLogo.isNotEmpty
        ? program.passLogo
        : (program.passIcon.isNotEmpty
            ? program.passIcon
            : (program.businessIcon.isNotEmpty ? program.businessIcon : ''));
    final reward = program.rewardDetails.isNotEmpty
        ? program.rewardDetails
        : (program.description.isNotEmpty
            ? program.description
            : 'Apple Wallet preview');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: iconUrl.isNotEmpty
                    ? Image.network(iconUrl, fit: BoxFit.cover)
                    : Icon(Icons.star_rounded,
                        color: foregroundColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title.isNotEmpty ? program.title : 'Program',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700,
                            ),
                            color: foregroundColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.interTight(),
                            color: labelColor,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  program.status ? 'Active' : 'Inactive',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        color: foregroundColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Stamps required',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                  ),
                  color: labelColor,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${program.stampsRequired}',
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w800,
                  ),
                  color: foregroundColor,
                ),
          ),
          const SizedBox(height: 10),
          if (program.termsConditions.isNotEmpty)
            Text(
              program.termsConditions,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.interTight(),
                    color: labelColor,
                  ),
            ),
          if (program.expiryDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Expires ${dateTimeFormat('d/M/y', program.expiryDate)}',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                    ),
                    color: foregroundColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
