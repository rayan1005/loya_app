import '/backend/backend.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/stamp_count_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late TextEditingController _passBgController;
  late TextEditingController _passFgController;
  late TextEditingController _passLabelController;
  late TextEditingController _stampIconController;
  late TextEditingController _updatesController;
  late TextEditingController _collectRuleController;
  late TextEditingController _instagramController;
  late TextEditingController _snapchatController;
  late TextEditingController _websiteController;
  late TextEditingController _supportEmailController;
  late TextEditingController _contactController;
  late TextEditingController _locationsController;
  late TextEditingController _broadcastController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  static const int _maxStamps = 12;
  int _stampsRequired = 1;
  bool _stampValueInitialized = false;
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
    _passBgController = TextEditingController(text: '#007AFF');
    _passFgController = TextEditingController(text: '#FFFFFF');
    _passLabelController = TextEditingController(text: '#FFFFFF');
    _stampIconController = TextEditingController();
    _updatesController = TextEditingController();
    _collectRuleController = TextEditingController();
    _instagramController = TextEditingController();
    _snapchatController = TextEditingController();
    _websiteController = TextEditingController();
    _supportEmailController = TextEditingController();
    _contactController = TextEditingController();
    _locationsController = TextEditingController();
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
    _passBgController.dispose();
    _passFgController.dispose();
    _passLabelController.dispose();
    _stampIconController.dispose();
    _updatesController.dispose();
    _collectRuleController.dispose();
    _instagramController.dispose();
    _snapchatController.dispose();
    _websiteController.dispose();
    _supportEmailController.dispose();
    _contactController.dispose();
    _locationsController.dispose();
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

  List<Map<String, String>> _parseLocations(String input) {
    final lines = input.split('\n');
    final result = <Map<String, String>>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.contains(':')) {
        final parts = line.split(':');
        final city = parts.first.trim();
        final branches = parts.sublist(1).join(':').split(',').map((b) => b.trim()).where((b) => b.isNotEmpty);
        for (final branch in branches) {
          result.add({'city': city, 'label': branch});
        }
      } else if (line.contains('-')) {
        final parts = line.split('-');
        if (parts.length >= 2) {
          result.add({'city': parts.first.trim(), 'label': parts.sublist(1).join('-').trim()});
        }
      } else {
        result.add({'city': 'General', 'label': line});
      }
    }
    return result;
  }

  Future<void> _save(ProgramsRecord program) async {
    if (_saving) return;
    if (!_colorsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid HEX colors (e.g. #007AFF).')),
      );
      return;
    }
    if (_rewardController.text.trim().isEmpty ||
        _termsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reward details and terms & conditions are required.')),
      );
      return;
    }
    _saving = true;
    setState(() {});

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final locations = _parseLocations(_locationsController.text);
    final latestUpdate = _updatesController.text.trim();
    await program.reference.update({
      ...createProgramsRecordData(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        rewardDetails: _rewardController.text.trim(),
        termsConditions: _termsController.text.trim(),
        status: _status,
        stampsRequired: _stampsRequired,
        expiryDate: _expiryDate,
        passBackgroundColor: _passBgController.text.trim(),
        passForegroundColor: _passFgController.text.trim(),
        passLabelColor: _passLabelController.text.trim(),
        stampIcon: _stampIconController.text.trim().isNotEmpty
            ? _stampIconController.text.trim()
            : null,
        latitude: lat,
        longitude: lng,
        passLatestUpdate: latestUpdate,
        passCollectRule: _collectRuleController.text.trim(),
        passInstagram: _instagramController.text.trim(),
        passSnapchat: _snapchatController.text.trim(),
        passWebsite: _websiteController.text.trim(),
        passSupportEmail: _supportEmailController.text.trim(),
        passContactName: _contactController.text.trim(),
        passLocations: locations.isNotEmpty ? locations : null,
      ),
      ...mapToFirestore({
        'updated_at': FieldValue.serverTimestamp(),
        if (latestUpdate.isNotEmpty)
          'pass_latest_update_at': FieldValue.serverTimestamp(),
      }),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program updated.')),
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
          const SnackBar(content: Text('Could not refresh passes')),
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
        const SnackBar(content: Text('Enter a broadcast message first')),
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
        await program.reference.update({
          ...createProgramsRecordData(passLatestUpdate: msg),
          ...mapToFirestore({
            'pass_latest_update_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          }),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast sent to $updated passes')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast failed')),
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
                _updatesController.text = _updatesController.text.isEmpty
                    ? program.passLatestUpdate
                    : _updatesController.text;
                _collectRuleController.text = _collectRuleController.text.isEmpty
                    ? program.passCollectRule
                    : _collectRuleController.text;
                _instagramController.text = _instagramController.text.isEmpty
                    ? program.passInstagram
                    : _instagramController.text;
                _snapchatController.text = _snapchatController.text.isEmpty
                    ? program.passSnapchat
                    : _snapchatController.text;
                _websiteController.text = _websiteController.text.isEmpty
                    ? program.passWebsite
                    : _websiteController.text;
                _supportEmailController.text = _supportEmailController.text.isEmpty
                    ? program.passSupportEmail
                    : _supportEmailController.text;
                _contactController.text = _contactController.text.isEmpty
                    ? (program.passContactName.isNotEmpty
                        ? program.passContactName
                        : program.title)
                    : _contactController.text;
                if (_locationsController.text.isEmpty &&
                    program.passLocations.isNotEmpty) {
                  final formatted = program.passLocations
                      .map((loc) {
                        if (loc is Map) {
                          final city = (loc['city'] ?? '').toString();
                          final label = (loc['label'] ?? loc['branch'] ?? '')
                              .toString();
                          if (city.isEmpty && label.isEmpty) return '';
                          return city.isNotEmpty ? '$city - $label' : label;
                        }
                        return loc.toString();
                      })
                      .where((line) => line.isNotEmpty)
                      .join('\n');
                  _locationsController.text = formatted;
                }
                if (!_stampValueInitialized) {
                  final initial = program.stampsRequired > 0
                      ? program.stampsRequired.clamp(1, _maxStamps)
                      : 1;
                  _stampsRequired = initial;
                  _stampValueInitialized = true;
                }
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
                _stampIconController.text = _stampIconController.text.isEmpty
                    ? program.stampIcon
                    : _stampIconController.text;
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
                      _stampPicker(context),
                      _fieldLabel('Reward details'),
                      _input(_rewardController, 'Reward details', maxLines: 3),
                      _fieldLabel('Terms & conditions'),
                      _input(_termsController, 'Terms', maxLines: 3),
                      _fieldLabel('Latest update (Wallet back)'),
                      _input(_updatesController,
                          'e.g., Offer valid until Thursday',
                          maxLines: 2),
                      _fieldLabel('How to collect stamps'),
                      _input(_collectRuleController,
                          'One stamp per purchase or SAR amount',
                          maxLines: 2),
                      _fieldLabel('Locations (one per line: City - Branch)'),
                      _input(
                          _locationsController,
                          'Riyadh - King Road\nJeddah - Corniche',
                          maxLines: 3),
                      _fieldLabel('Instagram'),
                      _input(_instagramController, '@brand or link'),
                      _fieldLabel('Snapchat'),
                      _input(_snapchatController, 'snapchat.com/add/brand'),
                      _fieldLabel('Website'),
                      _input(_websiteController, 'https://brand.com'),
                      _fieldLabel('Support email'),
                      _input(_supportEmailController, 'support@brand.com',
                          keyboardType: TextInputType.emailAddress),
                      _fieldLabel('Contact name'),
                      _input(_contactController, 'Merchant or support lead'),
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
                        title: const Text('Program active (on/off)'),
                        activeColor: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(height: 20.0),
                      _fieldLabel('Apple Wallet colors (HEX)'),
                      _input(_passBgController, '#007AFF'),
                      _input(_passFgController, '#FFFFFF'),
                      _input(_passLabelController, '#FFFFFF'),
                      _fieldLabel('Stamp icon URL'),
                      _input(_stampIconController, 'https://.../stamp.png'),
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

  Widget _stampPicker(BuildContext context) {
    return StampCountPicker(
      value: _stampsRequired,
      maxValue: _maxStamps,
      helperText:
          'Limited to 12 stamps to keep the Wallet strip fully visible.',
      onChanged: (value) => setState(() {
        _stampsRequired = value.clamp(1, _maxStamps);
      }),
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
