import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/merchant/components/merchant_nav_bar.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgramsListWidget extends StatefulWidget {
  const ProgramsListWidget({super.key});

  static String routeName = 'ProgramsList';
  static String routePath = 'programsList';

  @override
  State<ProgramsListWidget> createState() => _ProgramsListWidgetState();
}

class _ProgramsListWidgetState extends State<ProgramsListWidget> {
  @override
  Widget build(BuildContext context) {
    final merchantRef = currentUserDocument?.linkedMerchants;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 0.0,
        title: Text(
          'My programs',
          style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.interTight(
                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.pushNamed(CreatNewProWidget.routeName),
          ),
        ],
      ),
      bottomNavigationBar: MerchantNavBar(
        currentTab: MerchantNavTab.programs,
        merchantRef: merchantRef,
      ),
      body: merchantRef == null
          ? Center(
              child: Text(
                'Account is not linked to a merchant.',
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
            )
          : StreamBuilder<List<ProgramsRecord>>(
              stream: queryProgramsRecord(
                queryBuilder: (p) => p
                    .where('merchant_id', isEqualTo: merchantRef)
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No programs yet.',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        FFButtonWidget(
                          onPressed: () => context
                              .pushNamed(CreatNewProWidget.routeName),
                          text: 'Create program',
                          options: FFButtonOptions(
                            height: 44,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600,
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
                return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 16.0, 16.0, 120.0),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 12.0,
                              color: Color(0x1A000000),
                              offset: Offset(0.0, 6.0),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    program.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: program.status
                                        ? FlutterFlowTheme.of(context).primary
                                            .withOpacity(0.1)
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    program.status ? 'Active' : 'Inactive',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                          ),
                                          color: program.status
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              program.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Stamps required: ${program.stampsRequired}',
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                FFButtonWidget(
                                  onPressed: () =>
                                      _showProgramDetails(context, program),
                                  text: 'View',
                                  options: FFButtonOptions(
                                    height: 38.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                    elevation: 0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12.0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed(
                                      EditProgramWidget.routeName,
                                      queryParameters: {
                                        'programRef': serializeParam(
                                          program.reference,
                                          ParamType.DocumentReference,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  text: 'Edit',
                                  options: FFButtonOptions(
                                    height: 38.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                    borderRadius:
                                        BorderRadius.circular(12.0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FFButtonWidget(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete program?'),
                                            content: const Text(
                                                'This will remove the program for all users.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                    if (confirm) {
                                      await program.reference.delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Program deleted'),
                                        ),
                                      );
                                    }
                                  },
                                  text: 'Delete',
                                  options: FFButtonOptions(
                                    height: 38.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context).error,
                                        ),
                                    elevation: 0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .error
                                          .withOpacity(0.3),
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _showProgramDetails(
      BuildContext context, ProgramsRecord program) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      program.title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: program.status
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.1)
                            : FlutterFlowTheme.of(context)
                                .secondaryText
                                .withOpacity(0.1),
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
                const SizedBox(height: 8),
                Text(
                  program.description,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(context, 'Stamps required',
                        '${program.stampsRequired}'),
                    if (program.rewardDetails.isNotEmpty)
                      _infoChip(context, 'Reward', program.rewardDetails),
                    if (program.termsConditions.isNotEmpty)
                      _infoChip(context, 'T&C', program.termsConditions),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _colorDot(program.passBackgroundColor, 'Background'),
                    const SizedBox(width: 12),
                    _colorDot(program.passForegroundColor, 'Foreground'),
                    const SizedBox(width: 12),
                    _colorDot(program.passLabelColor, 'Labels'),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FFButtonWidget(
                    onPressed: () => Navigator.pop(ctx),
                    text: 'Close',
                    options: FFButtonOptions(
                      height: 40,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context)
                          .titleSmall
                          .override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
                            color: Colors.white,
                          ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _colorDot(String colorCode, String label) {
    int fallback = 0xFFEEF2F7;
    final colorInt = int.tryParse(colorCode.replaceAll('#', '0xff'));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Color(colorInt ?? fallback),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33000000)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
