import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:from_css_color/from_css_color.dart';

class EditProgramWidget extends StatefulWidget {
  const EditProgramWidget({super.key, this.programRef});

  final DocumentReference? programRef;

  static String routeName = 'EditProgram';
  static String routePath = 'editProgram';

  @override
  State<EditProgramWidget> createState() => _EditProgramWidgetState();
}

class _EditProgramWidgetState extends State<EditProgramWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _rewardController;
  late TextEditingController _termsController;
  late TextEditingController _stampsController;
  late TextEditingController _passBgController;
  late TextEditingController _passFgController;
  late TextEditingController _passLabelController;
  late TextEditingController _broadcastController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  DateTime? _expiryDate;
  bool _status = true;
  bool _saving = false;
  bool _refreshing = false;
  bool _broadcasting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _rewardController = TextEditingController();
    _termsController = TextEditingController();
    _stampsController = TextEditingController();
    _passBgController = TextEditingController(text: '#007AFF');
    _passFgController = TextEditingController(text: '#FFFFFF');
    _passLabelController = TextEditingController(text: '#FFFFFF');
    _broadcastController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rewardController.dispose();
    _termsController.dispose();
    _stampsController.dispose();
    _passBgController.dispose();
    _passFgController.dispose();
    _passLabelController.dispose();
    _broadcastController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Color _parseColor(String input, Color fallback) {
    try {
      if (input.trim().isEmpty) return fallback;
      final txt = input.trim().startsWith('#') ? input.trim() : '#${input.trim()}';
      return fromCssColor(txt);
    } catch (_) {
      return fallback;
    }
  }

  bool _colorsValid() {
    final hex = RegExp(r'^#?[0-9a-fA-F]{6}$');
    return (_passBgController.text.isEmpty ||
            hex.hasMatch(_passBgController.text.trim())) &&
        (_passFgController.text.isEmpty ||
            hex.hasMatch(_passFgController.text.trim())) &&
        (_passLabelController.text.isEmpty ||
            hex.hasMatch(_passLabelController.text.trim()));
  }

  Future<void> _save(ProgramsRecord program) async {
    if (_saving) return;
    if (!_colorsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid HEX colors (e.g. #007AFF).')),
      );
      return;
    }
    _saving = true;
    setState(() {});

    final stamps = int.tryParse(_stampsController.text.trim());
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    await program.reference.update({
      ...createProgramsRecordData(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        rewardDetails: _rewardController.text.trim(),
        termsConditions: _termsController.text.trim(),
        status: _status,
        stampsRequired: stamps,
        expiryDate: _expiryDate,
        passBackgroundColor: _passBgController.text.trim(),
        passForegroundColor: _passFgController.text.trim(),
        passLabelColor: _passLabelController.text.trim(),
        latitude: lat,
        longitude: lng,
      ),
      ...mapToFirestore({
        'updated_at': FieldValue.serverTimestamp(),
      }),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Program updated.')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickDate(DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _refreshPasses(ProgramsRecord program) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final resp =
          await RefreshProgramPassesCall.call(programId: program.reference.id);
      if (resp.succeeded) {
        final updated = RefreshProgramPassesCall.updated(resp.jsonBody) ?? 0;
        final failed = RefreshProgramPassesCall.failed(resp.jsonBody) ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pass refresh: $updated updated, $failed failed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not refresh passes')),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _broadcast(ProgramsRecord program) async {
    if (_broadcasting) return;
    final msg = _broadcastController.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a broadcast message first')),
      );
      return;
    }
    setState(() => _broadcasting = true);
    try {
      final resp = await BroadcastProgramMessageCall.call(
        programId: program.reference.id,
        message: msg,
      );
      if (resp.succeeded) {
        final updated = BroadcastProgramMessageCall.updated(resp.jsonBody) ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast sent to $updated passes')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _broadcasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 0.0,
        title: Text(
          'Edit Program',
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
      ),
      body: widget.programRef == null
          ? Center(
              child: Text(
                'Program not found.',
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
            )
          : StreamBuilder<ProgramsRecord>(
              stream: ProgramsRecord.getDocument(widget.programRef!),
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
                final program = snapshot.data!;
                _titleController.text = _titleController.text.isEmpty
                    ? program.title
                    : _titleController.text;
                _descController.text = _descController.text.isEmpty
                    ? program.description
                    : _descController.text;
                _rewardController.text = _rewardController.text.isEmpty
                    ? program.rewardDetails
                    : _rewardController.text;
                _termsController.text = _termsController.text.isEmpty
                    ? program.termsConditions
                    : _termsController.text;
                _stampsController.text = _stampsController.text.isEmpty
                    ? (program.stampsRequired > 0
                        ? program.stampsRequired.toString()
                        : '')
                    : _stampsController.text;
                _passBgController.text = _passBgController.text.isEmpty
                    ? (program.passBackgroundColor.isNotEmpty
                        ? program.passBackgroundColor
                        : '#007AFF')
                    : _passBgController.text;
                _passFgController.text = _passFgController.text.isEmpty
                    ? (program.passForegroundColor.isNotEmpty
                        ? program.passForegroundColor
                        : '#FFFFFF')
                    : _passFgController.text;
                _passLabelController.text = _passLabelController.text.isEmpty
                    ? (program.passLabelColor.isNotEmpty
                        ? program.passLabelColor
                        : '#FFFFFF')
                    : _passLabelController.text;
                _latController.text = _latController.text.isEmpty
                    ? (program.hasLatitude() ? program.latitude.toString() : '')
                    : _latController.text;
                _lngController.text = _lngController.text.isEmpty
                    ? (program.hasLongitude() ? program.longitude.toString() : '')
                    : _lngController.text;
                _status = _status && program.status;
                _expiryDate = _expiryDate ?? program.expiryDate;

                final bgColor =
                    _parseColor(_passBgController.text, const Color(0xFF007AFF));
                final fgColor = _parseColor(_passFgController.text, Colors.white);
                final labelColor =
                    _parseColor(_passLabelController.text, fgColor);

                return SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 16.0, 16.0, 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Program title'),
                      _input(_titleController, 'Enter program title'),
                      _fieldLabel('Description'),
                      _input(_descController, 'Describe the program', maxLines: 3),
                      _fieldLabel('Stamps required'),
                      _input(_stampsController, 'e.g., 10',
                          keyboardType: TextInputType.number),
                      _fieldLabel('Reward details'),
                      _input(_rewardController, 'Reward details', maxLines: 3),
                      _fieldLabel('Terms & conditions'),
                      _input(_termsController, 'Terms', maxLines: 3),
                      _fieldLabel('Expiry date'),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _expiryDate != null
                                  ? dateTimeFormat('yMMMd', _expiryDate!)
                                  : 'No date selected',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () => _pickDate(_expiryDate),
                            text: 'Pick date',
                            options: FFButtonOptions(
                              height: 40.0,
                              color: FlutterFlowTheme.of(context).secondary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      SwitchListTile.adaptive(
                        value: _status,
                        onChanged: (v) => setState(() => _status = v),
                        title: Text('Program active (on/off)'),
                        activeColor: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(height: 20.0),
                      _fieldLabel('Apple Wallet colors (HEX)'),
                      _input(_passBgController, '#007AFF'),
                      _input(_passFgController, '#FFFFFF'),
                      _input(_passLabelController, '#FFFFFF'),
                      _fieldLabel('Store location (latitude)'),
                      _input(_latController, 'e.g., 24.7136'),
                      _fieldLabel('Store location (longitude)'),
                      _input(_lngController, 'e.g., 46.6753'),
                      const SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleController.text.isNotEmpty
                                  ? _titleController.text
                                  : program.title,
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: fgColor,
                                  ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _descController.text.isNotEmpty
                                  ? _descController.text
                                  : (program.description.isNotEmpty
                                      ? program.description
                                      : 'Apple Wallet preview'),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.interTight(),
                                    color: labelColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!_colorsValid())
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Enter valid HEX colors (e.g. #AABBCC)',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.interTight(),
                                  color: FlutterFlowTheme.of(context).error,
                                ),
                          ),
                        ),
                      const SizedBox(height: 12.0),
                      _fieldLabel('Broadcast message to Wallet passes'),
                      _input(_broadcastController, 'Example: New offer this week'),
                      FFButtonWidget(
                        onPressed:
                            _broadcasting ? null : () => _broadcast(program),
                        text: _broadcasting ? 'Sending...' : 'Send broadcast',
                        options: FFButtonOptions(
                          height: 44.0,
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                ),
                                color: Colors.white,
                              ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      FFButtonWidget(
                        onPressed: _refreshing ? null : () => _refreshPasses(program),
                        text: _refreshing
                            ? 'Refreshing passes...'
                            : 'Regenerate Apple Wallet passes',
                        options: FFButtonOptions(
                          height: 46.0,
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: Colors.white,
                              ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      FFButtonWidget(
                        onPressed: _saving ? null : () => _save(program),
                        text: _saving ? 'Saving...' : 'Save changes',
                        options: FFButtonOptions(
                          height: 48.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w700,
                              ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12.0, bottom: 6.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).titleSmall,
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: FlutterFlowTheme.of(context).alternate),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 14.0),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium,
      ),
    );
  }
}
