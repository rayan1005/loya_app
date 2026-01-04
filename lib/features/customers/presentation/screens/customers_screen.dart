import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/utils/phone_utils.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;
    final businessId = ref.watch(currentBusinessIdProvider);

    return Column(
      children: [
        // Search header
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? AppSpacing.pagePaddingMobile
                : AppSpacing.pagePadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: l10n.get('search_customers'),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Add customer button
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showAddCustomerSheet(context, l10n, businessId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: const Icon(
                      LucideIcons.userPlus,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Customers list from Firestore
        Expanded(
          child: businessId == null
              ? _buildLoginRequired()
              : _buildCustomersList(businessId, l10n, isMobile),
        ),
      ],
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.logIn, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'يرجى تسجيل الدخول',
            style: AppTypography.title.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(
      String businessId, AppLocalizations l10n, bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('businessId', isEqualTo: businessId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Customers error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل العملاء',
                  style: AppTypography.title
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(l10n);
        }

        // Sort by lastVisit client-side and filter by search query
        var customers = snapshot.data!.docs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final phone = data['phone']?.toString().toLowerCase() ?? '';
          final name = data['name']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          return phone.contains(query) || name.contains(query);
        }).toList();

        // Sort by lastVisit descending (client-side to avoid index requirement)
        customers.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aVisit =
              (aData['lastVisit'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bVisit =
              (bData['lastVisit'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return bVisit.compareTo(aVisit);
        });

        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.searchX,
                    size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد عملاء بهذا البحث',
                  style: AppTypography.title
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(
            isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          ),
          itemCount: customers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = customers[index];
            final customer = Customer.fromFirestore(doc);
            return _CustomerCard(
              customer: customer,
              onTap: () => context.push('/customers/${customer.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عملاء حتى الآن',
            style: AppTypography.title.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف أول عميل للبدء',
            style: AppTypography.body.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerSheet(
      BuildContext context, AppLocalizations l10n, String? businessId) {
    if (businessId == null) return;

    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.get('add_customer'),
                  style: AppTypography.headline,
                ),
                const SizedBox(height: 24),

                // Phone field
                Text(
                  l10n.get('customer_phone'),
                  style: AppTypography.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      hintText: '+966 5X XXX XXXX',
                      prefixIcon: Icon(LucideIcons.phone, size: 20),
                    ),
                    autofocus: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Name field
                Text(
                  l10n.get('customer_name'),
                  style: AppTypography.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: l10n.get('customer_name'),
                    prefixIcon: const Icon(LucideIcons.user, size: 20),
                  ),
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final phoneInput = phoneController.text.trim();
                            if (phoneInput.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('يرجى إدخال رقم الهاتف'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }

                            // Normalize phone number
                            final normalizedPhone =
                                PhoneUtils.normalize(phoneInput);
                            if (normalizedPhone == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('رقم الهاتف غير صحيح'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }

                            setSheetState(() => isLoading = true);

                            try {
                              // Check if customer exists with any phone variant
                              final phoneVariants =
                                  PhoneUtils.getSearchVariants(phoneInput);
                              bool customerExists = false;

                              for (final phoneVar in phoneVariants) {
                                final existing = await FirebaseFirestore
                                    .instance
                                    .collection('customers')
                                    .where('businessId', isEqualTo: businessId)
                                    .where('phone', isEqualTo: phoneVar)
                                    .limit(1)
                                    .get();
                                if (existing.docs.isNotEmpty) {
                                  customerExists = true;
                                  break;
                                }
                              }

                              if (customerExists) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('العميل موجود مسبقاً'),
                                      backgroundColor: Colors.orange),
                                );
                                return;
                              }

                              // Create new customer with normalized phone
                              await FirebaseFirestore.instance
                                  .collection('customers')
                                  .add({
                                'businessId': businessId,
                                'phone':
                                    normalizedPhone, // Always store normalized
                                'name': nameController.text.trim().isEmpty
                                    ? null
                                    : nameController.text.trim(),
                                'totalVisits': 0,
                                'totalRewards': 0,
                                'lastVisit': FieldValue.serverTimestamp(),
                                'createdAt': FieldValue.serverTimestamp(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              });

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(l10n.get('success')),
                                    backgroundColor: AppColors.success),
                              );
                            } catch (e) {
                              setSheetState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('خطأ: ${e.toString()}'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(l10n.get('add_customer')),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: customer.name != null && customer.name!.isNotEmpty
                      ? Text(
                          customer.name![0].toUpperCase(),
                          style: AppTypography.title
                              .copyWith(color: AppColors.primary),
                        )
                      : Icon(LucideIcons.user, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name ?? customer.phone,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (customer.name != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.totalVisits} زيارة',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (customer.totalRewards > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${customer.totalRewards} مكافأة',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 8),
              Icon(LucideIcons.chevronLeft,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
