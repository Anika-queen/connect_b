import 'package:connect_b/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:connect_b/features/admin/presentation/pages/create_announcement_page.dart';
import 'package:connect_b/features/admin/presentation/pages/create_job_page.dart';
import 'package:connect_b/features/auth/presentation/pages/login_page.dart';
import 'package:connect_b/features/auth/presentation/pages/signup_page.dart';
import 'package:connect_b/features/chat/presentation/pages/conversation_page.dart';
import 'package:connect_b/features/home/presentation/pages/home_page.dart';
import 'package:connect_b/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:flutter/material.dart';
// nipa: update this page
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String profileEdit = '/profile/edit';
  static const String adminDashboard = '/admin';
  static const String adminCreateAnnouncement = '/admin/announcement/edit';
  static const String adminCreateJob = '/admin/job/edit';
  static const String conversation = '/chat/conversation';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.signUp:
        return MaterialPageRoute<void>(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.profileEdit:
        return MaterialPageRoute<bool?>(
          builder: (_) => const ProfileEditPage(),
          settings: settings,
        );
      case AppRoutes.adminDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminDashboardPage(),
          settings: settings,
        );
      case AppRoutes.adminCreateAnnouncement:
        return MaterialPageRoute<bool?>(
          builder: (_) => const CreateAnnouncementPage(),
          settings: settings,
        );
      case AppRoutes.adminCreateJob:
        return MaterialPageRoute<bool?>(
          builder: (_) => const CreateJobPage(),
          settings: settings,
        );
      case AppRoutes.conversation:
        return MaterialPageRoute<void>(
          builder: (_) => const ConversationPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Route not found')));
  }
}
