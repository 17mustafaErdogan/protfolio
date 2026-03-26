import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';

import '../screens/home_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/project_detail_screen.dart';
import '../screens/about_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/projects_admin.dart';
import '../screens/admin/project_edit_screen.dart';
import '../screens/admin/skills_admin.dart';
import '../screens/admin/cv_admin.dart';
import '../screens/admin/settings_admin.dart';
import '../screens/admin/expertise_areas_admin.dart';
import '../screens/admin/contact_messages_admin.dart';
import '../services/auth_service.dart';
import '../widgets/common/shell_scaffold.dart';

/// Uygulama içi sayfa yollarını tanımlayan sabit sınıf.
class AppRoutes {
  // Public routes
  static const String home = '/';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String contact = '/contact';
  static const String login = '/login';
  
  // Admin routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin';
  static const String adminProjects = '/admin/projects';
  static const String adminProjectNew = '/admin/projects/new';
  static const String adminProjectEdit = '/admin/projects/:id/edit';
  static const String adminSkills = '/admin/skills';
  static const String adminExpertiseAreas = '/admin/expertise-areas';
  static const String adminCV = '/admin/cv';
  static const String adminSettings = '/admin/settings';
  static const String adminMessages = '/admin/messages';

  static String projectDetailPath(String id) => '/projects/$id';
  static String adminProjectEditPath(String id) => '/admin/projects/$id/edit';
}

/// Admin sayfaları için yetkilendirme kontrolü.
String? _adminRedirect(BuildContext context, GoRouterState state) {
  final authService = context.read<AuthService>();
  if (!authService.isLoggedIn) {
    return AppRoutes.login;
  }
  return null;
}

/// Sayfa geçişleri için fade animasyonu.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: child,
  );
}

/// ShellRoute içindeki sayfalar için anlık geçiş.
Page<void> _shellPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

/// Router'ı oluşturur. AuthService, login/logout sonrası yönlendirmeyi
/// tetiklemek için [refreshListenable] olarak kullanılır.
GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authService,
    routes: [
    // ============================================================
    // PUBLIC ROUTES (NavBar/Footer ile)
    // ============================================================
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _shellPage(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.projects,
          name: 'projects',
          pageBuilder: (context, state) => _shellPage(state, const ProjectsScreen()),
        ),
        GoRoute(
          path: AppRoutes.projectDetail,
          name: 'project-detail',
          pageBuilder: (context, state) {
            final projectId = state.pathParameters['id']!;
            return _shellPage(state, ProjectDetailScreen(projectId: projectId));
          },
        ),
        GoRoute(
          path: AppRoutes.about,
          name: 'about',
          pageBuilder: (context, state) => _shellPage(state, const AboutScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => _shellPage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.contact,
          name: 'contact',
          pageBuilder: (context, state) => _shellPage(state, const ContactScreen()),
        ),
      ],
    ),
    
    // ============================================================
    // LOGIN ROUTE (Bağımsız)
    // ============================================================
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      redirect: (context, state) {
        // Zaten giriş yapılmışsa admin'e yönlendir
        final authService = context.read<AuthService>();
        if (authService.isLoggedIn) {
          return AppRoutes.admin;
        }
        return null;
      },
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    
    // ============================================================
    // ADMIN ROUTES (Korumalı, AdminShell ile)
    // ============================================================
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.admin,
          name: 'admin-dashboard',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminProjects,
          name: 'admin-projects',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProjectsAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminProjectNew,
          name: 'admin-project-new',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProjectEditScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminProjectEdit,
          name: 'admin-project-edit',
          redirect: _adminRedirect,
          pageBuilder: (context, state) {
            final projectId = state.pathParameters['id']!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ProjectEditScreen(projectId: projectId),
              transitionsBuilder: _fadeTransition,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.adminSkills,
          name: 'admin-skills',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SkillsAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminExpertiseAreas,
          name: 'admin-expertise-areas',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ExpertiseAreasAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminCV,
          name: 'admin-cv',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CVAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminSettings,
          name: 'admin-settings',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.adminMessages,
          name: 'admin-messages',
          redirect: _adminRedirect,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ContactMessagesAdminScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

/// 404 - Sayfa bulunamadı ekranı.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sayfa Bulunamadı',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aradığınız sayfa mevcut değil veya taşınmış olabilir.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Ana Sayfaya Dön'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
