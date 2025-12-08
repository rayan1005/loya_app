import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  Future<void> _startScan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _message = '';
    });

    try {
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF4A90E2', 'Cancel',
        true,
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
      String? programId =
          parsed?.queryParameters['program'] ?? parsed?.queryParameters['program_id'];
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
          final userRef =
              FirebaseFirestore.instance.collection('user').doc(uid);
          q = q.where('user_id', isEqualTo: userRef);
        }
        final snap = await q.limit(1).get();
        if (snap.docs.isNotEmpty) {
          final cardRef = snap.docs.first.reference;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 0.0,
        title: Text(
          'Scan stamp',
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
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 16.0,
                      color: Color(0x1F000000),
                      offset: Offset(0.0, 8.0),
                    )
                  ],
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scan the customer QR to add a stamp.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.0),
                    FFButtonWidget(
                      onPressed: _isScanning ? null : _startScan,
                      text: _isScanning ? 'Scanning...' : 'Start scan',
                      options: FFButtonOptions(
                        height: 50.0,
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
                    SizedBox(height: 16.0),
                    if (_message.isNotEmpty)
                      Text(
                        _message,
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        textAlign: TextAlign.center,
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




