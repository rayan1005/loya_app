import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/merchant/components/merchant_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _MdWidgetState extends State<MdWidget> {
  late MdModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MdModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantRef =
        widget.marchentsId ?? currentUserDocument?.linkedMerchants;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        bottomNavigationBar: MerchantNavBar(
          currentTab: MerchantNavTab.dashboard,
          merchantRef: merchantRef,
        ),
        body: SafeArea(
          child: merchantRef == null
              ? Center(
                  child: Text(
                    'Account is not linked to a merchant.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                )
              : StreamBuilder<MerchantsRecord>(
                  stream: MerchantsRecord.getDocument(merchantRef),
                  builder: (context, merchantSnap) {
                    if (!merchantSnap.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      );
                    }
                    final merchant = merchantSnap.data!;
                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 120.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(context, merchant),
                          const SizedBox(height: 16),
                          _actionButtons(context),
                          const SizedBox(height: 22),
                          Text(
                            'My programs',
                            style:
                                FlutterFlowTheme.of(context).titleLarge.override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _programsList(context, merchantRef),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, MerchantsRecord merchant) {
    final displayName = merchant.displayName.isNotEmpty
        ? merchant.displayName
        : (merchant.name.isNotEmpty ? merchant.name : 'Business');
    final photo = merchant.photoUrl.isNotEmpty
        ? merchant.photoUrl
        : (merchant.logoUrl.isNotEmpty ? merchant.logoUrl : currentUserPhoto);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor:
              FlutterFlowTheme.of(context).secondaryBackground,
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty
              ? Icon(Icons.storefront,
                  color: FlutterFlowTheme.of(context).primary, size: 28)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                merchant.email.isNotEmpty
                    ? merchant.email
                    : 'Manage your loyalty programs',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.interTight(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () =>
              context.pushNamed(MerchantProfileWidget.routeName),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FFButtonWidget(
            onPressed: () => context.pushNamed(MerchantScanWidget.routeName),
            text: 'Scan & Stamp',
            options: FFButtonOptions(
              height: 52,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
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
            onPressed: () =>
                context.pushNamed(CreatNewProWidget.routeName),
            text: 'Create Program',
            options: FFButtonOptions(
              height: 52,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _programsList(
      BuildContext context, DocumentReference<Object?> merchantRef) {
    return StreamBuilder<List<ProgramsRecord>>(
      stream: queryProgramsRecord(
        queryBuilder: (q) => q
            .where('merchant_id', isEqualTo: merchantRef)
            .orderBy('created_at', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary),
            ),
          );
        }
        final programs = snapshot.data!;
        if (programs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: FlutterFlowTheme.of(context).alternate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have no programs yet.',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first program to start stamping customers.',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 12),
                FFButtonWidget(
                  onPressed: () =>
                      context.pushNamed(CreatNewProWidget.routeName),
                  text: 'Create Program',
                  options: FFButtonOptions(
                    height: 46,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleSmall
                        .override(
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

        return Column(
          children: programs
              .map(
                (program) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _programCard(context, program),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _programCard(BuildContext context, ProgramsRecord program) {
    final iconUrl = program.passLogo.isNotEmpty
        ? program.passLogo
        : (program.passIcon.isNotEmpty
            ? program.passIcon
            : (program.businessIcon.isNotEmpty ? program.businessIcon : ''));
    final subtitle = program.rewardDetails.isNotEmpty
        ? program.rewardDetails
        : (program.description.isNotEmpty ? program.description : '');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.pushNamed(
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
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              color: Color(0x11000000),
              offset: Offset(0, 8),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: iconUrl.isNotEmpty
                  ? Image.network(iconUrl, fit: BoxFit.cover)
                  : Icon(Icons.card_giftcard,
                      color: FlutterFlowTheme.of(context).primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (program.status
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).secondaryText)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          program.status ? 'Active' : 'Inactive',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: program.status
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context)
                                        .secondaryText,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.interTight(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Stamps required: ${program.stampsRequired}',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.pushNamed(
                          MerchantProgramDetailsWidget.routeName,
                          queryParameters: {
                            'programRef': serializeParam(
                              program.reference,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                        ),
                        child: Text(
                          'Details',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
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
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
