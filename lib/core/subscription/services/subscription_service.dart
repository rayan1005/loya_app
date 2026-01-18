import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../models/models.dart';

/// Service for managing subscriptions and in-app purchases
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  /// All product IDs
  static const Set<String> _productIds = {
    'loya_pro_monthly',
    'loya_pro_yearly',
    'loya_business_monthly',
    'loya_business_yearly',
  };

  /// Initialize the service
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('SubscriptionService: Web platform, skipping IAP init');
      return;
    }

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('SubscriptionService: IAP not available');
      return;
    }

    // Load products
    await _loadProducts();

    // Listen for purchases
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // For iOS, set delegate for subscription offer
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }

    debugPrint('SubscriptionService: Initialized, ${_products.length} products loaded');
  }

  /// Dispose the service
  void dispose() {
    _purchaseSubscription?.cancel();
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
  }

  /// Check if IAP is available
  bool get isAvailable => _isAvailable;

  /// Get available products
  List<ProductDetails> get products => _products;

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Load products from store
  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('Loaded ${_products.length} products');
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('Purchase update: ${purchase.productID} - ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Show loading indicator
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify and deliver the product
          await _verifyAndDeliverPurchase(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
          break;

        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled');
          break;
      }

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify and deliver purchase
  Future<bool> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    // In production, you should verify the receipt server-side
    // For now, we trust the purchase and save to Firestore

    try {
      final planType = PlanType.fromProductId(purchase.productID);
      final isYearly = purchase.productID.contains('yearly');

      // Calculate end date
      final endDate = DateTime.now().add(
        isYearly ? const Duration(days: 365) : const Duration(days: 30),
      );

      debugPrint('Delivering purchase: $planType, ends: $endDate');

      return true;
    } catch (e) {
      debugPrint('Error delivering purchase: $e');
      return false;
    }
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String productId, String businessId) async {
    if (!_isAvailable) {
      debugPrint('IAP not available');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      debugPrint('Product not found: $productId');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // For subscriptions, use buyNonConsumable
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  /// Get subscription for a business
  Future<Subscription?> getSubscription(String businessId) async {
    try {
      final query = await _firestore
          .collection('subscriptions')
          .where('businessId', isEqualTo: businessId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return Subscription.fromFirestore(query.docs.first);
    } catch (e) {
      debugPrint('Error getting subscription: $e');
      return null;
    }
  }

  /// Create or update subscription
  Future<Subscription> saveSubscription(Subscription subscription) async {
    final data = subscription.toFirestore();

    if (subscription.id.isEmpty) {
      // Create new
      final doc = await _firestore.collection('subscriptions').add(data);
      return subscription.copyWith(id: doc.id);
    } else {
      // Update existing
      await _firestore.collection('subscriptions').doc(subscription.id).update(data);
      return subscription;
    }
  }

  /// Increment stamp usage
  Future<void> incrementStampUsage(String businessId) async {
    final subscription = await getSubscription(businessId);
    if (subscription == null) return;

    await _firestore.collection('subscriptions').doc(subscription.id).update({
      'stampsUsedThisMonth': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment push notification usage
  Future<void> incrementPushNotificationUsage(String businessId) async {
    final subscription = await getSubscription(businessId);
    if (subscription == null) return;

    await _firestore.collection('subscriptions').doc(subscription.id).update({
      'pushNotificationsSentThisMonth': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reset monthly usage (call from a scheduled function)
  Future<void> resetMonthlyUsage(String subscriptionId) async {
    await _firestore.collection('subscriptions').doc(subscriptionId).update({
      'stampsUsedThisMonth': 0,
      'pushNotificationsSentThisMonth': 0,
      'usageResetDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Start a trial for a business
  Future<Subscription> startTrial(String businessId, PlanType plan) async {
    final trial = Subscription.trial(businessId, plan);
    return saveSubscription(trial);
  }

  /// Check if business can start a trial (hasn't had one before)
  Future<bool> canStartTrial(String businessId) async {
    final query = await _firestore
        .collection('subscriptions')
        .where('businessId', isEqualTo: businessId)
        .where('isTrial', isEqualTo: true)
        .limit(1)
        .get();

    return query.docs.isEmpty;
  }
}

/// Payment queue delegate for iOS
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
