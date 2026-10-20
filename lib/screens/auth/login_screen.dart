import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoginMode = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
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

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      context.read<AppProvider>().clearError();
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 560),
                                  child: Column(
                                    children: [
                                      Semantics(
                                        label: 'Logo de Moto Monitor',
                                        child: Container(
                                          width: 88,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.18),
                                                blurRadius: 24,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.two_wheeler,
                                            size: 48,
                                            color: AppTheme.onPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Moto Monitor',
                                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                              color: AppTheme.primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isLoginMode
                                            ? 'Gestiona tu motocicleta de forma clara, segura y accesible.'
                                            : 'Crea tu cuenta para comenzar a registrar tu moto.',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 560),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            _isLoginMode ? 'Inicia sesión' : 'Crea tu cuenta',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isLoginMode
                                                ? 'Ingresa con tu correo y contraseña.'
                                                : 'Completa los datos para registrarte.',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 24),

                                          if (!_isLoginMode) ...[
                                            TextFormField(
                                              controller: _nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Nombre completo',
                                                hintText: 'Juan Pérez',
                                                prefixIcon: Icon(Icons.person_outline),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.trim().isEmpty) {
                                                  return 'Escribe tu nombre completo.';
                                                }
                                                return null;
                                              },
                                              textInputAction: TextInputAction.next,
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          TextFormField(
                                            controller: _emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              labelText: 'Correo electrónico',
                                              hintText: 'tu@email.com',
                                              prefixIcon: Icon(Icons.email_outlined),
                                            ),
                                            validator: (value) {
                                              final text = value?.trim() ?? '';
                                              if (text.isEmpty) {
                                                return 'Escribe tu correo electrónico.';
                                              }
                                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text)) {
                                                return 'Escribe un correo válido, por ejemplo nombre@correo.com.';
                                              }
                                              return null;
                                            },
                                            textInputAction: TextInputAction.next,
                                          ),
                                          const SizedBox(height: 16),

                                          if (!_isLoginMode) ...[
                                            TextFormField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              decoration: const InputDecoration(
                                                labelText: 'Teléfono (opcional)',
                                                hintText: '+57 300 123 4567',
                                                prefixIcon: Icon(Icons.phone_outlined),
                                              ),
                                              textInputAction: TextInputAction.next,
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                              labelText: 'Contraseña',
                                              hintText: '••••••••',
                                              prefixIcon: const Icon(Icons.lock_outline),
                                              suffixIcon: Tooltip(
                                                message: _obscurePassword
                                                    ? 'Mostrar contraseña'
                                                    : 'Ocultar contraseña',
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons.visibility_off_outlined
                                                        : Icons.visibility_outlined,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              final text = value ?? '';
                                              if (text.isEmpty) {
                                                return 'Escribe tu contraseña.';
                                              }
                                              if (!_isLoginMode && text.length < 8) {
                                                return 'La contraseña debe tener al menos 8 caracteres.';
                                              }
                                              return null;
                                            },
                                            textInputAction: !_isLoginMode
                                                ? TextInputAction.next
                                                : TextInputAction.done,
                                          ),
                                          const SizedBox(height: 16),

                                          if (!_isLoginMode) ...[
                                            TextFormField(
                                              controller: _confirmPasswordController,
                                              obscureText: _obscurePassword,
                                              decoration: const InputDecoration(
                                                labelText: 'Confirmar contraseña',
                                                hintText: '••••••••',
                                                prefixIcon: Icon(Icons.lock_outline),
                                              ),
                                              validator: (value) {
                                                if ((value ?? '').isEmpty) {
                                                  return 'Confirma tu contraseña.';
                                                }
                                                if (value != _passwordController.text) {
                                                  return 'Las dos contraseñas deben ser iguales.';
                                                }
                                                return null;
                                              },
                                              textInputAction: TextInputAction.done,
                                            ),
                                            const SizedBox(height: 24),
                                          ],

                                          if (appProvider.authError != null) ...[
                                            Container(
                                              padding: const EdgeInsets.all(14),
                                              margin: const EdgeInsets.only(bottom: 20),
                                              decoration: BoxDecoration(
                                                color: AppTheme.errorColor.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppTheme.errorColor.withValues(alpha: 0.28),
                                                  width: 1.25,
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.error_outline,
                                                    color: AppTheme.errorColor,
                                                    size: 22,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _friendlyAuthError(appProvider.authError!),
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                            color: AppTheme.errorColor,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: appProvider.isLoading ? null : _handleSubmit,
                                              child: appProvider.isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryColor),
                                                      ),
                                                    )
                                                  : Text(_isLoginMode ? 'Iniciar sesión' : 'Crear cuenta'),
                                            ),
                                          ),
                                          const SizedBox(height: 18),

                                          Center(
                                            child: TextButton(
                                              onPressed: appProvider.isLoading ? null : _toggleMode,
                                              child: Text(
                                                _isLoginMode ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _friendlyAuthError(String rawMessage) {
    final message = rawMessage.toLowerCase();
    if (message.contains('email o contraseña incorrectos')) {
      return 'El correo o la contraseña no son correctos. Revisa los datos e intenta de nuevo.';
    }
    if (message.contains('email inválido')) {
      return 'Escribe un correo electrónico válido.';
    }
    if (message.contains('contraseña')) {
      return 'Revisa la contraseña e inténtalo nuevamente.';
    }
    return rawMessage.replaceFirst(RegExp(r'^Error en el login:\s*', caseSensitive: false), 'No se pudo iniciar sesión: ');
  }
}
