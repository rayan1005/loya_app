import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/stamp_count_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/merchant/programs_list/programs_list_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  static const int _maxStamps = 12;
  int _stampsRequired = 6;

  bool _colorsValid(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    return RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(value.trim());
  }

  final List<String> _colorSwatches = const [
    '#4A90E2',
    '#1ABC9C',
    '#F5A623',
    '#E74C3C',
    '#8E44AD',
    '#2C3E50',
    '#16A085',
    '#F39C12',
  ];

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatNewProModel());

    _model.textController2 ??= TextEditingController();
    _model.textController3 ??= TextEditingController();
    _model.textController4 ??= TextEditingController();
    _model.textController5 ??= TextEditingController();
    _model.passBgColorController ??=
        TextEditingController(text: '#007AFF');
    _model.passFgColorController ??=
        TextEditingController(text: '#FFFFFF');
    _model.passLabelColorController ??=
        TextEditingController(text: '#FFFFFF');
    _stampsRequired = _stampsRequired.clamp(1, _maxStamps);
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
            (m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          title: const Text('Create New Program'),
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.safePop(),
          ),
        ),
        body: SafeArea(
          top: true,
          bottom: true,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final previewBg = _safeColor(_model.passBgColorController?.text,
        const Color(0xFF007AFF));
    final previewFg =
        _safeColor(_model.passFgColorController?.text, Colors.white);
    final previewLabel =
        _safeColor(_model.passLabelColorController?.text, previewFg);
    final programTitle = (_model.textController2?.text ?? '').trim();
    final programDescription = (_model.textController3?.text ?? '').trim();
    final rewardPreview = (_model.textController4?.text ?? '').trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Create Program',
              style: FlutterFlowTheme.of(context).titleLarge,
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Images & Icons',
              children: [
                _uploadButton(
                  label: 'Upload business icon',
                  loading: _model.isDataUploading_uploadData5kx,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) => setState(
                          () => _model.isDataUploading_uploadData5kx = u),
                      onUploaded: (url) => setState(
                          () => _model.uploadedFileUrl_uploadData5kx = url),
                    );
                  },
                ),
                _uploadButton(
                  label: 'Upload stamp icon',
                  loading: _model.isDataUploading_uploadDataXoh,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) =>
                          setState(() => _model.isDataUploading_uploadDataXoh = u),
                      onUploaded: (url) =>
                          setState(() => _model.uploadedFileUrl_uploadDataXoh = url),
                    );
                  },
                ),
                _uploadButton(
                  label: 'Upload background (optional)',
                  loading: _model.isDataUploading_background,
                  onTap: () async {
                    await _pickAndUpload(
                      onUploading: (u) => setState(
                          () => _model.isDataUploading_background = u),
                      onUploaded: (url) => setState(
                          () => _model.uploadedFileUrl_background = url),
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
                  controller: _model.textController2,
                ),
                _textField(
                  label: 'Description',
                  controller: _model.textController3,
                  maxLines: 2,
                ),
                _textField(
                  label: 'Reward',
                  controller: _model.textController4,
                ),
                _stampPicker(context),
                _textField(
                  label: 'Terms & conditions',
                  controller: _model.textController5,
                  maxLines: 3,
                ),
              ],
            ),

            _sectionCard(
              title: 'Colors',
              children: [
                Text(
                  'Pick a palette for the pass',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colorSwatches.map((hex) {
                    final color = _safeColor(hex, Colors.blue);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _model.passBgColorController?.text = hex;
                          _model.passFgColorController?.text = '#FFFFFF';
                          _model.passLabelColorController?.text = hex;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('Advanced (optional): enter hex manually',
                    style: FlutterFlowTheme.of(context).bodySmall),
                _textField(
                  label: 'Background color (e.g. #007AFF)',
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
                    borderRadius: BorderRadius.circular(16),
                    image: _model.uploadedFileUrl_background.isNotEmpty
                        ? DecorationImage(
                            image:
                                NetworkImage(_model.uploadedFileUrl_background),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                previewBg.withValues(alpha: 0.45),
                                BlendMode.srcATop),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_model.uploadedFileUrl_uploadData5kx.isNotEmpty)
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  _model.uploadedFileUrl_uploadData5kx),
                            )
                          else
                            const CircleAvatar(
                                radius: 24, child: Icon(Icons.store)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                programTitle.isNotEmpty
                                    ? programTitle
                                    : 'Add a program title',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: previewFg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Status: Active',
                                style: TextStyle(
                                  color: previewLabel,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (programDescription.isNotEmpty)
                        Text(
                          programDescription,
                          style: TextStyle(
                            color: previewLabel,
                          ),
                        )
                      else
                        Text(
                          'Add a short program description',
                          style: TextStyle(
                            color: previewLabel.withOpacity(0.7),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        rewardPreview.isNotEmpty
                            ? rewardPreview
                            : 'Describe the reward customers unlock',
                        style: TextStyle(
                          color: previewFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(
                          _stampsRequired.clamp(1, _maxStamps),
                          (index) {
                            final isFilled = index == 0;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: isFilled
                                    ? previewFg
                                    : previewFg.withOpacity(0.35),
                                child: _model.uploadedFileUrl_uploadDataXoh
                                        .isNotEmpty
                                    ? Image.network(
                                        _model.uploadedFileUrl_uploadDataXoh,
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        isFilled ? Icons.check : Icons.star,
                                        size: 16,
                                        color:
                                            isFilled ? previewBg : previewFg,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.qr_code, size: 38),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wallet pass preview',
                                    style: TextStyle(
                                      color: previewFg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _model.textController5?.text.isNotEmpty ==
                                            true
                                        ? _model.textController5!.text
                                        : 'Terms & conditions preview',
                                    style: TextStyle(
                                      color: previewLabel,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                if (merchantRef == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No merchant linked.')),
                  );
                  return;
                }
                final title = _model.textController2?.text.trim() ?? '';
                final desc = _model.textController3?.text.trim() ?? '';
                final reward = _model.textController4?.text.trim() ?? '';
                final terms = _model.textController5?.text.trim() ?? '';

                final missing = <String>[];
                if (title.isEmpty) missing.add('title');
                if (desc.isEmpty) missing.add('description');
                if (reward.isEmpty) missing.add('reward');
                if (terms.isEmpty) missing.add('terms & conditions');
                if (missing.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please fill: ${missing.join(', ')}',
                      ),
                    ),
                  );
                  return;
                }
                if (_model.uploadedFileUrl_uploadData5kx.isEmpty ||
                    _model.uploadedFileUrl_uploadDataXoh.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please upload business and stamp icons.')),
                  );
                  return;
                }
                if (!_colorsValid(_model.passBgColorController?.text) ||
                    !_colorsValid(_model.passFgColorController?.text) ||
                    !_colorsValid(_model.passLabelColorController?.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid hex colors.')),
                  );
                  return;
                }

                try {
                  final docRef = ProgramsRecord.collection.doc();
                  await docRef.set({
                    ...createProgramsRecordData(
                      programId: docRef.id,
                      merchantId: merchantRef,
                      title: title,
                      description: desc,
                      rewardDetails: reward,
                      stampsRequired: _stampsRequired,
                      termsConditions: terms,
                      businessIcon: _model.uploadedFileUrl_uploadData5kx,
                      stampIcon: _model.uploadedFileUrl_uploadDataXoh,
                      passBackgroundColor:
                          _model.passBgColorController?.text.trim(),
                      passForegroundColor:
                          _model.passFgColorController?.text.trim(),
                      passLabelColor:
                          _model.passLabelColorController?.text.trim(),
                      status: true,
                      createdAt: getCurrentTimestamp,
                    ),
                    ...mapToFirestore({
                      'program_background': _model.uploadedFileUrl_background,
                    }),
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Program created.')),
                  );
                  context.goNamed(ProgramsListWidget.routeName);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to create program: $e')),
                  );
                }
              },
              text: 'Create program',
              options: FFButtonOptions(
                height: 52,
                width: double.infinity,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: const TextStyle(color: Colors.white),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
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

  Widget _stampPicker(BuildContext context) {
    return StampCountPicker(
      title: 'Stamps required',
      value: _stampsRequired,
      maxValue: _maxStamps,
      helperText:
          'Limited to 12 stamps to keep the Wallet strip fully visible.',
      onChanged: (value) => setState(
        () => _stampsRequired = value.clamp(1, _maxStamps),
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
          width: double.infinity,
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
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
