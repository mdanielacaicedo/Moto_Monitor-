import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(const MotoMonitorApp());
}

class MotoMonitorApp extends StatelessWidget {
  const MotoMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Moto Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppProvider>().initializeApp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading && !appProvider.isInitialized) {
          return _buildLoadingScreen();
        }

        if (appProvider.errorMessage != null && !appProvider.isAuthenticated) {
          return _buildErrorScreen(appProvider);
        }

        if (appProvider.isAuthenticated && appProvider.isInitialized) {
          return const MainScreen();
        }

        if (appProvider.isInitialized && !appProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return _buildInitializingScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Moto Monitor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Inicializando...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(AppProvider appProvider) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Error de Inicialización',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => appProvider.clearError(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: const Text('Continuar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => appProvider.initializeApp(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitializingScreen() {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 24),
            Text(
              'Preparando la aplicación...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoginMode = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = context.read<AppProvider>();

    if (_isLoginMode) {
      await appProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await appProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    const Icon(
                      Icons.motorcycle,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Moto Monitor',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoginMode
                          ? 'Ingresa a tu cuenta'
                          : 'Crea tu cuenta nueva',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_isLoginMode && (value == null || value.trim().isEmpty)) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El email es requerido';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono (opcional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        if (!_isLoginMode && value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    if (!_isLoginMode) ...[
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_isLoginMode && value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (appProvider.authError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appProvider.authError!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    ElevatedButton(
                      onPressed: appProvider.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: appProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        _isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: appProvider.isLoading ? null : () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          context.read<AppProvider>().clearError();
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey.shade600),
                          children: [
                            TextSpan(
                                text: _isLoginMode
                                    ? '¿No tienes cuenta? '
                                    : '¿Ya tienes cuenta? '
                            ),
                            TextSpan(
                              text: _isLoginMode ? 'Regístrate' : 'Inicia sesión',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Mantenimiento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Mi Moto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Documentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Recordatorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto Monitor'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón refresh
          Consumer<AppProvider>(
            builder: (context, appProvider, _) {
              return IconButton(
                icon: appProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.refresh),
                onPressed: appProvider.isLoading
                    ? null
                    : () => appProvider.refreshData(),
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
                  color: Colors.black12,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                            SizedBox(height: 16),
                            Text('Actualizando datos...'),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.motorcycle_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay motos registradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Configura tu moto para comenzar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotoCard(appProvider.moto!),
          const SizedBox(height: 16),
          _buildAlertasSection(appProvider),
          const SizedBox(height: 16),
          _buildMantenimientoSection(appProvider),
          const SizedBox(height: 16),
          _buildAccesosRapidos(context, appProvider),
        ],
      ),
    );
  }

  Widget _buildMotoCard(dynamic moto) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.motorcycle, size: 50, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${moto.marca} ${moto.modelo}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Año: ${moto.ano}'),
                  Text('Kilometraje: ${_formatNumber(moto.kilometraje)} km'),
                  Text('Placa: ${moto.placa}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Widget _buildAlertasSection(AppProvider appProvider) {
    final alertas = <Widget>[];

    if (appProvider.totalAlertas > 0) {
      alertas.add(_buildAlertaCard(
        'Tienes ${appProvider.totalAlertas} alerta(s)',
        'Revisa documentos y mantenimiento',
        Colors.orange,
        Icons.warning,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas Importantes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (alertas.isEmpty)
          const Card(
            color: Colors.green,
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.white),
              title: Text(
                'Todo al día',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'No hay alertas pendientes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        else
          ...alertas,
      ],
    );
  }

  Widget _buildAlertaCard(String titulo, String subtitulo, Color color, IconData icono) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icono, color: color),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
      ),
    );
  }

  Widget _buildMantenimientoSection(AppProvider appProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.build, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Mantenimiento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Próximo mantenimiento programado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 8),
            const Text(
              'Faltan 1,200 km aproximadamente',
              style: TextStyle(color: Colors.grey),
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
        const Text(
          'Accesos Rápidos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildAccesoRapido(
                'Registrar\nMantenimiento',
                Icons.add_circle,
                Colors.green,
                    () => _showMantenimientoDialog(context, appProvider),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAccesoRapido(
                'Ver\nDocumentos',
                Icons.description,
                Colors.blue,
                    () => _navigateToDocuments(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAccesoRapido(
                'Actualizar\nKilometraje',
                Icons.speed,
                Colors.purple,
                    () => _showKilometrajeDialog(context, appProvider),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccesoRapido(String texto, IconData icono, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icono, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
          title: const Text('Actualizar Kilometraje'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kilometraje actual: ${_formatNumber(currentKm)} km'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nuevo kilometraje',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
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
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
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
          title: const Text('Registrar Mantenimiento'),
          content: const Text('Funcionalidad en desarrollo...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
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
      appBar: AppBar(
        title: const Text('Mantenimiento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Mantenimiento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Historial y registro de servicios'),
          ],
        ),
      ),
    );
  }
}

class MiMotoScreen extends StatelessWidget {
  const MiMotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Moto'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Mi Moto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Perfil y datos de tu motocicleta'),
          ],
        ),
      ),
    );
  }
}

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Documentos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('SOAT, revisión técnica, matrícula'),
          ],
        ),
      ),
    );
  }
}

class RecordatoriosScreen extends StatelessWidget {
  const RecordatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Recordatorios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Alertas y próximos vencimientos'),
          ],
        ),
      ),
    );
  }
}

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Configuración',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Ajustes de la aplicación'),
          ],
        ),
      ),
    );
  }
}