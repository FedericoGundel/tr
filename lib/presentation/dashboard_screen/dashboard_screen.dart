import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

import '../../widgets/custom_icon_widget.dart';
import '../../services/conductor_service.dart';
import './widgets/metric_card_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic>? _conductor;
  List<dynamic> _pedidos = [];
  Map<String, dynamic>? _pedido;
  bool _isRefreshing = false;
  bool _loading = true;

   List<Map<String, dynamic>> _metrics = [

  ];
  Future<void> _fetchConductorData() async {
    try {
      final data = await ConductorService.getPedidosConductor();
      if (!mounted) return; // 👈 agregado

      if (data != null && data['user'] != null) {
        final pedidos = data['user']['pedidos'] as List<dynamic>? ?? [];

        if (!mounted) return; // 👈 agregado
        setState(() {
          _conductor = data['user'];
          _pedidos = pedidos;

          if (_pedido != null) {
            final idActual = _pedido!['idRegistro'];
            final coincide = pedidos.firstWhere(
                  (p) => p['idRegistro'] == idActual,
              orElse: () => pedidos.isNotEmpty ? pedidos.last : null,
            );
            _pedido = coincide;
          } else {
            _pedido = pedidos.isNotEmpty ? pedidos.last : null;
          }

          _loading = false;
          _updateMetrics();
        });
      }
    } catch (e) {
      if (!mounted) return; // 👈 agregado
      debugPrint("❌ Error: $e");
      setState(() => _loading = false);
    }
  }

  void _updateMetrics() {
    final totalPedidos = _pedidos.length;
    final entregados = _pedidos.where((p) => p['Estado'] == 'Entregado').length;
    final pendientes = totalPedidos - entregados;

    _metrics = [
      {
        'title': 'Pedidos totales',
        'value': '$totalPedidos',
        'trend': '', // podés calcular tendencia si tenés histórico
        'isPositive': true,
        'icon': Icons.numbers,
      },
      {
        'title': 'Pedidos pendientes',
        'value': '$pendientes',
        'trend': '',
        'isPositive': pendientes == 0,
        'icon': Icons.pending_actions,
      },
      {
        'title': 'Pedidos entregados',
        'value': '$entregados',
        'trend': '',
        'isPositive': true,
        'icon': Icons.check_circle,
      }
    ];
  }

  @override
  void initState() {
    super.initState();
    // 👈 si viene seteado, lo guardo
    _fetchConductorData();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/cam.png"), // 👈 tu imagen
            fit: BoxFit.cover, // ajusta la imagen al tamaño de la pantalla
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(context),
                    _buildMetricsSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        'Inicio',
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: CustomIconWidget(
            iconName: 'menu',
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [


      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Tienes 1 pedido pendiente asignado.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/view-a-list-screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  ),
                  child: Text(
                    'Ver pedidos',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'dashboard',
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _metrics.length,
          itemBuilder: (context, index) {
            final metric = _metrics[index];
            return MetricCardWidget(
              title: metric['title'] as String,
              value: metric['value'] as String,
              trend: metric['trend'] as String,
              isPositive: metric['isPositive'] as bool,
              icon: metric['icon'] as IconData,
              onTap: () => _handleMetricTap(context, metric),
              onLongPress: () => _handleMetricLongPress(context, metric),
            );
          },
        ),
      ],
    );
  }

/*
  Widget _buildQuickActionsSection(BuildContext context) {
    return QuickActionsWidget(
      onNewItemPressed: () => _showNewItemModal(context),
      onViewListPressed: () =>
          Navigator.pushNamed(context, '/view-a-list-screen'),
      onAnalyticsPressed: () => _showAnalytics(context),
    );
  }

*/
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_conductor == null) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const CustomIconWidget(
                      iconName: 'person',
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _conductor?['Nombre'] ?? 'Usuario',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _conductor?['Email'] ?? 'Sin email',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 0.h),
                children: [
                  _buildDrawerItem(
                    context,
                    'Inicio',
                    'dashboard',
                        () => Navigator.pop(context),
                    isSelected: true,
                  ),
                  _buildDrawerItem(
                    context,
                    'Pedidos',
                    'list_alt',
                        () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/view-a-list-screen');
                    },
                  ),


                  _buildDrawerItem(
                    context,
                    'Scanner',
                    'qr_code_scanner', // Cambiá por otro nombre si tu CustomIconWidget no tiene este ícono
                        () => _openScanner(context),
                  ),
                  _buildDrawerItem(
                    context,
                    'Entregas',
                    'local_shipping',
                        () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.entrega);
                    },
                  ),
                  const Divider(),

                  _buildDrawerItem(
                    context,
                    'Cerrar sesión',
                    'Cerrar sesión',
                        () => _handleLogout(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      String title,
      String iconName,
      VoidCallback onTap, {
        bool isSelected = false,
        bool isDestructive = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? colorScheme.error
            : isSelected
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDestructive
              ? colorScheme.error
              : isSelected
              ? colorScheme.primary
              : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleMetricTap(BuildContext context, Map<String, dynamic> metric) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${metric['title']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMetricLongPress(
      BuildContext context, Map<String, dynamic> metric) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metric['title'] as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _handleMetricTap(context, metric);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.pop(context); // cierra el Drawer
    Navigator.pushNamed(context, AppRoutes.scanner); // navega al scanner
    // Si preferís por string: Navigator.pushNamed(context, '/scanner-screen');
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon')),
        );
        break;
      case 'settings':
        _showSettings(context);
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // 🔑 Limpieza de la sesión
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                      (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
