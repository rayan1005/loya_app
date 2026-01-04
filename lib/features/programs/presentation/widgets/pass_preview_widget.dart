import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/models/models.dart';

/// Real-time Apple Wallet pass preview widget
class PassPreviewWidget extends StatelessWidget {
  final String programName;
  final String rewardDescription;
  final int stampsRequired;
  final int currentStamps;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color labelColor;
  final String? logoUrl;
  final String? iconUrl;
  final String? stripUrl;
  final String stampStyle;
  // New: custom stamp icon URLs
  final String? stampActiveUrl;
  final String? stampInactiveUrl;
  // Old: custom fields with sample values (deprecated)
  final List<CustomFieldDefinition> customFields;
  final Map<String, String> customFieldValues;
  // New: stamp display mode
  final bool useStampOpacity;
  // New: Pass field config with priority order
  final PassFieldConfig? passFieldConfig;
  final List<String>? fieldPriorityOrder;
  // Sample customer data for preview
  final String? customerName;

  const PassPreviewWidget({
    super.key,
    required this.programName,
    required this.rewardDescription,
    required this.stampsRequired,
    required this.currentStamps,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.labelColor,
    this.logoUrl,
    this.iconUrl,
    this.stripUrl,
    this.stampStyle = 'circle',
    this.stampActiveUrl,
    this.stampInactiveUrl,
    this.customFields = const [],
    this.customFieldValues = const {},
    this.useStampOpacity = true,
    this.passFieldConfig,
    this.fieldPriorityOrder,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),

          // Strip Image or Stamps
          _buildStripArea(),

          // Info Section
          _buildInfoSection(),

          // Barcode Area
          _buildBarcodeArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: iconUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      iconUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        LucideIcons.gift,
                        color: foregroundColor,
                      ),
                    ),
                  )
                : Icon(
                    LucideIcons.gift,
                    color: foregroundColor,
                  ),
          ),
          const SizedBox(width: 12),

          // Logo or Title
          Expanded(
            child: logoUrl != null
                ? Image.network(
                    logoUrl!,
                    height: 30,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (_, __, ___) => Text(
                      programName,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    programName,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStripArea() {
    if (stripUrl != null) {
      return Image.network(
        stripUrl!,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildStampGrid(),
      );
    }
    return _buildStampGrid();
  }

  Widget _buildStampGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Stamps Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              stampsRequired > 6 ? 6 : stampsRequired,
              (index) => _buildStamp(index < currentStamps),
            ),
          ),
          if (stampsRequired > 6) ...[
            const SizedBox(height: 8),
            // Stamps Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                stampsRequired - 6,
                (index) => _buildStamp(index + 6 < currentStamps),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStamp(bool isActive) {
    final size = 32.0;

    // If custom stamp URL is provided, use it as an image
    if (stampActiveUrl != null && stampActiveUrl!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.4, // 40% opacity for inactive
          child: Image.network(
            stampActiveUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.circle,
              size: size * 0.7,
              color: isActive
                  ? foregroundColor
                  : foregroundColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    // Fall back to icon-based stamps
    final color = useStampOpacity
        ? (isActive ? foregroundColor : foregroundColor.withValues(alpha: 0.4))
        : foregroundColor;

    IconData icon;
    if (useStampOpacity) {
      // Same icon for both states in opacity mode
      switch (stampStyle) {
        case 'star':
          icon = LucideIcons.star;
          break;
        case 'heart':
          icon = LucideIcons.heart;
          break;
        case 'check':
          icon = LucideIcons.checkCircle;
          break;
        case 'coffee':
          icon = LucideIcons.coffee;
          break;
        case 'palm':
          icon = LucideIcons.palmtree;
          break;
        default: // circle
          icon = Icons.circle;
      }
    } else {
      // Different icons for active/inactive in separate icons mode
      switch (stampStyle) {
        case 'star':
          icon = isActive ? LucideIcons.star : Icons.star_border;
          break;
        case 'heart':
          icon = isActive ? LucideIcons.heart : Icons.favorite_border;
          break;
        case 'check':
          icon =
              isActive ? LucideIcons.checkCircle : Icons.check_circle_outline;
          break;
        case 'coffee':
          icon = LucideIcons.coffee;
          break;
        case 'palm':
          icon = LucideIcons.palmtree;
          break;
        default: // circle
          icon = isActive ? Icons.circle : Icons.circle_outlined;
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: size * 0.7,
        color: color,
      ),
    );
  }

  Widget _buildInfoSection() {
    // Build fields based on passFieldConfig if available
    final List<_PreviewField> previewFields = [];

    if (passFieldConfig != null) {
      // Use the new pass field config system with priority order
      final config = passFieldConfig!;
      final priorityOrder = fieldPriorityOrder ?? config.fieldPriorityOrder;

      // Build field map
      final fieldMap = <String, _PreviewField>{};

      if (config.showStampsRemaining) {
        fieldMap['stamps'] = _PreviewField(
          key: 'stamps',
          label: config.stampsLabel ?? '',
          value: '$currentStamps / $stampsRequired',
        );
      }

      if (config.showCustomerName) {
        fieldMap['customerName'] = _PreviewField(
          key: 'customerName',
          label: config.customerNameLabel ?? '',
          value: customerName ?? 'أحمد محمد',
        );
      }

      if (config.showBroadcastMessage) {
        fieldMap['broadcast'] = _PreviewField(
          key: 'broadcast',
          label: config.broadcastLabel ?? '',
          value: '---', // Broadcast message appears here when sent
        );
      }

      if (config.showMessage && (config.customMessage?.isNotEmpty ?? false)) {
        fieldMap['message'] = _PreviewField(
          key: 'message',
          label: config.messageLabel ?? '',
          value: config.customMessage!,
        );
      }

      if (config.showCustomField1) {
        fieldMap['customField1'] = _PreviewField(
          key: 'customField1',
          label: config.customField1Label ?? '',
          value: '---',
        );
      }

      if (config.showCustomField2) {
        fieldMap['customField2'] = _PreviewField(
          key: 'customField2',
          label: config.customField2Label ?? '',
          value: '---',
        );
      }

      if (config.showCustomField3) {
        fieldMap['customField3'] = _PreviewField(
          key: 'customField3',
          label: config.customField3Label ?? '',
          value: '---',
        );
      }

      // Order by merchant's priority
      for (final fieldKey in priorityOrder) {
        if (fieldMap.containsKey(fieldKey)) {
          previewFields.add(fieldMap[fieldKey]!);
        }
      }
    } else {
      // Fallback to old customFields system for backwards compatibility
      final frontFields = customFields
          .where((f) => f.enabled && f.showOnFront)
          .take(4)
          .toList();

      for (final field in frontFields) {
        previewFields.add(_PreviewField(
          key: field.key,
          label: field.label,
          value: customFieldValues[field.key] ?? '---',
        ));
      }
    }

    // First 4 fields go on front, rest on back
    final frontFields = previewFields.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress (Stamps + Reward - always shown at top)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأختام',
                    style: TextStyle(
                      color: labelColor.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$currentStamps / $stampsRequired',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المكافأة',
                    style: TextStyle(
                      color: labelColor.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      rewardDescription,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Custom fields from pass field config (front only, max 4)
          // Skip 'stamps' since it's already shown above
          if (frontFields.where((f) => f.key != 'stamps').isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            ...frontFields
                .where((f) => f.key != 'stamps')
                .map((field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            field.label,
                            style: TextStyle(
                              color: labelColor.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            field.value,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildBarcodeArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Fake QR Code
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: _QRPlaceholderPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'LOYA-PREVIEW',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QRPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;
    final random = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1],
      [0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1],
      [0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0],
      [1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1],
    ];

    for (var row = 0; row < 21; row++) {
      for (var col = 0; col < 21; col++) {
        if (random[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper class for preview fields
class _PreviewField {
  final String key;
  final String label;
  final String value;

  const _PreviewField({
    required this.key,
    required this.label,
    required this.value,
  });
}
