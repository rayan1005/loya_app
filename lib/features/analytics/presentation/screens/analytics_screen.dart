import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/data/providers/data_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointTablet;
    final businessId = ref.watch(currentBusinessIdProvider);

    if (businessId == null) {
      return _buildLoginRequired();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('analytics'),
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.get('analytics_subtitle'),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Period selector
                  _buildPeriodSelector(),
                ],
              ),
              const SizedBox(height: 24),

              // Stats cards from Firestore
              _buildStatsRow(l10n, isMobile, businessId),
              const SizedBox(height: 24),

              // Charts
              if (isMobile) ...[
                _buildStampsChart(l10n, businessId),
                const SizedBox(height: 16),
                _buildCustomersChart(l10n, businessId),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStampsChart(l10n, businessId)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCustomersChart(l10n, businessId)),
                  ],
                ),
              const SizedBox(height: 24),

              // Programs performance from Firestore
              _buildProgramsPerformance(l10n, businessId),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: '7 أيام',
            isSelected: _selectedPeriod == '7d',
            onTap: () => setState(() => _selectedPeriod = '7d'),
          ),
          _PeriodButton(
            label: '30 يوم',
            isSelected: _selectedPeriod == '30d',
            onTap: () => setState(() => _selectedPeriod = '30d'),
          ),
          _PeriodButton(
            label: '90 يوم',
            isSelected: _selectedPeriod == '90d',
            onTap: () => setState(() => _selectedPeriod = '90d'),
          ),
        ],
      ),
    );
  }

  int _getPeriodDays() {
    switch (_selectedPeriod) {
      case '30d':
        return 30;
      case '90d':
        return 90;
      default:
        return 7;
    }
  }

  Widget _buildStatsRow(
      AppLocalizations l10n, bool isMobile, String businessId) {
    final periodDays = _getPeriodDays();
    final startDate = DateTime.now().subtract(Duration(days: periodDays));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('businessId', isEqualTo: businessId)
          .orderBy('timestamp', descending: true)
          .limit(500)
          .snapshots(),
      builder: (context, activitySnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .where('businessId', isEqualTo: businessId)
              .snapshots(),
          builder: (context, customersSnapshot) {
            // Calculate stats from real data
            int totalStamps = 0;
            int totalRewards = 0;
            int totalCustomers = customersSnapshot.data?.docs.length ?? 0;

            if (activitySnapshot.hasData) {
              for (var doc in activitySnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                // Filter by date client-side
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                if (timestamp == null || timestamp.isBefore(startDate)) {
                  continue;
                }

                final type = data['type'] ?? '';
                if (type == 'stamp') {
                  totalStamps++;
                } else if (type == 'reward') {
                  totalRewards++;
                }
              }
            }

            // Calculate return rate (customers with more than 1 visit)
            int returningCustomers = 0;
            if (customersSnapshot.hasData) {
              for (var doc in customersSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if ((data['totalVisits'] ?? 0) > 1) {
                  returningCustomers++;
                }
              }
            }
            int returnRate = totalCustomers > 0
                ? ((returningCustomers / totalCustomers) * 100).round()
                : 0;

            final stats = [
              _StatData(
                label: l10n.get('total_stamps'),
                value: totalStamps.toString(),
                change: '',
                isPositive: true,
                icon: LucideIcons.stamp,
                color: AppColors.programOrange,
              ),
              _StatData(
                label: l10n.get('rewards_earned'),
                value: totalRewards.toString(),
                change: '',
                isPositive: true,
                icon: LucideIcons.gift,
                color: AppColors.programPurple,
              ),
              _StatData(
                label: l10n.get('active_customers'),
                value: totalCustomers.toString(),
                change: '',
                isPositive: true,
                icon: LucideIcons.users,
                color: AppColors.programBlue,
              ),
              _StatData(
                label: l10n.get('return_rate'),
                value: '$returnRate%',
                change: '',
                isPositive: true,
                icon: LucideIcons.refreshCw,
                color: AppColors.programTeal,
              ),
            ];

            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(data: stats[0])),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(data: stats[1])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(data: stats[2])),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(data: stats[3])),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _StatCard(data: stat),
                        ),
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildStampsChart(AppLocalizations l10n, String businessId) {
    final periodDays = _getPeriodDays();
    final startDate = DateTime.now().subtract(Duration(days: periodDays));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('businessId', isEqualTo: businessId)
          .orderBy('timestamp', descending: true)
          .limit(500)
          .snapshots(),
      builder: (context, snapshot) {
        // Group stamps by day (filter client-side)
        Map<int, int> stampsByDay = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Filter by type and date client-side
            if (data['type'] != 'stamp') continue;

            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            if (timestamp == null || timestamp.isBefore(startDate)) continue;

            final dayIndex = DateTime.now().difference(timestamp).inDays;
            if (dayIndex < 7) {
              stampsByDay[6 - dayIndex] = (stampsByDay[6 - dayIndex] ?? 0) + 1;
            }
          }
        }

        // Create chart spots
        List<FlSpot> spots = List.generate(
            7, (i) => FlSpot(i.toDouble(), (stampsByDay[i] ?? 0).toDouble()));
        double maxY = spots.map((s) => s.y).fold(10.0, (a, b) => a > b ? a : b);
        maxY = ((maxY / 10).ceil() * 10).toDouble();
        if (maxY < 10) maxY = 10;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('stamps_over_time'),
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              'أحد',
                              'إثن',
                              'ثلا',
                              'أرب',
                              'خمي',
                              'جمع',
                              'سبت'
                            ];
                            final now = DateTime.now();
                            final dayIndex =
                                (now.weekday + value.toInt() - 6) % 7;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[dayIndex],
                                style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY / 4,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTypography.captionSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomersChart(AppLocalizations l10n, String businessId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('businessId', isEqualTo: businessId)
          .snapshots(),
      builder: (context, snapshot) {
        int active = 0;
        int occasional = 0;
        int inactive = 0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final lastVisit = (data['lastVisit'] as Timestamp?)?.toDate();
            if (lastVisit == null) {
              inactive++;
            } else {
              final daysSinceVisit = now.difference(lastVisit).inDays;
              if (daysSinceVisit <= 7) {
                active++;
              } else if (daysSinceVisit <= 30) {
                occasional++;
              } else {
                inactive++;
              }
            }
          }
        }

        final total = active + occasional + inactive;
        final activePercent = total > 0 ? ((active / total) * 100).round() : 0;
        final occasionalPercent =
            total > 0 ? ((occasional / total) * 100).round() : 0;
        final inactivePercent =
            total > 0 ? ((inactive / total) * 100).round() : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('customer_distribution'),
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: total == 0
                    ? Center(
                        child: Text(
                          'لا يوجد بيانات',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  if (active > 0)
                                    PieChartSectionData(
                                      color: AppColors.programOrange,
                                      value: active.toDouble(),
                                      title: '$activePercent%',
                                      radius: 50,
                                      titleStyle: AppTypography.label.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (occasional > 0)
                                    PieChartSectionData(
                                      color: AppColors.programPurple,
                                      value: occasional.toDouble(),
                                      title: '$occasionalPercent%',
                                      radius: 50,
                                      titleStyle: AppTypography.label.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (inactive > 0)
                                    PieChartSectionData(
                                      color: AppColors.programTeal,
                                      value: inactive.toDouble(),
                                      title: '$inactivePercent%',
                                      radius: 50,
                                      titleStyle: AppTypography.label.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem(
                                color: AppColors.programOrange,
                                label: '${l10n.get('active')} ($active)',
                              ),
                              const SizedBox(height: 8),
                              _LegendItem(
                                color: AppColors.programPurple,
                                label:
                                    '${l10n.get('occasional')} ($occasional)',
                              ),
                              const SizedBox(height: 8),
                              _LegendItem(
                                color: AppColors.programTeal,
                                label: '${l10n.get('inactive')} ($inactive)',
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgramsPerformance(AppLocalizations l10n, String businessId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                Icon(LucideIcons.barChart3,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد برامج لعرض الإحصائيات',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.get('programs_performance'),
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...snapshot.data!.docs.asMap().entries.map((entry) {
                final doc = entry.value;
                final data = doc.data() as Map<String, dynamic>;
                final colors = [
                  AppColors.programOrange,
                  AppColors.programPurple,
                  AppColors.programTeal,
                  AppColors.programBlue,
                ];

                return Column(
                  children: [
                    _ProgramPerformanceRow(
                      programId: doc.id,
                      businessId: businessId,
                      name: data['name'] ?? 'برنامج',
                      color: colors[entry.key % colors.length],
                    ),
                    if (entry.key < snapshot.data!.docs.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
              if (data.change.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: data.isPositive
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.change,
                    style: AppTypography.captionSmall.copyWith(
                      color:
                          data.isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: AppTypography.numberLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgramPerformanceRow extends StatelessWidget {
  final String programId;
  final String businessId;
  final String name;
  final Color color;

  const _ProgramPerformanceRow({
    required this.programId,
    required this.businessId,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wallet_passes')
          .where('programId', isEqualTo: programId)
          .snapshots(),
      builder: (context, snapshot) {
        int totalStamps = 0;
        int totalRewards = 0;
        int customers = 0;

        if (snapshot.hasData) {
          customers = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalStamps += (data['currentStamps'] ?? 0) as int;
            totalRewards += (data['totalRewards'] ?? 0) as int;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.star,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  name,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalStamps.toString(),
                      style: AppTypography.numberMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'أختام',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalRewards.toString(),
                      style: AppTypography.numberMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'مكافآت',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      customers.toString(),
                      style: AppTypography.numberMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'عملاء',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
