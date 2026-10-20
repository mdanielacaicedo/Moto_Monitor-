import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_moto_screen.dart';
import 'models/documento.dart';
import 'models/mantenimiento.dart';
import 'models/moto.dart';
import 'models/recordatorio.dart';
import 'providers/app_provider.dart';
import 'services/data_service.dart';
import 'theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    MantenimientoScreen(),
    MiMotoScreen(),
    DocumentosScreen(),
    RecordatoriosScreen(),
    ConfiguracionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Servicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.two_wheeler_outlined),
            selectedIcon: Icon(Icons.two_wheeler),
            label: 'Mi Moto',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Docs',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _navigationAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    if (!_navigationAttempted && appProvider.isInitialized && !appProvider.hasData) {
      _navigationAttempted = true;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMotoScreen()),
          ).then((_) {
            setState(() => _navigationAttempted = false);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Moto Monitor'),
        elevation: 0,
        actions: [
          Consumer<AppProvider>(
            builder: (context, appProvider, _) {
              return IconButton(
                icon: appProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: appProvider.isLoading ? null : () => appProvider.refreshData(),
                tooltip: 'Actualizar datos',
              );
            },
          ),
          const PopupMenuBuilder(),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Stack(
            children: [
              _buildMainContent(context, appProvider),
              if (appProvider.isLoading && appProvider.isInitialized)
                Container(
                  color: AppTheme.textPrimary.withValues(alpha: 0.06),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Actualizando...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppProvider appProvider) {
    if (!appProvider.hasData) {
      return const SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotoCard(context, appProvider.moto!),
          const SizedBox(height: 24),
          _buildAlertasSection(context, appProvider),
          const SizedBox(height: 24),
          _buildMantenimientoSection(context, appProvider),
          const SizedBox(height: 24),
          _buildAccesosRapidos(context, appProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMotoCard(BuildContext context, dynamic moto) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.onPrimaryColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.two_wheeler,
                    size: 32,
                    color: AppTheme.onPrimaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${moto.marca} ${moto.modelo}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppTheme.onPrimaryColor),
                      ),
                      Text(
                        'Placa: ${moto.placa}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.78)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMotoInfoItem(
                  context,
                  'Año',
                  moto.ano.toString(),
                    AppTheme.onPrimaryColor,
                ),
                _buildMotoInfoItem(
                  context,
                  'Km',
                  _formatNumber(moto.kilometraje),
                    AppTheme.onPrimaryColor,
                ),
                _buildMotoInfoItem(
                  context,
                  'Color',
                  moto.color ?? 'N/A',
                    AppTheme.onPrimaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotoInfoItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildAlertasSection(BuildContext context, AppProvider appProvider) {
    final hasAlerts = appProvider.totalAlertas > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado General',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: hasAlerts ? AppTheme.warningColor.withValues(alpha: 0.1) : AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasAlerts
                  ? AppTheme.warningColor.withValues(alpha: 0.3)
                  : AppTheme.successColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: hasAlerts
                        ? AppTheme.warningColor.withValues(alpha: 0.2)
                        : AppTheme.successColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasAlerts ? Icons.warning_outlined : Icons.check_circle_outline,
                    size: 28,
                    color: hasAlerts
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAlerts
                            ? 'Tienes ${appProvider.totalAlertas} alerta(s)'
                            : 'Todo está en orden',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: hasAlerts
                                  ? AppTheme.warningColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasAlerts
                            ? 'Revisa documentos y mantenimiento'
                            : 'No hay alertas pendientes',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMantenimientoSection(BuildContext context, AppProvider appProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Próximo Servicio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Programado a 1,200 km',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.7,
                minHeight: 8,
                backgroundColor: AppTheme.outlineColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Faltan 1,200 km aproximadamente',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesosRapidos(BuildContext context, AppProvider appProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAccesoRapido(
                context,
                'Registrar\nServicio',
                Icons.add_circle_outline,
                AppTheme.successColor,
                () => _showMantenimientoDialog(context, appProvider),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccesoRapido(
                context,
                'Ver\nDocumentos',
                Icons.article_outlined,
                AppTheme.infoColor,
                () => _navigateToDocuments(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccesoRapido(
                context,
                'Actualizar\nKilometraje',
                Icons.speed_outlined,
                AppTheme.accentColor,
                () => _showKilometrajeDialog(context, appProvider),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccesoRapido(
    BuildContext context,
    String texto,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKilometrajeDialog(BuildContext context, AppProvider appProvider) {
    final TextEditingController controller = TextEditingController();
    final currentKm = appProvider.moto?.kilometraje ?? 0;
    controller.text = currentKm.toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.speed_outlined,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Actualizar Kilometraje'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Km actual: ${_formatNumber(currentKm)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nuevo kilometraje',
                  suffixText: 'km',
                  prefixIcon: const Icon(Icons.speed_outlined),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final nuevoKm = int.tryParse(controller.text);
                if (nuevoKm != null && nuevoKm >= currentKm) {
                  try {
                    await appProvider.actualizarKilometraje(nuevoKm);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showMantenimientoDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Registrar Servicio'),
            ],
          ),
          content: const Text(
            'Esta funcionalidad estará disponible pronto. Podrás registrar servicios de mantenimiento, cambios de aceite, llantas y más.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDocuments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a documentos...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class PopupMenuBuilder extends StatelessWidget {
  const PopupMenuBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de cuenta',
      icon: const Icon(Icons.account_circle),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          value: 'user_info',
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appProvider.currentUserName ?? 'Usuario',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    appProvider.currentUserEmail ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              );
            },
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorColor),
              SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
        ),
       ],
       onSelected: (value) async {
         if (value == 'logout') {
           await context.read<AppProvider>().logout();
         }
       },
    );
  }
}

class MantenimientoScreen extends StatelessWidget {
  const MantenimientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicio')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return FutureBuilder<List<Mantenimiento>>(
            future: DataService.instance.getMantenimientos(),
            builder: (context, snapshot) {
              final moto = appProvider.moto;
              final items = snapshot.data ?? const <Mantenimiento>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (moto == null) {
                return _EmptyScreen(
                  icon: Icons.build_circle_outlined,
                  title: 'Aún no hay servicios registrados',
                  message: 'Primero registra tu moto para comenzar a guardar mantenimientos, cambios de aceite y otros servicios.',
                  actionLabel: 'Registrar motocicleta',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddMotoScreen()));
                  },
                );
              }

              if (items.isEmpty) {
                return _EmptyScreen(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin historial de servicio',
                  message: 'Cuando registres un mantenimiento, aquí verás la fecha, el tipo de servicio, el kilometraje y el costo.',
                  actionLabel: 'Registrar motocicleta',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddMotoScreen(moto: moto)));
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _SectionHeader(
                      title: 'Historial de servicios',
                      subtitle: 'Revisa tus mantenimientos con una línea de tiempo clara.',
                    );
                  }
                  final mantenimiento = items[index - 1];
                  return _MaintenanceTimelineCard(mantenimiento: mantenimiento);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MiMotoScreen extends StatelessWidget {
  const MiMotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Moto')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final moto = appProvider.moto;

          if (moto == null) {
            return _EmptyScreen(
              icon: Icons.two_wheeler_outlined,
              title: 'Todavía no has configurado tu moto',
              message: 'Agrega los datos de tu motocicleta para verlos aquí y poder editarlos cuando lo necesites.',
              actionLabel: 'Agregar motocicleta',
              onAction: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddMotoScreen()));
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.two_wheeler, color: AppTheme.primaryColor, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${moto.marca} ${moto.modelo}', style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(height: 4),
                                Text('Placa ${moto.placa.isEmpty ? 'pendiente' : moto.placa}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _MotoInfoGrid(moto: moto),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddMotoScreen(moto: moto)));
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar información'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return FutureBuilder<List<Documento>>(
            future: DataService.instance.getDocumentos(),
            builder: (context, snapshot) {
              final moto = appProvider.moto;
              final documentos = snapshot.data ?? const <Documento>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (moto == null) {
                return const _EmptyScreen(
                  icon: Icons.folder_open_outlined,
                  title: 'Sin documentos todavía',
                  message: 'Cuando registres tu moto podrás organizar aquí SOAT, revisión técnico-mecánica y otros documentos.',
                );
              }

              if (documentos.isEmpty) {
                return _EmptyScreen(
                  icon: Icons.folder_open_outlined,
                  title: 'Aún no hay documentos cargados',
                  message: 'Agrega tus documentos para ver vigencia, estado y fechas de vencimiento en un solo lugar.',
                  actionLabel: 'Editar moto',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddMotoScreen(moto: moto)));
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final documento = documentos[index];
                  return _DocumentCard(documento: documento);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: documentos.length,
              );
            },
          );
        },
      ),
    );
  }
}

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return FutureBuilder<List<Recordatorio>>(
            future: DataService.instance.getRecordatorios(),
            builder: (context, snapshot) {
              final moto = appProvider.moto;
              final recordatorios = snapshot.data ?? const <Recordatorio>[];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (moto == null) {
                return const _EmptyScreen(
                  icon: Icons.notifications_outlined,
                  title: 'Sin alertas todavía',
                  message: 'Cuando configures tu moto aparecerán aquí los recordatorios y vencimientos importantes.',
                );
              }

              if (recordatorios.isEmpty) {
                return _EmptyScreen(
                  icon: Icons.notifications_none_outlined,
                  title: 'No tienes alertas activas',
                  message: 'Aquí se mostrarán tus recordatorios de mantenimiento, documentos y fechas importantes.',
                  actionLabel: 'Editar moto',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddMotoScreen(moto: moto)));
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final recordatorio = recordatorios[index];
                  return _ReminderCard(recordatorio: recordatorio);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: recordatorios.length,
              );
            },
          );
        },
      ),
    );
  }
}

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<AppProvider>(
            builder: (context, appProvider, _) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: const Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  title: Text(appProvider.currentUserName ?? 'Usuario'),
                  subtitle: Text(appProvider.currentUserEmail ?? 'Sin correo configurado'),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Cuenta', subtitle: 'Opciones relacionadas con tu perfil y seguridad.'),
          _SettingTile(title: 'Perfil', subtitle: 'Edita tu información personal', icon: Icons.person_outline, onTap: () {}),
          _SettingTile(title: 'Seguridad', subtitle: 'Contraseña y privacidad', icon: Icons.security_outlined, onTap: () {}),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Notificaciones', subtitle: 'Define qué avisos quieres recibir.'),
          _SettingTile(title: 'Alertas de servicio', subtitle: 'Avisos de mantenimiento y revisiones', icon: Icons.notifications_outlined, onTap: () {}),
          _SettingTile(title: 'Vencimientos', subtitle: 'Documentos próximos a vencer', icon: Icons.calendar_today_outlined, onTap: () {}),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Aplicación', subtitle: 'Información general de la app.'),
          _SettingTile(title: 'Versión', subtitle: 'v1.0.0', icon: Icons.info_outline, onTap: () {}),
          _SettingTile(title: 'Acerca de', subtitle: 'Información y soporte', icon: Icons.help_outline, onTap: () {}),
        ],
      ),
    );
  }
}

