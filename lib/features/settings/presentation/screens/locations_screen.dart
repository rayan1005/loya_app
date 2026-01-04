import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('الفروع والمواقع', style: AppTypography.headline),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddLocationDialog(businessId),
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('إضافة فرع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'أضف فروع متجرك لإرسال إشعارات موقعية للعملاء',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Locations List
            Expanded(
              child: businessId == null
                  ? const Center(child: Text('يرجى تسجيل الدخول'))
                  : _buildLocationsList(businessId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList(String businessId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('locations')
          .where('businessId', isEqualTo: businessId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.mapPin,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'لا توجد فروع مسجلة',
                  style: AppTypography.headline
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف فروعك لإرسال إشعارات تلقائية للعملاء القريبين',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _showAddLocationDialog(businessId),
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: const Text('إضافة فرع جديد',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: snapshot.data!.docs.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  // Last item is the add button
                  if (index == snapshot.data!.docs.length) {
                    return InkWell(
                      onTap: () => _showAddLocationDialog(businessId),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.plus,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'إضافة فرع جديد',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final doc = snapshot.data!.docs[index];
                  final location = BusinessLocation.fromFirestore(doc);
                  return _buildLocationCard(location);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationCard(BusinessLocation location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: location.isActive
              ? AppColors.divider
              : Colors.red.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.store, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name, style: AppTypography.titleMedium),
                    if (location.nameAr != null)
                      Text(
                        location.nameAr!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical),
                onSelected: (value) => _handleLocationAction(value, location),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 18),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'geo',
                    child: Row(
                      children: [
                        Icon(LucideIcons.bell, size: 18),
                        SizedBox(width: 8),
                        Text('رسالة موقعية'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: location.isActive ? 'disable' : 'enable',
                    child: Row(
                      children: [
                        Icon(
                          location.isActive
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(location.isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (location.address != null)
            Row(
              children: [
                Icon(LucideIcons.mapPin,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location.address!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: location.latitude != null
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      location.latitude != null
                          ? LucideIcons.mapPin
                          : LucideIcons.mapPinOff,
                      size: 12,
                      color: location.latitude != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location.latitude != null ? 'موقع محدد' : 'بدون موقع',
                      style: AppTypography.caption.copyWith(
                        color: location.latitude != null
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.radar, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${location.geofenceRadius}م',
                      style: AppTypography.caption.copyWith(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLocationAction(String action, BusinessLocation location) async {
    switch (action) {
      case 'edit':
        _showEditLocationDialog(location);
        break;
      case 'geo':
        _showGeoMessageDialog(location);
        break;
      case 'disable':
      case 'enable':
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(location.id)
            .update({'isActive': action == 'enable'});
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف الفرع'),
            content: Text('هل أنت متأكد من حذف "${location.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await FirebaseFirestore.instance
              .collection('locations')
              .doc(location.id)
              .delete();
        }
        break;
    }
  }

  void _showAddLocationDialog(String? businessId) {
    if (businessId == null) return;

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    int radius = 100;
    double? latitude;
    double? longitude;
    bool isLoadingLocation = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.mapPin, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('إضافة فرع جديد'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم الفرع *',
                      hintText: 'مثال: فرع الرياض',
                      prefixIcon: const Icon(LucideIcons.store),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      hintText: 'المدينة، الحي، الشارع',
                      prefixIcon: const Icon(LucideIcons.mapPin),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      prefixIcon: const Icon(LucideIcons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('الموقع الجغرافي', style: AppTypography.label),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (latitude != null && longitude != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.checkCircle,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'تم تحديد الموقع\n${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                                    style: AppTypography.caption
                                        .copyWith(color: Colors.green),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.x,
                                      size: 18, color: Colors.red),
                                  onPressed: () {
                                    setDialogState(() {
                                      latitude = null;
                                      longitude = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Current Location Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: isLoadingLocation
                                      ? null
                                      : () async {
                                          setDialogState(
                                              () => isLoadingLocation = true);
                                          try {
                                            final position =
                                                await _getCurrentLocation();
                                            if (position != null) {
                                              setDialogState(() {
                                                latitude = position['latitude'];
                                                longitude =
                                                    position['longitude'];
                                              });
                                            }
                                          } finally {
                                            setDialogState(() =>
                                                isLoadingLocation = false);
                                          }
                                        },
                                  icon: isLoadingLocation
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(LucideIcons.locateFixed),
                                  label: Text(isLoadingLocation
                                      ? 'جاري التحديد...'
                                      : 'استخدم موقعي الحالي'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Pick from Map Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close current dialog
                                    _showMapPickerSimple(
                                        businessId,
                                        nameController.text,
                                        addressController.text,
                                        phoneController.text,
                                        radius);
                                  },
                                  icon: const Icon(LucideIcons.map),
                                  label: const Text('اختر من الخريطة'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(color: Colors.green),
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Manual Coordinates
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'خط العرض',
                                        hintText: '24.7136',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (v) {
                                        final lat = double.tryParse(v);
                                        if (lat != null &&
                                            lat >= -90 &&
                                            lat <= 90) {
                                          setDialogState(() => latitude = lat);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'خط الطول',
                                        hintText: '46.6753',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (v) {
                                        final lng = double.tryParse(v);
                                        if (lng != null &&
                                            lng >= -180 &&
                                            lng <= 180) {
                                          setDialogState(() => longitude = lng);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('نطاق الإشعارات: '),
                      Expanded(
                        child: Slider(
                          value: radius.toDouble(),
                          min: 50,
                          max: 500,
                          divisions: 9,
                          label: '$radiusم',
                          onChanged: (value) {
                            setDialogState(() => radius = value.round());
                          },
                        ),
                      ),
                      Text('$radiusم'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى إدخال اسم الفرع'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('locations').add({
                    'businessId': businessId,
                    'name': nameController.text.trim(),
                    'address': addressController.text.trim().isEmpty
                        ? null
                        : addressController.text.trim(),
                    'phone': phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    'latitude': latitude,
                    'longitude': longitude,
                    'geofenceRadius': radius,
                    'isActive': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الفرع بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error adding location: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>?> _getCurrentLocation() async {
    final completer = Completer<Map<String, double>?>();

    try {
      html.window.navigator.geolocation.getCurrentPosition().then((position) {
        completer.complete({
          'latitude': position.coords!.latitude!.toDouble(),
          'longitude': position.coords!.longitude!.toDouble(),
        });
      }).catchError((error) {
        print('Geolocation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('يرجى السماح بالوصول للموقع في المتصفح ثم حاول مرة أخرى'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        completer.complete(null);
      });

      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهت مهلة تحديد الموقع، حاول مرة أخرى'),
              backgroundColor: Colors.orange,
            ),
          );
          return null;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطأ في تحديد الموقع: $e'),
            backgroundColor: Colors.red),
      );
      return null;
    }
  }

  void _showMapPicker(Function(double lat, double lng) onLocationPicked,
      {double? initialLat, double? initialLng}) {
    final lat = initialLat ?? 24.7136;
    final lng = initialLng ?? 46.6753;
    double selectedLat = lat;
    double selectedLng = lng;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.map, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('اختر الموقع من الخريطة'),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'اضغط على الخريطة لتحديد الموقع، أو أدخل الإحداثيات يدوياً',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                // Map iframe
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: HtmlElementView(
                        viewType:
                            'map-picker-${DateTime.now().millisecondsSinceEpoch}',
                        onPlatformViewCreated: (id) {
                          // Register the view factory
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Manual coordinate input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'خط العرض',
                          hintText: '24.7136',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        controller: TextEditingController(
                            text: selectedLat.toStringAsFixed(6)),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed >= -90 && parsed <= 90) {
                            selectedLat = parsed;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'خط الطول',
                          hintText: '46.6753',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        controller: TextEditingController(
                            text: selectedLng.toStringAsFixed(6)),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null &&
                              parsed >= -180 &&
                              parsed <= 180) {
                            selectedLng = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Open in Google Maps button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final url =
                          'https://www.google.com/maps?q=$selectedLat,$selectedLng';
                      html.window.open(url, '_blank');
                    },
                    icon: const Icon(LucideIcons.externalLink),
                    label: const Text('فتح في خرائط Google'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                onLocationPicked(selectedLat, selectedLng);
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.check),
              label: const Text('تأكيد الموقع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapPickerSimple(String businessId, String name, String address,
      String phone, int radius) {
    final latController = TextEditingController(text: '24.7136');
    final lngController = TextEditingController(text: '46.6753');
    String mapKey = DateTime.now().millisecondsSinceEpoch.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(LucideIcons.map, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('اختر موقع الفرع'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coordinate inputs FIRST
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          decoration: InputDecoration(
                            labelText: 'خط العرض',
                            hintText: '24.7136',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            isDense: true,
                            prefixIcon: const Icon(Icons.north, size: 18),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          decoration: InputDecoration(
                            labelText: 'خط الطول',
                            hintText: '46.6753',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            isDense: true,
                            prefixIcon: const Icon(Icons.east, size: 18),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          mapKey =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'تحديث الخريطة',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Map Preview using static image
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Image.network(
                            'https://staticmap.openstreetmap.de/staticmap.php?center=${latController.text},${lngController.text}&zoom=15&size=500x220&markers=${latController.text},${lngController.text},red-pushpin&key=$mapKey',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                        color: AppColors.primary),
                                    const SizedBox(height: 8),
                                    const Text('جاري تحميل الخريطة...'),
                                  ],
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.mapPin,
                                      size: 40, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                      '${latController.text}, ${lngController.text}',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('(معاينة الموقع)',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          // Center marker overlay
                          Center(
                            child: Icon(LucideIcons.mapPin,
                                color: Colors.red, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Google Maps button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        html.window.open(
                            'https://www.google.com/maps/@${latController.text},${lngController.text},17z',
                            '_blank');
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: const Text(
                          'افتح Google Maps للحصول على إحداثيات دقيقة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Help text
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.info,
                            size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'في Google Maps: اضغط يمين ← انسخ الإحداثيات',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final lat = double.tryParse(latController.text);
                  final lng = double.tryParse(lngController.text);

                  if (lat == null || lng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يرجى إدخال إحداثيات صحيحة'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('الإحداثيات خارج النطاق المسموح'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  // Save the location
                  try {
                    await FirebaseFirestore.instance
                        .collection('locations')
                        .add({
                      'businessId': businessId,
                      'name': name.isNotEmpty ? name : 'فرع جديد',
                      'address': address.isEmpty ? null : address,
                      'phone': phone.isEmpty ? null : phone,
                      'latitude': lat,
                      'longitude': lng,
                      'geofenceRadius': radius,
                      'isActive': true,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                            content: Text('تم إضافة الفرع بنجاح! ✓'),
                            backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                            content: Text('خطأ: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: const Icon(LucideIcons.check),
                label: const Text('حفظ الفرع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLocationDialog(BusinessLocation location) {
    final nameController = TextEditingController(text: location.name);
    final addressController = TextEditingController(text: location.address);
    final phoneController = TextEditingController(text: location.phone);
    int radius = location.geofenceRadius;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.pencil, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('تعديل الفرع'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الفرع',
                    prefixIcon: const Icon(LucideIcons.store),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: const Icon(LucideIcons.mapPin),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(LucideIcons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('نطاق الإشعارات: '),
                    Expanded(
                      child: Slider(
                        value: radius.toDouble(),
                        min: 50,
                        max: 500,
                        divisions: 9,
                        label: '$radiusم',
                        onChanged: (value) {
                          setDialogState(() => radius = value.round());
                        },
                      ),
                    ),
                    Text('$radiusم'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('locations')
                    .doc(location.id)
                    .update({
                  'name': nameController.text.trim(),
                  'address': addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  'phone': phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  'geofenceRadius': radius,
                });

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGeoMessageDialog(BusinessLocation location) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    GeoTriggerType triggerType = GeoTriggerType.enter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.bell, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('رسالة موقعية - ${location.name}'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<GeoTriggerType>(
                  initialValue: triggerType,
                  decoration: InputDecoration(
                    labelText: 'نوع التنبيه',
                    prefixIcon: const Icon(LucideIcons.radar),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: GeoTriggerType.enter,
                        child: Text('عند الدخول للمنطقة')),
                    DropdownMenuItem(
                        value: GeoTriggerType.exit,
                        child: Text('عند الخروج من المنطقة')),
                    DropdownMenuItem(
                        value: GeoTriggerType.dwell,
                        child: Text('عند البقاء في المنطقة')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => triggerType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإشعار',
                    hintText: 'مثال: مرحباً بك!',
                    prefixIcon: const Icon(LucideIcons.type),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'نص الإشعار',
                    hintText: 'أنت قريب من فرعنا، لا تنسى ختم بطاقتك!',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(LucideIcons.messageSquare),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    bodyController.text.isEmpty) {
                  return;
                }

                final businessId = ref.read(currentBusinessIdProvider);
                if (businessId == null) return;

                await FirebaseFirestore.instance
                    .collection('geo_messages')
                    .add({
                  'businessId': businessId,
                  'locationId': location.id,
                  'title': titleController.text.trim(),
                  'body': bodyController.text.trim(),
                  'triggerType': triggerType.name,
                  'isActive': true,
                  'triggerCount': 0,
                  'createdAt': Timestamp.now(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ تم إنشاء الرسالة الموقعية'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
