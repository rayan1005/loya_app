import 'package:cloud_firestore/cloud_firestore.dart';

/// Business entity model
class Business {
  final String id;
  final String ownerId;
  final String nameEn;
  final String nameAr;
  final String? logoUrl;
  final String phone;
  final String? email;
  final String? address;
  final String plan;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    required this.id,
    required this.ownerId,
    required this.nameEn,
    required this.nameAr,
    this.logoUrl,
    required this.phone,
    this.email,
    this.address,
    required this.plan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      nameEn: data['nameEn'] ?? '',
      nameAr: data['nameAr'] ?? '',
      logoUrl: data['logoUrl'],
      phone: data['phone'] ?? '',
      email: data['email'],
      address: data['address'],
      plan: data['plan'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'logoUrl': logoUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'plan': plan,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Business copyWith({
    String? id,
    String? ownerId,
    String? nameEn,
    String? nameAr,
    String? logoUrl,
    String? phone,
    String? email,
    String? address,
    String? plan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Plan limits
  int get maxPrograms {
    switch (plan) {
      case 'business':
        return 999; // Unlimited
      case 'pro':
        return 2;
      default:
        return 1;
    }
  }

  int get maxPasses {
    switch (plan) {
      case 'business':
      case 'pro':
        return 999999; // Unlimited
      default:
        return 2;
    }
  }
}

/// Custom field definition for loyalty programs
/// Labels are per-program, values are stored per-customer in CustomerProgress
class CustomFieldDefinition {
  final String key; // Unique key for the field (auto-generated)
  final String label; // Display label set by business
  final bool showOnFront; // Show on pass front (max 4) vs back (up to 10)
  final bool enabled; // Is the field active?

  const CustomFieldDefinition({
    required this.key,
    required this.label,
    this.showOnFront = true,
    this.enabled = true,
  });

  factory CustomFieldDefinition.fromMap(Map<String, dynamic> map) {
    return CustomFieldDefinition(
      key: map['key'] ?? '',
      label: map['label'] ?? '',
      showOnFront: map['showOnFront'] ?? true,
      enabled: map['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'showOnFront': showOnFront,
      'enabled': enabled,
    };
  }

  CustomFieldDefinition copyWith({
    String? key,
    String? label,
    bool? showOnFront,
    bool? enabled,
  }) {
    return CustomFieldDefinition(
      key: key ?? this.key,
      label: label ?? this.label,
      showOnFront: showOnFront ?? this.showOnFront,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Configuration for which fields to show on Apple Wallet pass (max 4 on front)
class PassFieldConfig {
  final bool showStampsRemaining; // "4 stamps until reward"
  final String?
      stampsLabel; // Custom label for stamps (default: "Stamps Remaining")
  final bool showCustomerName; // Customer name if available
  final String?
      customerNameLabel; // Custom label for customer name (default: "Name")
  final bool showPhoneNumber; // Customer phone
  final bool showMessage; // Custom promotional message
  final String? customMessage; // The message text
  final String?
      messageLabel; // Custom label for message (can be empty for no label)
  final bool showRewards; // Show rewards count in header
  final String? rewardsLabel; // Custom label for rewards (default: "Rewards")
  final bool showBroadcastMessage; // Show broadcast messages from dashboard
  final String?
      broadcastLabel; // Custom label for broadcast (default: "Message")

  // 3 Custom fields per customer (values stored in customer_progress)
  final bool showCustomField1;
  final String? customField1Label;
  final bool showCustomField2;
  final String? customField2Label;
  final bool showCustomField3;
  final String? customField3Label;

  // Priority order for fields (drag-and-drop reorderable)
  final List<String> fieldPriorityOrder;

  const PassFieldConfig({
    this.showStampsRemaining = true,
    this.stampsLabel,
    this.showCustomerName = false,
    this.customerNameLabel,
    this.showPhoneNumber = false,
    this.showMessage = false,
    this.customMessage,
    this.messageLabel,
    this.showRewards = true,
    this.rewardsLabel,
    this.showBroadcastMessage = true,
    this.broadcastLabel,
    this.showCustomField1 = false,
    this.customField1Label,
    this.showCustomField2 = false,
    this.customField2Label,
    this.showCustomField3 = false,
    this.customField3Label,
    this.fieldPriorityOrder = const [
      'stamps',
      'customerName',
      'customField1',
      'customField2',
      'customField3',
      'broadcast'
    ],
  });

  factory PassFieldConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PassFieldConfig();

    // Parse priority order with fallback to default
    List<String> priorityOrder = const [
      'stamps',
      'customerName',
      'customField1',
      'customField2',
      'customField3',
      'broadcast'
    ];
    if (map['fieldPriorityOrder'] != null) {
      priorityOrder = List<String>.from(map['fieldPriorityOrder']);
      // Remove deprecated 'message' field
      priorityOrder.remove('message');
      // Ensure 'broadcast' is included for backward compatibility
      if (!priorityOrder.contains('broadcast')) {
        priorityOrder.add('broadcast');
      }
    }

    return PassFieldConfig(
      showStampsRemaining: map['showStampsRemaining'] ?? true,
      stampsLabel: map['stampsLabel'],
      showCustomerName: map['showCustomerName'] ?? false,
      customerNameLabel: map['customerNameLabel'],
      showPhoneNumber: map['showPhoneNumber'] ?? false,
      showMessage: map['showMessage'] ?? false,
      customMessage: map['customMessage'],
      messageLabel: map['messageLabel'],
      showRewards: map['showRewards'] ?? true,
      rewardsLabel: map['rewardsLabel'],
      showBroadcastMessage: map['showBroadcastMessage'] ?? true,
      broadcastLabel: map['broadcastLabel'],
      showCustomField1: map['showCustomField1'] ?? false,
      customField1Label: map['customField1Label'],
      showCustomField2: map['showCustomField2'] ?? false,
      customField2Label: map['customField2Label'],
      showCustomField3: map['showCustomField3'] ?? false,
      customField3Label: map['customField3Label'],
      fieldPriorityOrder: priorityOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showStampsRemaining': showStampsRemaining,
      'stampsLabel': stampsLabel,
      'showCustomerName': showCustomerName,
      'customerNameLabel': customerNameLabel,
      'showPhoneNumber': showPhoneNumber,
      'showMessage': showMessage,
      'customMessage': customMessage,
      'messageLabel': messageLabel,
      'showRewards': showRewards,
      'rewardsLabel': rewardsLabel,
      'showBroadcastMessage': showBroadcastMessage,
      'broadcastLabel': broadcastLabel,
      'showCustomField1': showCustomField1,
      'customField1Label': customField1Label,
      'showCustomField2': showCustomField2,
      'customField2Label': customField2Label,
      'showCustomField3': showCustomField3,
      'customField3Label': customField3Label,
      'fieldPriorityOrder': fieldPriorityOrder,
    };
  }

  /// Count of enabled fields (max 4 allowed on front)
  int get enabledCount {
    int count = 0;
    if (showStampsRemaining) count++;
    if (showCustomerName) count++;
    if (showPhoneNumber) count++;
    if (showMessage && customMessage?.isNotEmpty == true) count++;
    if (showCustomField1) count++;
    if (showCustomField2) count++;
    if (showCustomField3) count++;
    return count;
  }

  PassFieldConfig copyWith({
    bool? showStampsRemaining,
    String? stampsLabel,
    bool? showCustomerName,
    String? customerNameLabel,
    bool? showPhoneNumber,
    bool? showMessage,
    String? customMessage,
    String? messageLabel,
    bool? showRewards,
    String? rewardsLabel,
    bool? showBroadcastMessage,
    String? broadcastLabel,
    bool? showCustomField1,
    String? customField1Label,
    bool? showCustomField2,
    String? customField2Label,
    bool? showCustomField3,
    String? customField3Label,
    List<String>? fieldPriorityOrder,
  }) {
    return PassFieldConfig(
      showStampsRemaining: showStampsRemaining ?? this.showStampsRemaining,
      stampsLabel: stampsLabel ?? this.stampsLabel,
      showCustomerName: showCustomerName ?? this.showCustomerName,
      customerNameLabel: customerNameLabel ?? this.customerNameLabel,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showMessage: showMessage ?? this.showMessage,
      customMessage: customMessage ?? this.customMessage,
      messageLabel: messageLabel ?? this.messageLabel,
      showRewards: showRewards ?? this.showRewards,
      rewardsLabel: rewardsLabel ?? this.rewardsLabel,
      showBroadcastMessage: showBroadcastMessage ?? this.showBroadcastMessage,
      broadcastLabel: broadcastLabel ?? this.broadcastLabel,
      showCustomField1: showCustomField1 ?? this.showCustomField1,
      customField1Label: customField1Label ?? this.customField1Label,
      showCustomField2: showCustomField2 ?? this.showCustomField2,
      customField2Label: customField2Label ?? this.customField2Label,
      showCustomField3: showCustomField3 ?? this.showCustomField3,
      customField3Label: customField3Label ?? this.customField3Label,
      fieldPriorityOrder: fieldPriorityOrder ?? this.fieldPriorityOrder,
    );
  }
}

/// Loyalty program model with full customization options
class LoyaltyProgram {
  final String id;
  final String businessId;
  final String name;
  final String? description;
  final String rewardDescription;
  final int stampsRequired;
  final bool isActive;
  final int totalCustomers;
  final int totalStamps;
  final int totalRewards;
  final DateTime createdAt;
  final DateTime updatedAt;

  // === PASS DESIGN CUSTOMIZATION ===
  // Colors
  final String backgroundColor; // Pass background color
  final String foregroundColor; // Text color
  final String labelColor; // Label text color
  final String accentColor; // Accent/highlight color

  // Images (URLs from Firebase Storage)
  final String? logoUrl; // Logo image (160x50 recommended)
  final String? iconUrl; // Icon image (29x29, 58x58, 87x87)
  final String? stripUrl; // Strip/banner image (375x123)
  final String? thumbnailUrl; // Thumbnail (90x90)

  // Stamp Icons
  final String? stampActiveUrl; // Active stamp icon
  final String? stampInactiveUrl; // Inactive stamp icon
  final String stampStyle; // 'circle', 'star', 'heart', 'check', 'custom'

  // === CONTENT CUSTOMIZATION ===
  final String? termsConditions; // Terms & conditions
  final String? websiteUrl; // Business website
  final String? phoneNumber; // Contact phone
  final String? email; // Contact email
  final String? address; // Business address

  // === LOCATION ===
  final double? latitude;
  final double? longitude;
  final String? locationName;

  // === EXPIRY ===
  final DateTime? expiryDate;

  // === NOTIFICATIONS ===
  final String? broadcastMessage; // Current broadcast message
  final DateTime? lastBroadcastAt;

  // === CUSTOM FIELDS (per-program labels, values stored per-customer) ===
  // Each field has: key, label, showOnFront, enabled
  final List<CustomFieldDefinition> customFields;

  // === PASS FIELD CONFIG (which fields to show on pass front, max 4) ===
  final PassFieldConfig passFieldConfig;

  // === LOCATION ENGAGEMENT ===
  final bool locationEnabled; // Enable geofence notifications
  final int locationRadius; // Radius in meters (50, 100, 200, 500)

  // === STAMP DISPLAY OPTIONS ===
  final bool
      useStampOpacity; // true = same icon 30% opacity, false = different icon

  // Legacy field for backwards compatibility
  String get color => backgroundColor;
  String get icon => stampStyle;

  const LoyaltyProgram({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    required this.rewardDescription,
    required this.stampsRequired,
    required this.isActive,
    this.totalCustomers = 0,
    this.totalStamps = 0,
    this.totalRewards = 0,
    required this.createdAt,
    required this.updatedAt,
    // Design
    this.backgroundColor = '#007AFF',
    this.foregroundColor = '#FFFFFF',
    this.labelColor = '#FFFFFF',
    this.accentColor = '#007AFF',
    this.logoUrl,
    this.iconUrl,
    this.stripUrl,
    this.thumbnailUrl,
    this.stampActiveUrl,
    this.stampInactiveUrl,
    this.stampStyle = 'circle',
    // Content
    this.termsConditions,
    this.websiteUrl,
    this.phoneNumber,
    this.email,
    this.address,
    // Location
    this.latitude,
    this.longitude,
    this.locationName,
    // Expiry
    this.expiryDate,
    // Notifications
    this.broadcastMessage,
    this.lastBroadcastAt,
    // Custom fields
    this.customFields = const [],
    // Location engagement
    this.locationEnabled = false,
    this.locationRadius = 100,
    // Stamp display
    this.useStampOpacity = true,
    // Pass field config
    this.passFieldConfig = const PassFieldConfig(),
  });

  factory LoyaltyProgram.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyProgram(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      rewardDescription:
          data['rewardDescription'] ?? data['reward_details'] ?? '',
      stampsRequired: data['stampsRequired'] ?? data['stamps_required'] ?? 10,
      isActive: data['isActive'] ?? true,
      totalCustomers: data['totalCustomers'] ?? 0,
      totalStamps: data['totalStamps'] ?? 0,
      totalRewards: data['totalRewards'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Design - support both camelCase and snake_case
      backgroundColor: data['backgroundColor'] ??
          data['background_color'] ??
          data['color'] ??
          '#007AFF',
      foregroundColor:
          data['foregroundColor'] ?? data['foreground_color'] ?? '#FFFFFF',
      labelColor: data['labelColor'] ?? data['label_color'] ?? '#FFFFFF',
      accentColor: data['accentColor'] ??
          data['accent_color'] ??
          data['color'] ??
          '#007AFF',
      logoUrl: data['logoUrl'] ?? data['pass_logo'],
      iconUrl: data['iconUrl'] ?? data['pass_icon'] ?? data['business_icon'],
      stripUrl: data['stripUrl'] ?? data['strip_image'],
      thumbnailUrl: data['thumbnailUrl'],
      stampActiveUrl: data['stampActiveUrl'] ?? data['stamp_active_icon'],
      stampInactiveUrl: data['stampInactiveUrl'] ?? data['stamp_inactive_icon'],
      stampStyle: data['stampStyle'] ?? data['icon'] ?? 'circle',
      // Content
      termsConditions: data['termsConditions'] ?? data['terms_conditions'],
      websiteUrl: data['websiteUrl'] ?? data['website_url'],
      phoneNumber: data['phoneNumber'] ?? data['phone_number'],
      email: data['email'],
      address: data['address'],
      // Location
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] ?? data['location_name'],
      // Expiry
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ??
          (data['expiry_date'] as Timestamp?)?.toDate(),
      // Notifications
      broadcastMessage: data['broadcastMessage'] ?? data['broadcast_message'],
      lastBroadcastAt: (data['lastBroadcastAt'] as Timestamp?)?.toDate(),
      // Custom fields
      customFields: (data['customFields'] as List<dynamic>?)
              ?.map((e) =>
                  CustomFieldDefinition.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      // Location engagement
      locationEnabled: data['locationEnabled'] ?? false,
      locationRadius: data['locationRadius'] ?? 100,
      // Stamp display
      useStampOpacity: data['useStampOpacity'] ?? true,
      // Pass field config
      passFieldConfig: data['passFieldConfig'] != null
          ? PassFieldConfig.fromMap(
              data['passFieldConfig'] as Map<String, dynamic>)
          : const PassFieldConfig(),
    );
  }

  /// Convert to JSON-safe map for API calls (no Timestamp objects)
  /// Always includes image fields (even when null) so they can be cleared
  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'name': name,
      'description': description,
      'rewardDescription': rewardDescription,
      'stampsRequired': stampsRequired,
      'isActive': isActive,
      'totalCustomers': totalCustomers,
      'totalStamps': totalStamps,
      'totalRewards': totalRewards,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Design - always include these so they can be cleared
      'backgroundColor': backgroundColor,
      'foregroundColor': foregroundColor,
      'labelColor': labelColor,
      'accentColor': accentColor,
      'logoUrl': logoUrl, // Always include, even if null
      'iconUrl': iconUrl, // Always include, even if null
      'stripUrl': stripUrl, // Always include, even if null
      'thumbnailUrl': thumbnailUrl, // Always include, even if null
      'stampActiveUrl': stampActiveUrl, // Always include, even if null
      'stampInactiveUrl': stampInactiveUrl, // Always include, even if null
      'stampStyle': stampStyle,
      // Content
      'termsConditions': termsConditions,
      'websiteUrl': websiteUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      // Location
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      // Expiry
      'expiryDate': expiryDate?.toIso8601String(),
      // Notifications
      'broadcastMessage': broadcastMessage,
      'lastBroadcastAt': lastBroadcastAt?.toIso8601String(),
      // Custom fields
      'customFields': customFields.map((e) => e.toMap()).toList(),
      // Location engagement
      'locationEnabled': locationEnabled,
      'locationRadius': locationRadius,
      // Stamp display
      'useStampOpacity': useStampOpacity,
      // Pass field config
      'passFieldConfig': passFieldConfig.toMap(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'name': name,
      'description': description,
      'rewardDescription': rewardDescription,
      'stampsRequired': stampsRequired,
      'isActive': isActive,
      'totalCustomers': totalCustomers,
      'totalStamps': totalStamps,
      'totalRewards': totalRewards,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Design
      'backgroundColor': backgroundColor,
      'foregroundColor': foregroundColor,
      'labelColor': labelColor,
      'accentColor': accentColor,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (stripUrl != null) 'stripUrl': stripUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (stampActiveUrl != null) 'stampActiveUrl': stampActiveUrl,
      if (stampInactiveUrl != null) 'stampInactiveUrl': stampInactiveUrl,
      'stampStyle': stampStyle,
      // Content
      if (termsConditions != null) 'termsConditions': termsConditions,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      // Location
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'locationName': locationName,
      // Expiry
      if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate!),
      // Notifications
      if (broadcastMessage != null) 'broadcastMessage': broadcastMessage,
      if (lastBroadcastAt != null)
        'lastBroadcastAt': Timestamp.fromDate(lastBroadcastAt!),
      // Custom fields
      'customFields': customFields.map((e) => e.toMap()).toList(),
      // Location engagement
      'locationEnabled': locationEnabled,
      'locationRadius': locationRadius,
      // Stamp display
      'useStampOpacity': useStampOpacity,
      // Pass field config
      'passFieldConfig': passFieldConfig.toMap(),
    };
  }

  LoyaltyProgram copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    String? rewardDescription,
    int? stampsRequired,
    bool? isActive,
    int? totalCustomers,
    int? totalStamps,
    int? totalRewards,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? backgroundColor,
    String? foregroundColor,
    String? labelColor,
    String? accentColor,
    String? logoUrl,
    String? iconUrl,
    String? stripUrl,
    String? thumbnailUrl,
    String? stampActiveUrl,
    String? stampInactiveUrl,
    String? stampStyle,
    String? termsConditions,
    String? websiteUrl,
    String? phoneNumber,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? expiryDate,
    String? broadcastMessage,
    DateTime? lastBroadcastAt,
    List<CustomFieldDefinition>? customFields,
    bool? locationEnabled,
    int? locationRadius,
    bool? useStampOpacity,
    PassFieldConfig? passFieldConfig,
  }) {
    return LoyaltyProgram(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      stampsRequired: stampsRequired ?? this.stampsRequired,
      isActive: isActive ?? this.isActive,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalStamps: totalStamps ?? this.totalStamps,
      totalRewards: totalRewards ?? this.totalRewards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      labelColor: labelColor ?? this.labelColor,
      accentColor: accentColor ?? this.accentColor,
      logoUrl: logoUrl ?? this.logoUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      stripUrl: stripUrl ?? this.stripUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      stampActiveUrl: stampActiveUrl ?? this.stampActiveUrl,
      stampInactiveUrl: stampInactiveUrl ?? this.stampInactiveUrl,
      stampStyle: stampStyle ?? this.stampStyle,
      termsConditions: termsConditions ?? this.termsConditions,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      expiryDate: expiryDate ?? this.expiryDate,
      broadcastMessage: broadcastMessage ?? this.broadcastMessage,
      lastBroadcastAt: lastBroadcastAt ?? this.lastBroadcastAt,
      customFields: customFields ?? this.customFields,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      locationRadius: locationRadius ?? this.locationRadius,
      useStampOpacity: useStampOpacity ?? this.useStampOpacity,
      passFieldConfig: passFieldConfig ?? this.passFieldConfig,
    );
  }
}

/// Customer model (business-owned customer record)
class Customer {
  final String id;
  final String businessId;
  final String phone;
  final String? name;
  final String? notes;
  final List<String> tags;
  final int totalVisits;
  final int totalRewards;
  final DateTime? lastVisit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.businessId,
    required this.phone,
    this.name,
    this.notes,
    this.tags = const [],
    this.totalVisits = 0,
    this.totalRewards = 0,
    this.lastVisit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      phone: data['phone'] ?? '',
      name: data['name'],
      notes: data['notes'],
      tags: List<String>.from(data['tags'] ?? []),
      totalVisits: data['totalVisits'] ?? 0,
      totalRewards: data['totalRewards'] ?? 0,
      lastVisit: (data['lastVisit'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'phone': phone,
      'name': name,
      'notes': notes,
      'tags': tags,
      'totalVisits': totalVisits,
      'totalRewards': totalRewards,
      'lastVisit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Customer copyWith({
    String? id,
    String? businessId,
    String? phone,
    String? name,
    String? notes,
    List<String>? tags,
    int? totalVisits,
    int? totalRewards,
    DateTime? lastVisit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      totalVisits: totalVisits ?? this.totalVisits,
      totalRewards: totalRewards ?? this.totalRewards,
      lastVisit: lastVisit ?? this.lastVisit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Customer progress in a specific program
class CustomerProgress {
  final String id;
  final String customerId;
  final String programId;
  final String businessId;
  final int stamps;
  final int rewardsRedeemed;
  final DateTime? lastStampAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Custom field values - key/value pairs where key matches CustomFieldDefinition.key
  final Map<String, String> customFieldValues;
  // Individual custom fields for backward compatibility with backend
  final String? customField1;
  final String? customField2;
  final String? customField3;

  const CustomerProgress({
    required this.id,
    required this.customerId,
    required this.programId,
    required this.businessId,
    required this.stamps,
    this.rewardsRedeemed = 0,
    this.lastStampAt,
    required this.createdAt,
    required this.updatedAt,
    this.customFieldValues = const {},
    this.customField1,
    this.customField2,
    this.customField3,
  });

  factory CustomerProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerProgress(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      programId: data['programId'] ?? '',
      businessId: data['businessId'] ?? '',
      stamps: data['stamps'] ?? 0,
      rewardsRedeemed: data['rewardsRedeemed'] ?? 0,
      lastStampAt: (data['lastStampAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customFieldValues:
          Map<String, String>.from(data['customFieldValues'] ?? {}),
      customField1: data['customField1'] as String?,
      customField2: data['customField2'] as String?,
      customField3: data['customField3'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'programId': programId,
      'businessId': businessId,
      'stamps': stamps,
      'rewardsRedeemed': rewardsRedeemed,
      'lastStampAt':
          lastStampAt != null ? Timestamp.fromDate(lastStampAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'customFieldValues': customFieldValues,
      if (customField1 != null) 'customField1': customField1,
      if (customField2 != null) 'customField2': customField2,
      if (customField3 != null) 'customField3': customField3,
    };
  }

  CustomerProgress copyWith({
    String? id,
    String? customerId,
    String? programId,
    String? businessId,
    int? stamps,
    int? rewardsRedeemed,
    DateTime? lastStampAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? customFieldValues,
    String? customField1,
    String? customField2,
    String? customField3,
  }) {
    return CustomerProgress(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      programId: programId ?? this.programId,
      businessId: businessId ?? this.businessId,
      stamps: stamps ?? this.stamps,
      rewardsRedeemed: rewardsRedeemed ?? this.rewardsRedeemed,
      lastStampAt: lastStampAt ?? this.lastStampAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      customField1: customField1 ?? this.customField1,
      customField2: customField2 ?? this.customField2,
      customField3: customField3 ?? this.customField3,
    );
  }
}

/// Activity log entry
class ActivityLog {
  final String id;
  final String businessId;
  final String customerId;
  final String? customerName;
  final String customerPhone;
  final String programId;
  final String programName;
  final ActivityType type;
  final int? stampCount;
  final int? maxStamps;
  final DateTime timestamp;

  const ActivityLog({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.customerName,
    required this.customerPhone,
    required this.programId,
    required this.programName,
    required this.type,
    this.stampCount,
    this.maxStamps,
    required this.timestamp,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'],
      customerPhone: data['customerPhone'] ?? '',
      programId: data['programId'] ?? '',
      programName: data['programName'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ActivityType.stamp,
      ),
      stampCount: data['stampCount'],
      maxStamps: data['maxStamps'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'programId': programId,
      'programName': programName,
      'type': type.name,
      'stampCount': stampCount,
      'maxStamps': maxStamps,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

enum ActivityType {
  stamp,
  reward,
  newCustomer,
}

/// =========================================
/// PUSH NOTIFICATIONS - رسائل Push
/// =========================================
class PushMessage {
  final String id;
  final String businessId;
  final String? programId; // null = all programs
  final String title;
  final String body;
  final String? imageUrl;
  final MessageStatus status;
  final int sentCount;
  final int failedCount;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const PushMessage({
    required this.id,
    required this.businessId,
    this.programId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.status = MessageStatus.draft,
    this.sentCount = 0,
    this.failedCount = 0,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
  });

  factory PushMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PushMessage(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      programId: data['programId'],
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MessageStatus.draft,
      ),
      sentCount: data['sentCount'] ?? 0,
      failedCount: data['failedCount'] ?? 0,
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      if (programId != null) 'programId': programId,
      'title': title,
      'body': body,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'status': status.name,
      'sentCount': sentCount,
      'failedCount': failedCount,
      if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt!),
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum MessageStatus { draft, scheduled, sending, sent, failed }

/// =========================================
/// SUBUSERS - المستخدمين الفرعيين
/// =========================================
class SubUser {
  final String id;
  final String businessId;
  final String email;
  final String name;
  final String? phone;
  final SubUserRole role;
  final List<String> locationIds; // الفروع المسموح بها
  final List<String> programIds; // البرامج المسموح بها
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const SubUser({
    required this.id,
    required this.businessId,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.locationIds = const [],
    this.programIds = const [],
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory SubUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubUser(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: SubUserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => SubUserRole.stamper,
      ),
      locationIds: List<String>.from(data['locationIds'] ?? []),
      programIds: List<String>.from(data['programIds'] ?? []),
      isActive: data['isActive'] ?? true,
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      'role': role.name,
      'locationIds': locationIds,
      'programIds': programIds,
      'isActive': isActive,
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool canStamp() =>
      role == SubUserRole.stamper ||
      role == SubUserRole.manager ||
      role == SubUserRole.admin;
  bool canManageCustomers() =>
      role == SubUserRole.manager || role == SubUserRole.admin;
  bool canManagePrograms() => role == SubUserRole.admin;
  bool canManageUsers() => role == SubUserRole.admin;
}

enum SubUserRole {
  stamper, // فقط إضافة أختام
  manager, // إضافة أختام + إدارة العملاء
  admin, // كل الصلاحيات
}

/// =========================================
/// USER CONTEXT - سياق المستخدم الحالي
/// =========================================
enum UserRole {
  owner, // صاحب النشاط التجاري
  manager, // مدير
  cashier, // كاشير
}

class UserContext {
  final String type; // 'owner' or 'team_member'
  final String businessId;
  final UserRole role;
  final String? teamMemberId; // Only for team members
  final String? name;
  final String? phone;

  const UserContext({
    required this.type,
    required this.businessId,
    required this.role,
    this.teamMemberId,
    this.name,
    this.phone,
  });

  bool get isOwner => type == 'owner';
  bool get isTeamMember => type == 'team_member';

  bool get canManagePrograms => role == UserRole.owner;
  bool get canManageTeam => role == UserRole.owner;
  bool get canManageSettings => role == UserRole.owner;
  bool get canViewAnalytics =>
      role == UserRole.owner || role == UserRole.manager;
  bool get canManageCustomers =>
      role == UserRole.owner || role == UserRole.manager;
  bool get canStamp => true; // All roles can stamp
}

/// Team member stored in businesses/{id}/team_members
class TeamMember {
  final String id;
  final String name;
  final String phone;
  final String role; // 'manager' or 'cashier'
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamMember(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'cashier',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserRole get userRole {
    switch (role) {
      case 'manager':
        return UserRole.manager;
      case 'cashier':
      default:
        return UserRole.cashier;
    }
  }
}

/// =========================================
/// LOCATIONS - المواقع/الفروع
/// =========================================
class BusinessLocation {
  final String id;
  final String businessId;
  final String name;
  final String? nameAr;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int geofenceRadius; // بالمتر للرسائل الموقعية
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;

  const BusinessLocation({
    required this.id,
    required this.businessId,
    required this.name,
    this.nameAr,
    this.address,
    this.latitude,
    this.longitude,
    this.geofenceRadius = 100,
    this.phone,
    this.email,
    this.isActive = true,
    required this.createdAt,
  });

  factory BusinessLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessLocation(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['nameAr'],
      address: data['address'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      geofenceRadius: data['geofenceRadius'] ?? 100,
      phone: data['phone'],
      email: data['email'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'name': name,
      if (nameAr != null) 'nameAr': nameAr,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'geofenceRadius': geofenceRadius,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// =========================================
/// GEO-MESSAGES - الرسائل الموقعية
/// =========================================
class GeoMessage {
  final String id;
  final String businessId;
  final String locationId;
  final String title;
  final String body;
  final GeoTriggerType triggerType;
  final bool isActive;
  final int triggerCount;
  final DateTime createdAt;

  const GeoMessage({
    required this.id,
    required this.businessId,
    required this.locationId,
    required this.title,
    required this.body,
    this.triggerType = GeoTriggerType.enter,
    this.isActive = true,
    this.triggerCount = 0,
    required this.createdAt,
  });

  factory GeoMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeoMessage(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      locationId: data['locationId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      triggerType: GeoTriggerType.values.firstWhere(
        (e) => e.name == data['triggerType'],
        orElse: () => GeoTriggerType.enter,
      ),
      isActive: data['isActive'] ?? true,
      triggerCount: data['triggerCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'locationId': locationId,
      'title': title,
      'body': body,
      'triggerType': triggerType.name,
      'isActive': isActive,
      'triggerCount': triggerCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum GeoTriggerType {
  enter, // عند الدخول للمنطقة
  exit, // عند الخروج من المنطقة
  dwell, // عند البقاء فترة في المنطقة
}

/// =========================================
/// ANALYTICS - التحليلات
/// =========================================
class AnalyticsSummary {
  final int totalCustomers;
  final int newCustomersToday;
  final int newCustomersWeek;
  final int newCustomersMonth;
  final int totalStamps;
  final int stampsToday;
  final int stampsWeek;
  final int stampsMonth;
  final int totalRewards;
  final int rewardsToday;
  final int rewardsWeek;
  final int rewardsMonth;
  final int activePrograms;
  final double retentionRate;
  final double avgStampsPerCustomer;
  final Map<String, int> stampsByDay; // آخر 30 يوم
  final Map<String, int> customersByDay;
  final Map<String, int> rewardsByDay;
  final List<TopCustomer> topCustomers;
  final List<TopProgram> topPrograms;

  const AnalyticsSummary({
    this.totalCustomers = 0,
    this.newCustomersToday = 0,
    this.newCustomersWeek = 0,
    this.newCustomersMonth = 0,
    this.totalStamps = 0,
    this.stampsToday = 0,
    this.stampsWeek = 0,
    this.stampsMonth = 0,
    this.totalRewards = 0,
    this.rewardsToday = 0,
    this.rewardsWeek = 0,
    this.rewardsMonth = 0,
    this.activePrograms = 0,
    this.retentionRate = 0,
    this.avgStampsPerCustomer = 0,
    this.stampsByDay = const {},
    this.customersByDay = const {},
    this.rewardsByDay = const {},
    this.topCustomers = const [],
    this.topPrograms = const [],
  });
}

class TopCustomer {
  final String id;
  final String name;
  final String phone;
  final int totalStamps;
  final int totalRewards;

  const TopCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalStamps,
    required this.totalRewards,
  });
}

class TopProgram {
  final String id;
  final String name;
  final int customerCount;
  final int stampCount;

  const TopProgram({
    required this.id,
    required this.name,
    required this.customerCount,
    required this.stampCount,
  });
}