class _EmptyScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyScreen({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, size: 42, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _MaintenanceTimelineCard extends StatelessWidget {
  final Mantenimiento mantenimiento;

  const _MaintenanceTimelineCard({required this.mantenimiento});

  @override
  Widget build(BuildContext context) {
    final statusLabel = mantenimiento.completado ? 'Completado' : 'Pendiente';
    final statusColor = mantenimiento.completado ? AppTheme.successColor : AppTheme.warningColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(mantenimiento.completado ? Icons.check_circle_outline : Icons.schedule_outlined, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(mantenimiento.tipo, style: Theme.of(context).textTheme.titleMedium)),
                      _StatusChip(icon: mantenimiento.completado ? Icons.check_circle_outline : Icons.schedule_outlined, label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(mantenimiento.descripcion, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(icon: Icons.event_outlined, label: MaterialLocalizations.of(context).formatMediumDate(mantenimiento.fecha)),
                      _InfoPill(icon: Icons.speed_outlined, label: '${mantenimiento.kilometraje} km'),
                      _InfoPill(icon: Icons.payments_outlined, label: '\$${mantenimiento.costo.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotoInfoGrid extends StatelessWidget {
  final Moto moto;

  const _MotoInfoGrid({required this.moto});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoTileData>[
      _InfoTileData(label: 'Año', value: moto.ano.toString(), icon: Icons.calendar_today_outlined),
      _InfoTileData(label: 'Kilometraje', value: '${moto.kilometraje} km', icon: Icons.speed_outlined),
      _InfoTileData(label: 'Color', value: moto.color?.isNotEmpty == true ? moto.color! : 'No registrado', icon: Icons.palette_outlined),
      _InfoTileData(label: 'Motor', value: moto.motor?.isNotEmpty == true ? moto.motor! : 'No registrado', icon: Icons.settings_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 2 ? 2.4 : 3.4,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: AppTheme.lightColorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                          const SizedBox(height: 2),
                          Text(item.value, style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Documento documento;

  const _DocumentCard({required this.documento});

  @override
  Widget build(BuildContext context) {
    final statusColor = documento.vencido
        ? AppTheme.errorColor
        : documento.proximoAVencer
            ? AppTheme.warningColor
            : AppTheme.successColor;
    final statusIcon = documento.vencido
        ? Icons.error_outline
        : documento.proximoAVencer
            ? Icons.warning_amber_outlined
            : Icons.verified_outlined;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(documento.tipo, style: Theme.of(context).textTheme.titleMedium)),
                _StatusChip(icon: statusIcon, label: documento.estadoTexto, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text('Expedición: ${MaterialLocalizations.of(context).formatMediumDate(documento.fechaExpedicion)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Vence: ${MaterialLocalizations.of(context).formatMediumDate(documento.fechaVencimiento)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Recordatorio recordatorio;

  const _ReminderCard({required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    final statusColor = recordatorio.vencido
        ? AppTheme.errorColor
        : recordatorio.esUrgente
            ? AppTheme.warningColor
            : AppTheme.successColor;
    final statusIcon = recordatorio.vencido
        ? Icons.error_outline
        : recordatorio.esUrgente
            ? Icons.priority_high_outlined
            : Icons.check_circle_outline;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(recordatorio.titulo, style: Theme.of(context).textTheme.titleMedium)),
                _StatusChip(icon: statusIcon, label: recordatorio.estadoTexto, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(recordatorio.descripcion, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            _InfoPill(icon: Icons.event_outlined, label: 'Vence: ${MaterialLocalizations.of(context).formatMediumDate(recordatorio.fechaVencimiento)}'),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightColorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingTile({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InfoTileData {
  final String label;
  final String value;
  final IconData icon;

  _InfoTileData({required this.label, required this.value, required this.icon});
}
