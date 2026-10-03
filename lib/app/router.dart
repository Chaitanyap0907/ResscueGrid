import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/enums.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/showcase/component_showcase_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/student/report_emergency_screen.dart';
import '../features/student/incident_tracking_screen.dart';
import '../features/student/my_reports_screen.dart';
import '../features/responder/responder_dashboard_screen.dart';
import '../features/responder/incoming_assignment_screen.dart';
import '../features/responder/active_incident_screen.dart';
import '../features/responder/response_history_screen.dart';
import '../features/admin/command_center_screen.dart';
import '../features/admin/incidents_list_screen.dart';
import '../features/admin/responders_screen.dart';
import '../features/admin/statistics_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // 1. Auth & Showcase
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const ComponentShowcaseScreen(),
    ),

    // 2. Direct fullscreen flows (not in bottom nav shell)
    GoRoute(
      path: '/student/report',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as IncidentCategory?;
        return ReportEmergencyScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/student/tracking/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return IncidentTrackingScreen(incidentId: id);
      },
    ),
    GoRoute(
      path: '/responder/incoming',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomingAssignmentScreen(),
    ),
    GoRoute(
      path: '/responder/active/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ActiveIncidentScreen(incidentId: id);
      },
    ),

    // 3. Student Shell Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final loc = state.uri.path;
        int idx = 0;
        UserRole currentRole = UserRole.student;

        if (loc.startsWith('/student/reports')) {
          idx = 1;
        } else if (loc.startsWith('/responder/history')) {
          idx = 2;
          currentRole = UserRole.responder;
        } else if (loc.startsWith('/responder/active')) {
          idx = 1;
          currentRole = UserRole.responder;
        } else if (loc.startsWith('/responder')) {
          idx = 0;
          currentRole = UserRole.responder;
        } else if (loc.startsWith('/admin/incidents')) {
          idx = 1;
          currentRole = UserRole.admin;
        } else if (loc.startsWith('/admin/responders')) {
          idx = 2;
          currentRole = UserRole.admin;
        } else if (loc.startsWith('/admin/statistics')) {
          idx = 3;
          currentRole = UserRole.admin;
        } else if (loc.startsWith('/admin')) {
          idx = 0;
          currentRole = UserRole.admin;
        } else if (loc.startsWith('/notifications')) {
          idx = 2;
        } else if (loc.startsWith('/profile')) {
          idx = 3;
        }

        return AppScaffold(
          selectedIndex: idx,
          role: currentRole,
          child: child,
        );
      },
      routes: [
        // Student Shell tabs
        GoRoute(
          path: '/student',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StudentHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/student/reports',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MyReportsScreen(),
          ),
        ),

        // Responder Shell tabs
        GoRoute(
          path: '/responder',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ResponderDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/responder/active',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ActiveIncidentScreen(),
          ),
        ),
        GoRoute(
          path: '/responder/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ResponseHistoryScreen(),
          ),
        ),

        // Admin Shell tabs
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CommandCenterScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/incidents',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: IncidentsListScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/responders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RespondersScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/statistics',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatisticsScreen(),
          ),
        ),

        // Shared Shell tabs
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);
