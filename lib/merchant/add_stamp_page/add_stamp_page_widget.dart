import 'dart:math' as math;

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/merchant/components/merchant_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_stamp_page_model.dart';

export 'add_stamp_page_model.dart';

class AddStampPageWidget extends StatefulWidget {
  const AddStampPageWidget({super.key});

  @override
  State<AddStampPageWidget> createState() => _AddStampPageWidgetState();
}

class _AddStampPageWidgetState extends State<AddStampPageWidget> {
  late AddStampPageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddStampPageModel());
    _model.emailAddressTextController ??=
        TextEditingController(text: FFAppState().addNewStamp.toString());
    _model.emailAddressFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _updateCount(int value) {
    FFAppState().addNewStamp = value.clamp(0, 20);
    _model.emailAddressTextController?.text =
        FFAppState().addNewStamp.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: MerchantNavBar(
        currentTab: MerchantNavTab.programs,
        merchantRef: currentUserDocument?.linkedMerchants,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF4B39EF)],
            begin: AlignmentDirectional(0.87, -1.0),
            end: AlignmentDirectional(-0.87, 1.0),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Add Stamps',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan result',
                    style: FlutterFlowTheme.of(context)
                        .labelMedium
                        .override(fontFamily: 'Inter', color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    context,
                    label: 'Serial',
                    value: FFAppState().qrserial,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    context,
                    label: 'Program ID',
                    value: FFAppState().qrprogramid,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    context,
                    label: 'User ID',
                    value: FFAppState().qruid,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Select how many stamps to add',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlutterFlowIconButton(
                              borderRadius: 10,
                              buttonSize: 44,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.remove,
                                color: FlutterFlowTheme.of(context).info,
                              ),
                              onPressed: () => _updateCount(
                                math.max(0, FFAppState().addNewStamp - 1),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: TextFormField(
                                controller: _model.emailAddressTextController,
                                focusNode: _model.emailAddressFocusNode,
                                textAlign: TextAlign.center,
                                readOnly: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style:
                                    FlutterFlowTheme.of(context).headlineMedium,
                              ),
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 10,
                              buttonSize: 44,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.add,
                                color: FlutterFlowTheme.of(context).info,
                              ),
                              onPressed: () => _updateCount(
                                math.min(20, FFAppState().addNewStamp + 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FFButtonWidget(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Adding ${FFAppState().addNewStamp} stamp(s)'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            context.pop();
                          },
                          text: 'Confirm',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 52,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle:
                                FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                            elevation: 3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '—',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
        ],
      ),
    );
  }
}
