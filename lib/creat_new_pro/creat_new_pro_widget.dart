import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:from_css_color/from_css_color.dart';

import 'creat_new_pro_model.dart';
export 'creat_new_pro_model.dart';

class CreatNewProWidget extends StatefulWidget {
  const CreatNewProWidget({super.key});

  static String routeName = 'CreatNewPro';
  static String routePath = 'creatNewPro';

  @override
  State<CreatNewProWidget> createState() => _CreatNewProWidgetState();
}

class _CreatNewProWidgetState extends State<CreatNewProWidget> {
  late CreatNewProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _colorsValid(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    return RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(value.trim());
  }

  Color _safeColor(String? input, Color fallback) {
    try {
      if (input == null || input.trim().isEmpty) return fallback;
      final txt =
          input.trim().startsWith('#') ? input.trim() : '#${input.trim()}';
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
    _model.passBgColorController ??=
        TextEditingController(text: '#007AFF');
    _model.passFgColorController ??=
        TextEditingController(text: '#FFFFFF');
    _model.passLabelColorController ??=
        TextEditingController(text: '#FFFFFF');
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

    if (selectedMedia == null ||
        !selectedMedia.every(
            (m) => validateFileFormat(m.storagePath, context))) return;

    onUploading(true);

    try {
      final urls = await Future.wait(
        selectedMedia.map(
          (m) => uploadData(m.storagePath, m.bytes),
        ),
      );

      final validUrls = urls.whereType<String>().toList();
      if (validUrls.isNotEmpty) {
        onUploaded(validUrls.first);
      }
    } finally {
      onUploading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final previewBg = _safeColor(_model.passBgColorController?.text,
        const Color(0xFF007AFF));
    final previewFg =
        _safeColor(_model.passFgColorController?.text, Colors.white);
    final previewLabel =
        _safeColor(_model.passLabelColorController?.text, previewFg);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        title: const Text('Create New Program'),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'Images & Icons',
              children: [
                _uploadButton(
                  label: 'Upload business icon',
                  loading: _model.isUploadingBusinessIcon,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) => setState(
                          () => _model.isUploadingBusinessIcon = u),
                      onUploaded: (url) =>
                          setState(() => _model.businessIconUrl = url),
                    );
                  },
                ),
                _uploadButton(
                  label: 'Upload stamp icon',
                  loading: _model.isUploadingStampIcon,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) =>
                          setState(() => _model.isUploadingStampIcon = u),
                      onUploaded: (url) =>
                          setState(() => _model.stampIconUrl = url),
                    );
                  },
                ),
                _uploadButton(
                  label: 'Upload Wallet icon',
                  loading: _model.isUploadingPassIcon,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) =>
                          setState(() => _model.isUploadingPassIcon = u),
                      onUploaded: (url) =>
                          setState(() => _model.passIconUrl = url),
                    );
                  },
                ),
                _uploadButton(
                  label: 'Upload Wallet logo',
                  loading: _model.isUploadingPassLogo,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) =>
                          setState(() => _model.isUploadingPassLogo = u),
                      onUploaded: (url) =>
                          setState(() => _model.passLogoUrl = url),
                    );
                  },
                ),
              ],
            ),

            _sectionCard(
              title: 'Program details',
              children: [
                _textField(
                  label: 'Program title',
                  controller: _model.titleController,
                ),
                _textField(
                  label: 'Description',
                  controller: _model.descriptionController,
                  maxLines: 2,
                ),
                _textField(
                  label: 'Reward',
                  controller: _model.rewardController,
                ),
                TextField(
                  controller: _model.textFieldNumberTextController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Stamps required'),
                ),
                _textField(
                  label: 'Terms & conditions',
                  controller: _model.termsController,
                  maxLines: 3,
                ),
              ],
            ),

            _sectionCard(
              title: 'Apple Wallet colors',
              children: [
                _textField(
                  label: 'Background color',
                  controller: _model.passBgColorController,
                ),
                _textField(
                  label: 'Foreground color',
                  controller: _model.passFgColorController,
                ),
                _textField(
                  label: 'Label color',
                  controller: _model.passLabelColorController,
                ),
                const SizedBox(height: 12),

                // PREVIEW
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: previewBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _model.titleController?.text.isNotEmpty == true
                            ? _model.titleController!.text
                            : 'Loya Program',
                        style: TextStyle(
                          fontSize: 20,
                          color: previewFg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _model.descriptionController?.text.isNotEmpty == true
                            ? _model.descriptionController!.text
                            : 'Preview text',
                        style: TextStyle(
                          color: previewLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            FFButtonWidget(
              onPressed: () async {
                final merchantRef = currentUserDocument?.linkedMerchants;
                if (merchantRef == null) return;

                await ProgramsRecord.collection.doc().set({
                  'merchantId': merchantRef,
                  'title': _model.titleController?.text,
                  'description': _model.descriptionController?.text,
                  'rewardDetails': _model.rewardController?.text,
                  'businessIcon': _model.businessIconUrl,
                  'stampIcon': _model.stampIconUrl,
                  'passIcon': _model.passIconUrl,
                  'passLogo': _model.passLogoUrl,
                  'passBackgroundColor':
                      _model.passBgColorController?.text.trim(),
                  'passForegroundColor':
                      _model.passFgColorController?.text.trim(),
                  'passLabelColor':
                      _model.passLabelColorController?.text.trim(),
                  'created_at': FieldValue.serverTimestamp(),
                });

                context.pushNamed('MD');
              },
              text: 'Create program',
              options: FFButtonOptions(
                height: 52,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: const TextStyle(color: Colors.white),
                borderRadius: BorderRadius.circular(14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x11000000),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _uploadButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FFButtonWidget(
        onPressed: loading ? null : onTap,
        text: loading ? '$label...' : label,
        options: FFButtonOptions(
          height: 44,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          textStyle:
              TextStyle(color: FlutterFlowTheme.of(context).primary),
          borderSide:
              BorderSide(color: FlutterFlowTheme.of(context).alternate),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
