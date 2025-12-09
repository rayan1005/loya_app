import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/upload_data.dart';
import '/dashboard/dashboard_widget.dart';
import '/merchant/md/md_widget.dart';
import '/pages/home_page/home_page_widget.dart';
import '/merchant/components/merchant_nav_bar.dart';
import '/merchant/qr/merchant_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MerchantProfileWidget extends StatefulWidget {
  const MerchantProfileWidget({super.key});

  static String routeName = 'MerchantProfile';
  static String routePath = 'merchantProfile';

  @override
  State<MerchantProfileWidget> createState() => _MerchantProfileWidgetState();
}

class _MerchantProfileWidgetState extends State<MerchantProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _logoUrl;
  String _selectedRole = 'merchant';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      maxWidth: 512.0,
      maxHeight: 512.0,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        !selectedMedia.every(
            (m) => validateFileFormat(m.storagePath, context))) return;

    setState(() => _saving = true);
    try {
      final uploadedFiles = <FFUploadedFile>[];
      String? downloadUrl;
      for (final media in selectedMedia) {
        final file = FFUploadedFile(
          name: media.storagePath.split('/').last,
          bytes: media.bytes,
          height: media.dimensions?.height,
          width: media.dimensions?.width,
        );
        uploadedFiles.add(file);
        downloadUrl = await uploadData(media.storagePath, media.bytes);
      }
      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        setState(() => _logoUrl = downloadUrl);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save(MerchantsRecord merchant) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final data = createMerchantsRecordData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dec: _descController.text.trim(),
        logoUrl: _logoUrl ?? merchant.logoUrl,
        updatedAt: DateTime.now(),
      );
      await merchant.reference.update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchantRef = currentUserDocument?.linkedMerchants;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 0,
          title: Text(
            'Business settings',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  ),
                ),
          ),
          centerTitle: true,
        ),
        body: merchantRef == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'This account is not linked to a merchant profile yet.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ),
              )
            : StreamBuilder<MerchantsRecord>(
                stream: MerchantsRecord.getDocument(merchantRef),
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
                  final merchant = snapshot.data!;
                  if (!_initialized) {
                    _initialized = true;
                    _nameController.text = merchant.name;
                    _emailController.text = merchant.email;
                    _phoneController.text = merchant.phoneNumber;
                    _addressController.text = merchant.address;
                    _descController.text = merchant.dec;
    _logoUrl = merchant.logoUrl;
    _selectedRole =
        FFAppState().UserOrMetchent.isNotEmpty ? FFAppState().UserOrMetchent : 'merchant';
  }

                  return SafeArea(
                    top: true,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 44,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        backgroundImage: _logoUrl != null &&
                                                _logoUrl!.isNotEmpty
                                            ? NetworkImage(_logoUrl!)
                                                as ImageProvider
                                            : null,
                                        child: (_logoUrl == null ||
                                                _logoUrl!.isEmpty)
                                            ? const Icon(Icons.store, size: 36)
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      FFButtonWidget(
                                        onPressed: _saving ? null : _pickLogo,
                                        text:
                                            _saving ? 'Uploading...' : 'Change logo',
                                        options: FFButtonOptions(
                                          height: 38,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          textStyle: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontWeight,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                          elevation: 0,
                                          borderSide: BorderSide(
                                            color:
                                                FlutterFlowTheme.of(context)
                                                    .primary
                                                    .withOpacity(0.2),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: 'Business name',
                                ),
                                _buildTextField(
                                  context,
                                  controller: _emailController,
                                  label: 'Email',
                                  keyboard: TextInputType.emailAddress,
                                ),
                                _buildTextField(
                                  context,
                                  controller: _phoneController,
                                  label: 'Phone',
                                  keyboard: TextInputType.phone,
                                ),
                                _buildTextField(
                                  context,
                                  controller: _addressController,
                                  label: 'City / Address',
                                ),
                                _buildTextField(
                                  context,
                                  controller: _descController,
                                  label: 'About / description',
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Role',
                                  style: FlutterFlowTheme.of(context).titleMedium,
                                ),
                                const SizedBox(height: 8),
                                _roleTile(context,
                                    label: 'Business owner',
                                    value: 'merchant',
                                    subtitle:
                                        'Access dashboard, programs, scanner.',
                                    merchantRef: merchantRef),
                                _roleTile(context,
                                    label: 'User',
                                    value: 'user',
                                    subtitle:
                                        'Browse programs, manage my cards.',
                                    merchantRef: merchantRef),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: FFButtonWidget(
                            onPressed: _saving ? null : () => _save(merchant),
                            text: _saving ? 'Saving...' : 'Save changes',
                            options: FFButtonOptions(
                              height: 50,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                  ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: FFButtonWidget(
                            onPressed: () {
                              context.pushNamed(MerchantQrWidget.routeName);
                            },
                            text: 'Business QR',
                            options: FFButtonOptions(
                              height: 48,
                              color:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).primaryText,
                                  ),
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        MerchantNavBar(
                          currentTab: MerchantNavTab.settings,
                          merchantRef: merchantRef,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelLarge,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleTile(BuildContext context,
      {required String label,
      required String value,
      required String subtitle,
      required DocumentReference? merchantRef}) {
    final selected = _selectedRole == value;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: ListTile(
        leading: Radio<String>(
          value: value,
          groupValue: _selectedRole,
          onChanged: (val) => _onRoleSelected(val, merchantRef),
        ),
        title: Text(label),
        subtitle: Text(subtitle),
        onTap: () => _onRoleSelected(value, merchantRef),
      ),
    );
  }

  Future<void> _onRoleSelected(
      String? val, DocumentReference? merchantRef) async {
    if (val == null) return;
    setState(() => _selectedRole = val);
    FFAppState().update(() {
      FFAppState().UserOrMetchent = val;
    });
    // Navigate immediately to the appropriate dashboard
    if (!mounted) return;
    if (val == 'merchant' && merchantRef != null) {
      context.goNamed(
        MdWidget.routeName,
        queryParameters: {
          'marchentsId': serializeParam(
            merchantRef,
            ParamType.DocumentReference,
          ),
        }.withoutNulls,
      );
    } else {
      // user mode
      context.goNamed(DashboardWidget.routeName);
    }
  }
}
