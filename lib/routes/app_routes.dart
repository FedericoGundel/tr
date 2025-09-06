import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/view_a_list_screen/view_a_list_screen.dart';
import '../presentation/scanner_screen/scanner_screen.dart';
import '../presentation/entrega_screen/entrega_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String login = '/login-screen';
  static const String viewAList = '/view-a-list-screen';
  static const String scanner = '/scanner-screen';
  static const String entrega = '/entrega-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    login: (context) => const LoginScreen(),
    viewAList: (context) => const ViewAListScreen(),
    scanner: (context) => const ScannerScreen(),
    entrega: (context) => const EntregaScreen(),

    // TODO: Add your other routes here
  };
}
