import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:from_css_color/from_css_color.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'creat_new_pro_model.dart';
export 'creat_new_pro_model.dart';

class CreatNewProWidget extends StatefulWidget {
  const CreatNewProWidget({super.key});

  static String routeName = 'CreatNewPro';
  static String routePath = 'creatNewPro';

  @override
  State<CreatNewProWidget> createState() => _CreatNewProWidgetState();
}

class _CreatNewProWidgetState extends State<CreatNewProWidget>
    with TickerProviderStateMixin {
  late CreatNewProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  bool _colorsValid() {
    final hex = RegExp(r'^#?[0-9a-fA-F]{6}$');
    return (_model.passBgColorController?.text.trim().isEmpty ?? true ||
            hex.hasMatch(_model.passBgColorController!.text.trim())) &&
        (_model.passFgColorController?.text.trim().isEmpty ?? true ||
            hex.hasMatch(_model.passFgColorController!.text.trim())) &&
        (_model.passLabelColorController?.text.trim().isEmpty ?? true ||
            hex.hasMatch(_model.passLabelColorController!.text.trim()));
  }

  Color _safeColor(String? input, Color fallback) {
    try {
      if (input == null || input.trim().isEmpty) return fallback;
      final txt = input.trim().startsWith('#') ? input.trim() : '#${input.trim()}';
      return fromCssColor(txt);
    } catch (_) {
      return fallback;
    }
  }

  double? _parseDouble(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return double.tryParse(text.trim());
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatNewProModel());

    _model.textFieldNumberTextController ??= TextEditingController(text: '6');
    _model.textFieldNumberFocusNode ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
    _model.passBgColorController ??= TextEditingController(text: '#007AFF');
    _model.passBgColorFocusNode ??= FocusNode();
    _model.passFgColorController ??= TextEditingController(text: '#FFFFFF');
    _model.passFgColorFocusNode ??= FocusNode();
    _model.passLabelColorController ??= TextEditingController(text: '#FFFFFF');
    _model.passLabelColorFocusNode ??= FocusNode();
    _model.latController ??= TextEditingController();
    _model.lngController ??= TextEditingController();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
Duration(milliseconds: 0)
Duration(milliseconds: 300)
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
Duration(milliseconds: 0)
Duration(milliseconds: 300)
            begin: Offset(0.0, 140.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload({
    required void Function(String url) onUploaded,
    required void Function(bool uploading) onUploading,
  }) async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia != null &&
        selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      onUploading(true);
      try {
        final downloadUrls = (await Future.wait(
          selectedMedia.map(
            (m) async => await uploadData(m.storagePath, m.bytes),
          ),
        ))
            .whereType<String>()
            .toList();
        if (downloadUrls.isNotEmpty) {
          onUploaded(downloadUrls.first);
        }
      } finally {
        onUploading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final previewBg =
        _safeColor(_model.passBgColorController?.text, const Color(0xFF007AFF));
    final previewFg =
        _safeColor(_model.passFgColorController?.text, Colors.white);
    final previewLabel =
        _safeColor(_model.passLabelColorController?.text, previewFg);

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
          title: Text(
            'Create New Program',
            style: FlutterFlowTheme.of(context).titleLarge,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  context,
                  title: 'Images & icons',
                  children: [
                    _uploadButton(
                      context,
                      label: 'Upload business icon',
                      loading: _model.isDataUploading_uploadData5kx,
                      onTap: () async {
                        await _pickAndUpload(
                          onUploading: (u) => safeSetState(
                              () => _model.isDataUploading_uploadData5kx = u),
                          onUploaded: (url) => safeSetState(
                              () => _model.uploadedFileUrl_uploadData5kx = url),
                        );
                      },
                    ),
                    _uploadButton(
                      context,
                      label: 'Upload stamp icon',
                      loading: _model.isDataUploading_uploadDataXoh,
                      onTap: () async {
                        await _pickAndUpload(
                          onUploading: (u) =>
                              safeSetState(() => _model.isDataUploading_uploadDataXoh = u),
                          onUploaded: (url) => safeSetState(
                              () => _model.uploadedFileUrl_uploadDataXoh = url),
                        );
                      },
                    ),
                    _uploadButton(
                      context,
                      label: 'Upload Apple Wallet icon',
                      loading: _model.isDataUploading_passIcon,
                      onTap: () async {
                        await _pickAndUpload(
                          onUploading: (u) =>
                              safeSetState(() => _model.isDataUploading_passIcon = u),
                          onUploaded: (url) => safeSetState(
                              () => _model.uploadedFileUrl_passIcon = url),
                        );
                      },
                    ),
                    _uploadButton(
                      context,
                      label: 'Upload Apple Wallet logo',
                      loading: _model.isDataUploading_passLogo,
                      onTap: () async {
                        await _pickAndUpload(
                          onUploading: (u) =>
                              safeSetState(() => _model.isDataUploading_passLogo = u),
                          onUploaded: (url) => safeSetState(
                              () => _model.uploadedFileUrl_passLogo = url),
                        );
                      },
                    ),
                  ],
                ),
                _sectionCard(
                  context,
                  title: 'Program details',
                  children: [
                    _fieldLabel(context, 'Program title'),
                    _textField(
                      controller: _model.textController2,
                      focusNode: _model.textFieldFocusNode1,
                      hint: 'Program name',
                    ),
                    _fieldLabel(context, 'Description'),
                    _textField(
                      controller: _model.textController3,
                      focusNode: _model.textFieldFocusNode2,
                      hint: 'Describe the program',
                      maxLines: 3,
                    ),
                    _fieldLabel(context, 'Reward details'),
                    _textField(
                      controller: _model.textController4,
                      focusNode: _model.textFieldFocusNode3,
                      hint: 'Example: Free coffee after 6 stamps',
                      maxLines: 2,
                    ),
                    _fieldLabel(context, 'Stamps required to redeem'),
                    TextFormField(
                      controller: _model.textFieldNumberTextController,
                      focusNode: _model.textFieldNumberFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      decoration: InputDecoration(
                        hintText: '6',
                        filled: true,
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate),
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    _fieldLabel(context, 'Terms & conditions'),
                    _textField(
                      controller: _model.textController5,
                      focusNode: _model.textFieldFocusNode4,
                      hint: 'Add any terms',
                      maxLines: 4,
                    ),
                  ],
                ),
                _sectionCard(
                  context,
                  title: 'Apple Wallet colors (HEX)',
                  children: [
                    _textField(
                      controller: _model.passBgColorController,
                      focusNode: _model.passBgColorFocusNode,
                      hint: '#007AFF',
                      label: 'Background color',
                    ),
                    SizedBox(height: 8),
                    _textField(
                      controller: _model.passFgColorController,
                      focusNode: _model.passFgColorFocusNode,
                      hint: '#FFFFFF',
                      label: 'Foreground color',
                    ),
                    SizedBox(height: 8),
                    _textField(
                      controller: _model.passLabelColorController,
                      focusNode: _model.passLabelColorFocusNode,
                      hint: '#FFFFFF',
                      label: 'Label color',
                    ),
                    SizedBox(height: 8),
                    _textField(
                      controller: _model.latController,
                      focusNode: _model.latFocusNode,
                      hint: '24.7136',
                      label: 'Store latitude (optional)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _textField(
                      controller: _model.lngController,
                      focusNode: _model.lngFocusNode,
                      hint: '46.6753',
                      label: 'Store longitude (optional)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: previewBg,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _model.textController2?.text.isNotEmpty == true
                                ? _model.textController2!.text
                                : 'Loya Program',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: previewFg,
                                ),
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            _model.textController3?.text.isNotEmpty == true
                                ? _model.textController3!.text
                                : 'Apple Wallet preview',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.interTight(),
                                  color: previewLabel,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!_colorsValid())
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Use valid HEX colors (example: #AABBCC)',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.interTight(),
                                color: FlutterFlowTheme.of(context).error,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: () async {
                    if (!_colorsValid()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Please enter valid HEX colors (e.g. #AABBCC).'),
                        ),
                      );
                      return;
                    }

                    final merchantRef = currentUserDocument?.linkedMerchants;
                    if (merchantRef == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Merchant profile not found.'),
                        ),
                      );
                      return;
                    }

                    await ProgramsRecord.collection.doc().set({
                      ...createProgramsRecordData(
                        merchantId: merchantRef,
                        title: _model.textController2?.text.trim(),
                        description: _model.textController3?.text.trim(),
                        rewardType: _model.textController4?.text.trim(),
                        rewardDetails: _model.textController4?.text.trim(),
                        stampsRequired: int.tryParse(
                            _model.textFieldNumberTextController.text.trim()),
                        stampIcon: _model.uploadedFileUrl_uploadDataXoh,
                        status: true,
                        termsConditions: _model.textController5?.text.trim(),
                        businessIcon: _model.uploadedFileUrl_uploadData5kx,
                        passBackgroundColor:
                            _model.passBgColorController?.text.trim(),
                        passForegroundColor:
                            _model.passFgColorController?.text.trim(),
                        passLabelColor:
                            _model.passLabelColorController?.text.trim(),
                        passIcon: _model.uploadedFileUrl_passIcon,
                        passLogo: _model.uploadedFileUrl_passLogo,
                        latitude: _parseDouble(_model.latController?.text),
                        longitude: _parseDouble(_model.lngController?.text),
                      ),
                      ...mapToFirestore({
                        'created_at': FieldValue.serverTimestamp(),
                        'number': FFAppState().stampCountInput,
                      }),
                    });

                    context.pushNamed(
                      MdWidget.routeName,
                      queryParameters: {
                        'marchentsId': serializeParam(
                          merchantRef,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );
                  },
                  text: 'Create program',
                  options: FFButtonOptions(
                    height: 52.0,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleMedium
                        .override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.white,
                        ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ]
                  .addToStart(SizedBox(height: 8))
                  .addToEnd(SizedBox(height: 24)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: const Color(0x1A000000),
              offset: const Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.layers, color: FlutterFlowTheme.of(context).primary),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context)
                        .titleMedium
                        .override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).titleSmall,
      ),
    );
  }

  Widget _textField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    String? hint,
    String? label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium,
      ),
    );
  }

  Widget _uploadButton(BuildContext context,
      {required String label,
      required bool loading,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FFButtonWidget(
        onPressed: loading ? null : onTap,
        text: loading ? '$label ...' : label,
        options: FFButtonOptions(
          height: 44.0,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.interTight(
                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                ),
                color: FlutterFlowTheme.of(context).primary,
              ),
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
      ),
    );
  }
}

