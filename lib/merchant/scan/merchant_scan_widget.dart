import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/merchant/components/merchant_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class MerchantScanWidget extends StatefulWidget {
  const MerchantScanWidget({super.key});

  static String routeName = 'MerchantScan';
  static String routePath = 'merchantScan';

  @override
  State<MerchantScanWidget> createState() => _MerchantScanWidgetState();
}

class _MerchantScanWidgetState extends State<MerchantScanWidget> {
  bool _isScanning = false;
  String _message = '';
  DocumentReference? _selectedProgram;
  String _selectedProgramTitle = 'No program selected';
  DocumentReference? _lastCardRef;
  int _lastTotal = 0;

  Future<void> _pickProgram() async {
    final merchantRef = currentUserDocument?.linkedMerchants;
    if (merchantRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No merchant linked.')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: StreamBuilder<List<ProgramsRecord>>(
            stream: queryProgramsRecord(
              queryBuilder: (q) => q
                  .where('merchant_id', isEqualTo: merchantRef)
                  .where('status', isEqualTo: true),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final programs = snapshot.data!;
              if (programs.isEmpty) {
                return const Center(child: Text('No active programs.'));
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: programs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = programs[index];
                  return ListTile(
                    leading: p.stampIcon.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(p.stampIcon))
                        : const CircleAvatar(child: Icon(Icons.star)),
                    title: Text(p.title),
                    subtitle: Text('${p.stampsRequired} stamps required'),
                    onTap: () {
                      setState(() {
                        _selectedProgram = p.reference;
                        _selectedProgramTitle = p.title;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _startScan() async {
    if (_selectedProgram == null) {
      await _pickProgram();
      if (_selectedProgram == null) {
        return;
      }
    }
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _message = '';
    });

    try {
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF4A90E2', 'Cancel',
        false,
        ScanMode.QR,
      );

      if (!mounted) return;
      if (scanResult == '-1') {
        setState(() {
          _message = 'Scan cancelled.';
          _isScanning = false;
        });
        return;
      }

      final parsed = Uri.tryParse(scanResult.trim());
      String? programId = _selectedProgram?.id ??
          parsed?.queryParameters['program'] ??
          parsed?.queryParameters['program_id'];
      String? uid = parsed?.queryParameters['uid'];
      String? serial = parsed?.queryParameters['serial'];

      // Fallback regex parsing if URI failed
      programId ??= RegExp(r'program=([^&]+)')
          .firstMatch(scanResult)
          ?.group(1);
      uid ??= RegExp(r'uid=([^&]+)').firstMatch(scanResult)?.group(1);
      serial ??= RegExp(r'serial=([^&]+)').firstMatch(scanResult)?.group(1);

      if (programId == null || programId.isEmpty) {
        setState(() {
          _message = 'Program ID not found in QR.';
          _isScanning = false;
        });
        return;
      }

      final response = await AddStampCall.call(programId: programId);
      if (!(response.succeeded)) {
        setState(() {
          _message = 'Failed to add stamp. Check connection or permissions.';
          _isScanning = false;
        });
        return;
      }

      final total = AddStampCall.totalStamps(response.jsonBody) ?? 0;
      final serialNumber =
          AddStampCall.serialNumber(response.jsonBody) ?? serial ?? '';
      DocumentReference? cardRef;
      DocumentReference? userRef;

      // Try updating the user card if found
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
          _lastCardRef = cardRef;
          _lastTotal = total;
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

          // Log transaction for analytics/history
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
                createdAt: DateTime.now(),
              ),
            });
          } catch (_) {
            // ignore logging errors
          }
        }
      } catch (_) {
        // Best-effort update; ignore errors.
      }

      setState(() {
        _message = 'Stamp added. Total: $total';
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Something went wrong while scanning.';
        _isScanning = false;
      });
    }
  }

  Future<void> _undoLastStamp() async {
    if (_lastCardRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recent stamp to undo.')),
      );
      return;
    }
    try {
      await _lastCardRef!.update({
        'current_stamps': FieldValue.increment(-1),
        'updated_at': FieldValue.serverTimestamp(),
      });
      setState(() {
        _message = 'Last stamp undone.';
        _lastCardRef = null;
        _lastTotal = 0;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not undo last stamp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 0,
        title: Text(
          'Scan stamp',
          style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.interTight(
                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: MerchantNavBar(
        currentTab: MerchantNavTab.dashboard,
        merchantRef: currentUserDocument?.linkedMerchants,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Program',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w700),
                                  )),
                          const SizedBox(height: 4),
                          Text(
                            _selectedProgramTitle,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: _pickProgram,
                      text: 'Change',
                      options: FFButtonOptions(
                        height: 40,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_lastCardRef != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent stamp saved',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total now: $_lastTotal',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ],
                      ),
                      FFButtonWidget(
                        onPressed: _undoLastStamp,
                        text: 'Undo',
                        options: FFButtonOptions(
                          height: 38,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).primaryText,
                                  ),
                          borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      color: Color(0x14000000),
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).accent1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.qr_code_scanner,
                              color: FlutterFlowTheme.of(context).primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add stamp via QR',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scan the customer QR to add a stamp.',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FFButtonWidget(
                      onPressed: _isScanning ? null : _startScan,
                      text: _isScanning ? 'Scanning...' : 'Start scan',
                      options: FFButtonOptions(
                        height: 50,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_message.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .accent1
                              .withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _message,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
