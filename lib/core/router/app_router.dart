import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell.dart';
import '../../features/dashboard/presentation/screens/overview_screen.dart';
import '../../features/programs/presentation/screens/programs_screen.dart';
import '../../features/programs/presentation/screens/program_designer_screen.dart';
import '../../features/programs/presentation/screens/share_program_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/customers/presentation/screens/stamp_flow_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/analytics/presentation/screens/advanced_analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/billing_screen.dart';
import '../../features/settings/presentation/screens/business_profile_screen.dart';
import '../../features/settings/presentation/screens/subusers_screen.dart';
import '../../features/settings/presentation/screens/locations_screen.dart';
import '../../features/settings/presentation/screens/export_screen.dart';
import '../../features/settings/presentation/screens/team_members_screen.dart';
import '../../features/settings/presentation/screens/branches_screen.dart';
import '../../features/messaging/presentation/screens/messages_screen.dart';
import '../../features/marketing/presentation/screens/referral_program_screen.dart';
import '../../features/marketing/presentation/screens/automation_screen.dart';
import '../../features/stamper/presentation/screens/stamper_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/otp';

      // If not logged in and not on login pages, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login pages, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),

      // Dashboard Shell with nested routes
      ShellRoute(
        builder: (context, state, child) {
          return DashboardShell(child: child);
        },
        routes: [
          // Overview
          GoRoute(
            path: '/',
            name: 'overview',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OverviewScreen(),
            ),
          ),

          // Programs
          GoRoute(
            path: '/programs',
            name: 'programs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgramsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-program',
                builder: (context, state) => const ProgramDesignerScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'edit-program',
                builder: (context, state) {
                  final programId = state.pathParameters['id']!;
                  return ProgramDesignerScreen(programId: programId);
                },
              ),
              GoRoute(
                path: ':id/share',
                name: 'share-program',
                builder: (context, state) {
                  final programId = state.pathParameters['id']!;
                  return ShareProgramScreen(programId: programId);
                },
              ),
            ],
          ),

          // Customers
          GoRoute(
            path: '/customers',
            name: 'customers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomersScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'customer-detail',
                builder: (context, state) {
                  final customerId = state.pathParameters['id']!;
                  return CustomerDetailScreen(customerId: customerId);
                },
              ),
            ],
          ),

          // Stamp Flow
          GoRoute(
            path: '/stamp',
            name: 'stamp',
            builder: (context, state) => const StampFlowScreen(),
          ),

          // Activity
          GoRoute(
            path: '/activity',
            name: 'activity',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActivityScreen(),
            ),
          ),

          // Analytics
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'advanced',
                name: 'advanced-analytics',
                builder: (context, state) => const AdvancedAnalyticsScreen(),
              ),
            ],
          ),

          // Messages / Push Notifications
          GoRoute(
            path: '/messages',
            name: 'messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesScreen(),
            ),
          ),

          // Marketing - Referral Program
          GoRoute(
            path: '/referral',
            name: 'referral',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReferralProgramScreen(),
            ),
          ),

          // Marketing - Automation
          GoRoute(
            path: '/automation',
            name: 'automation',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AutomationScreen(),
            ),
          ),

          // Stamper
          GoRoute(
            path: '/stamper',
            name: 'stamper',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StamperScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'business',
                name: 'business-profile',
                builder: (context, state) => const BusinessProfileScreen(),
              ),
              GoRoute(
                path: 'billing',
                name: 'billing',
                builder: (context, state) => const BillingScreen(),
              ),
              GoRoute(
                path: 'subusers',
                name: 'subusers',
                builder: (context, state) => const SubusersScreen(),
              ),
              GoRoute(
                path: 'locations',
                name: 'locations',
                builder: (context, state) => const LocationsScreen(),
              ),
              GoRoute(
                path: 'export',
                name: 'export',
                builder: (context, state) => const ExportScreen(),
              ),
              GoRoute(
                path: 'team',
                name: 'team-members',
                builder: (context, state) => const TeamMembersScreen(),
              ),
              GoRoute(
                path: 'branches',
                name: 'branches',
                builder: (context, state) => const BranchesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
