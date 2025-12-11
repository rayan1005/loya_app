import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MerchantScanWidget extends StatefulWidget {
  const MerchantScanWidget({
    super.key,
    this.programRef,
    this.programTitle,
  });

  final DocumentReference? programRef;
  final String? programTitle;

  static String routeName = 'MerchantScan';
  static String routePath = 'merchantScan';

  @override
  State<MerchantScanWidget> createState() => _MerchantScanWidgetState();
}

class _MerchantScanWidgetState extends State<MerchantScanWidget> {
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _processing = false;
  bool _torchOn = false;
  bool _showSuccess = false;
  String? _statusMessage;
  DocumentReference? _selectedProgram;
  ProgramsRecord? _programRecord;
  String _programTitle = 'Choose a program';

  @override
  void initState() {
    super.initState();
    _selectedProgram = widget.programRef;
    _programTitle = widget.programTitle ?? 'Choose a program';
    if (_selectedProgram != null) {
      _loadProgramDetails();
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _openProgramSheet());
    }
  }

  Future<void> _loadProgramDetails() async {
    if (_selectedProgram == null) return;
    try {
      final program =
          await ProgramsRecord.getDocumentOnce(_selectedProgram!);
      if (mounted) {
        setState(() {
          _programRecord = program;
          _programTitle =
              program.title.isNotEmpty ? program.title : _programTitle;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue ?? '';
    if (value.isEmpty) return;
    await _startProcessing(value);
  }

  Future<void> _startProcessing(String code) async {
    if (_selectedProgram == null) {
      await _openProgramSheet();
      if (_selectedProgram == null) {
        setState(() => _statusMessage = 'Select a program to scan.');
        return;
      }
    }
    setState(() {
      _processing = true;
      _statusMessage = null;
    });

    final success = await _processStamp(code);
    if (!mounted) return;

    if (success) {
      setState(() {
        _showSuccess = true;
        _statusMessage = 'Stamp added successfully!';
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    }

    setState(() {
      _processing = false;
    });
  }

  Future<bool> _processStamp(String scanResult) async {
    try {
      await _scannerController.stop();
    } catch (_) {}
    try {
      final parsed = Uri.tryParse(scanResult.trim());
      String? programId = _selectedProgram?.id ??
          parsed?.queryParameters['program'] ??
          parsed?.queryParameters['program_id'];
      String? uid = parsed?.queryParameters['uid'];
      String? serial = parsed?.queryParameters['serial'];

      programId ??=
          RegExp(r'program=([^&]+)').firstMatch(scanResult)?.group(1);
      uid ??= RegExp(r'uid=([^&]+)').firstMatch(scanResult)?.group(1);
      serial ??=
          RegExp(r'serial=([^&]+)').firstMatch(scanResult)?.group(1);

      if (programId == null || programId.isEmpty) {
        setState(() {
          _statusMessage = 'Program ID not found in QR.';
        });
        return false;
      }

      final response = await AddStampCall.call(programId: programId);
      if (!(response.succeeded)) {
        setState(() {
          _statusMessage =
              'Failed to add stamp. Check connection or permissions.';
        });
        return false;
      }

      final total = AddStampCall.totalStamps(response.jsonBody) ?? 0;
      final serialNumber =
          AddStampCall.serialNumber(response.jsonBody) ?? serial ?? '';
      DocumentReference? cardRef;
      DocumentReference? userRef;

      try {
        final programRef =
            FirebaseFirestore.instance.collection('programs').doc(programId);
        ProgramsRecord? program;
        try {
          program = await ProgramsRecord.getDocumentOnce(programRef);
        } catch (_) {}

        Query q = StampCardsRecord.collection.where(
          'program_id',
          isEqualTo: programRef,
        );
        if (uid != null && uid.isNotEmpty) {
          userRef = FirebaseFirestore.instance.collection('user').doc(uid);
          q = q.where('user_id', isEqualTo: userRef);
        }
        final snap = await q.limit(1).get();
        if (snap.docs.isNotEmpty) {
          cardRef = snap.docs.first.reference;
          final target =
              program != null && program.stampsRequired > 0 ? program.stampsRequired : total;
          await cardRef.update({
            ...createStampCardsRecordData(
              currentStamps: total,
              walletPassId: serialNumber.isNotEmpty ? serialNumber : null,
              status: total >= target ? 'completed' : 'active',
            ),
            ...mapToFirestore({
              'updated_at': FieldValue.serverTimestamp(),
            }),
          });

          try {
            final txRef = TransactionsRecord.collection.doc();
            await txRef.set({
              ...createTransactionsRecordData(
                transactionId: txRef.id,
                merchantId: currentUserDocument?.linkedMerchants,
                cardId: cardRef,
                userId: userRef,
                action: 'stamp',
                value: 1,
                scannedBy: currentUserEmail,
              ),
              ...mapToFirestore({
                'created_at': FieldValue.serverTimestamp(),
              }),
            });
          } catch (_) {}
        }
      } catch (_) {}
      return true;
    } finally {
      try {
        await _scannerController.start();
      } catch (_) {}
    }
  }

  Future<void> _openProgramSheet() async {
    final merchantRef = currentUserDocument?.linkedMerchants;
    if (merchantRef == null) {
      setState(() => _statusMessage = 'No merchant linked.');
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).padding.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose a program',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<ProgramsRecord>>(
                  stream: queryProgramsRecord(
                    queryBuilder: (q) => q
                        .where('merchant_id', isEqualTo: merchantRef)
                        .orderBy('created_at', descending: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final programs = snapshot.data!;
                    if (programs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No programs available.',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: programs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        final iconUrl = program.passLogo.isNotEmpty
                            ? program.passLogo
                            : (program.passIcon.isNotEmpty
                                ? program.passIcon
                                : (program.businessIcon.isNotEmpty
                                    ? program.businessIcon
                                    : ''));
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _selectedProgram = program.reference;
                              _programRecord = program;
                              _programTitle = program.title;
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: iconUrl.isNotEmpty
                                      ? Image.network(iconUrl,
                                          fit: BoxFit.cover)
                                      : Icon(Icons.star_rate_rounded,
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program.title,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stamps required: ${program.stampsRequired}',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (program.status
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(12),
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
                                                  ? FlutterFlowTheme.of(
                                                          context)
                                                      .primary
                                                  : FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                            ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
            Center(child: _scanFrame(context)),
            _topBar(context),
            _bottomBar(context),
            if (_statusMessage != null && !_showSuccess)
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: _statusChip(context, _statusMessage!),
              ),
            if (_showSuccess) _successOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => context.safePop(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: InkWell(
                onTap: _openProgramSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _programTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                    if (_programRecord != null)
                      Text(
                        '${_programRecord!.stampsRequired} stamps required',
                        style: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white70,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16 + bottom,
      child: Row(
        children: [
          _flashButton(context),
          const Spacer(),
          TextButton(
            onPressed: () => context.safePop(),
            child: Text(
              'Cancel',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _flashButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final next = !_torchOn;
        try {
          await _scannerController.toggleTorch();
        } catch (_) {}
        setState(() => _torchOn = next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _torchOn ? 'Flash on' : 'Flash off',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanFrame(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
              ),
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _successOverlay(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 10),
            Text(
              'Stamp added successfully!',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
