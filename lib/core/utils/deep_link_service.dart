import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/shared/widgets/quick_action_sheet.dart';
import '../data/models/models.dart';

/// Deep Link Action Types
enum DeepLinkAction {
  stamp,
  redeem,
  view,
}

/// Parsed deep link data
class DeepLinkData {
  final DeepLinkAction action;
  final String? customerId;
  final String? programId;
  final String? phone;
  final String? serialNumber;

  const DeepLinkData({
    this.action = DeepLinkAction.stamp,
    this.customerId,
    this.programId,
    this.phone,
    this.serialNumber,
  });

  @override
  String toString() => 'DeepLinkData(action: $action, customerId: $customerId, programId: $programId)';
}

/// Provider to track pending deep link data
final pendingDeepLinkProvider = StateProvider<DeepLinkData?>((ref) => null);

/// Deep Link Service - handles incoming URLs when app opens via QR scan
class DeepLinkService {
  final Ref _ref;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this._ref) {
    _appLinks = AppLinks();
    _init();
  }

  void _init() {
    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle initial link (app opened via link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Parse incoming URI and extract data
  void _handleUri(Uri uri) {
    debugPrint('Deep link received: $uri');

    try {
      final data = parseUri(uri);
      if (data != null) {
        _ref.read(pendingDeepLinkProvider.notifier).state = data;
        
        // Also fetch and set customer data for the quick action sheet
        _fetchAndSetCustomerData(data);
      }
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
    }
  }

  /// Parse URI into DeepLinkData
  /// Supported formats:
  /// - https://loya.live/s/CUSTOMER_ID?p=PROGRAM_ID
  /// - https://loya.live/add-stamp?uid=CUSTOMER_ID&program=PROGRAM_ID
  /// - https://loya.live/redeem?uid=CUSTOMER_ID&program=PROGRAM_ID
  /// - loya://stamp?uid=CUSTOMER_ID&program=PROGRAM_ID
  static DeepLinkData? parseUri(Uri uri) {
    // Determine action from path
    DeepLinkAction action = DeepLinkAction.stamp;
    String? customerId;
    String? programId;
    String? phone;
    String? serialNumber;

    final path = uri.path.toLowerCase();
    
    // Determine action
    if (path.contains('redeem')) {
      action = DeepLinkAction.redeem;
    } else if (path.contains('view')) {
      action = DeepLinkAction.view;
    } else {
      action = DeepLinkAction.stamp; // Default
    }

    // Parse short format: /s/CUSTOMER_ID
    if (path.startsWith('/s/') && path.length > 3) {
      customerId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    }

    // Get query parameters
    customerId ??= uri.queryParameters['uid'] ?? 
                   uri.queryParameters['customerId'] ?? 
                   uri.queryParameters['cid'];
    
    programId = uri.queryParameters['program'] ?? 
                uri.queryParameters['programId'] ?? 
                uri.queryParameters['pid'] ??
                uri.queryParameters['p'];
    
    phone = uri.queryParameters['phone'];
    serialNumber = uri.queryParameters['serial'] ?? uri.queryParameters['sn'];

    // Must have at least customer ID or phone
    if (customerId == null && phone == null) {
      return null;
    }

    return DeepLinkData(
      action: action,
      customerId: customerId,
      programId: programId,
      phone: phone,
      serialNumber: serialNumber,
    );
  }

  /// Fetch customer data and populate the quick action sheet
  Future<void> _fetchAndSetCustomerData(DeepLinkData linkData) async {
    try {
      if (linkData.customerId == null) return;

      // Fetch customer document
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(linkData.customerId)
          .get();

      if (!customerDoc.exists) {
        debugPrint('Customer not found: ${linkData.customerId}');
        return;
      }

      final customerData = customerDoc.data()!;
      final customerName = customerData['name'] as String? ?? 
                          customerData['displayName'] as String?;

      // Fetch program info if available
      String? programName;
      int? currentStamps;
      int? stampsRequired;
      int? availableRewards;

      if (linkData.programId != null) {
        // Get program info
        final programDoc = await FirebaseFirestore.instance
            .collection('programs')
            .doc(linkData.programId)
            .get();

        if (programDoc.exists) {
          final program = LoyaltyProgram.fromFirestore(programDoc);
          programName = program.name;
          stampsRequired = program.stampsRequired;
        }

        // Get customer progress in this program
        final progressQuery = await FirebaseFirestore.instance
            .collection('customer_progress')
            .where('customerId', isEqualTo: linkData.customerId)
            .where('programId', isEqualTo: linkData.programId)
            .limit(1)
            .get();

        if (progressQuery.docs.isNotEmpty) {
          final progress = CustomerProgress.fromFirestore(progressQuery.docs.first);
          currentStamps = progress.stamps;
          // Calculate available rewards based on stamps
          if (stampsRequired != null && stampsRequired > 0) {
            availableRewards = currentStamps! ~/ stampsRequired;
          }
        }
      }

      // Set the scanned customer data for the quick action sheet
      _ref.read(scannedCustomerProvider.notifier).state = ScannedCustomerData(
        customerId: linkData.customerId!,
        programId: linkData.programId,
        customerName: customerName,
        programName: programName,
        currentStamps: currentStamps,
        stampsRequired: stampsRequired,
        availableRewards: availableRewards,
      );

      // Show the quick action sheet
      _ref.read(quickActionSheetVisibleProvider.notifier).state = true;

    } catch (e) {
      debugPrint('Error fetching customer data: $e');
    }
  }

  /// Generate a deep link URL for a customer pass
  static String generatePassUrl({
    required String customerId,
    required String programId,
    String? serialNumber,
  }) {
    final params = <String, String>{
      'uid': customerId,
      'p': programId,
    };
    if (serialNumber != null) {
      params['sn'] = serialNumber;
    }

    final uri = Uri.https('loya.live', '/s/$customerId', params);
    return uri.toString();
  }

  /// Generate a short scannable URL
  static String generateShortUrl(String customerId, String programId) {
    return 'https://loya.live/s/$customerId?p=$programId';
  }
}

/// Provider for the deep link service
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Initialize deep link handling in the app
void initializeDeepLinks(WidgetRef ref) {
  // Just accessing the provider initializes it
  ref.read(deepLinkServiceProvider);
}
