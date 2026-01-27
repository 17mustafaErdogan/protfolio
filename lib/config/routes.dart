import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/project_detail_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/projects_admin.dart';
import '../screens/admin/project_edit_screen.dart';
import '../screens/admin/skills_admin.dart';
import '../screens/admin/cv_admin.dart';
import '../screens/admin/settings_admin.dart';
import '../services/auth_service.dart';
import '../widgets/common/shell_scaffold.dart';

/// Uygulama içi sayfa yollarını tanımlayan sabit sınıf.
class AppRoutes {
  // Public routes
  static const String home = '/';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String login = '/login';
  
  // Admin routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin';
  static const String adminProjects = '/admin/projects';
  static const String adminProjectNew = '/admin/projects/new';
  static const String adminProjectEdit = '/admin/projects/:id/edit';
  static const String adminSkills = '/admin/skills';
  static const String adminCV = '/admin/cv';
  static const String adminSettings = '/admin/settings';
  
  static String projectDetailPath(String id) => '/projects/$id';
  static String adminProjectEditPath(String id) => '/admin/projects/$id/edit';
}

/// Router yapılandırması.
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  
  // Auth durumunu yenile
  refreshListenable: _authRefreshListenable,
  
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
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.projects,
          name: 'projects',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProjectsScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.projectDetail,
          name: 'project-detail',
          pageBuilder: (context, state) {
            final projectId = state.pathParameters['id']!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ProjectDetailScreen(projectId: projectId),
              transitionsBuilder: _fadeTransition,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.about,
          name: 'about',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AboutScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.contact,
          name: 'contact',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ContactScreen(),
            transitionsBuilder: _fadeTransition,
          ),
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
      ],
    ),
  ],
);

/// Admin sayfaları için yetkilendirme kontrolü.
String? _adminRedirect(BuildContext context, GoRouterState state) {
  final authService = context.read<AuthService>();
  if (!authService.isLoggedIn) {
    return AppRoutes.login;
  }
  return null;
}

/// Auth durumu değişikliklerini dinlemek için listenable.
final _authRefreshListenable = _AuthRefreshNotifier();

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    // Bu basit bir implementasyon.
    // Gerçek uygulamada AuthService'i dinlemek gerekir.
  }
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
