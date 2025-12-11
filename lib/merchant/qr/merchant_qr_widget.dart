import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/merchant/components/merchant_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MerchantQrWidget extends StatelessWidget {
  const MerchantQrWidget({super.key});

  static String routeName = 'MerchantQR';
  static String routePath = 'merchantQR';

  @override
  Widget build(BuildContext context) {
    final merchantRef = currentUserDocument?.linkedMerchants;
    final qrData = merchantRef?.id ?? 'merchant-not-linked';
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: const Text('Business QR'),
        centerTitle: true,
      ),
      bottomNavigationBar: MerchantNavBar(
        currentTab: MerchantNavTab.dashboard,
        merchantRef: merchantRef,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Share this QR with your staff to scan and add stamps quickly.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 12, color: Color(0x14000000), offset: Offset(0, 6))
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                qrData,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
