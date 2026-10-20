import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/moto.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';

class AddMotoScreen extends StatefulWidget {
  final Moto? moto;

  const AddMotoScreen({super.key, this.moto});

  @override
  State<AddMotoScreen> createState() => _AddMotoScreenState();
}

class _AddMotoScreenState extends State<AddMotoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _anoController;
  late final TextEditingController _placaController;
  late final TextEditingController _kilometrajeController;
  late final TextEditingController _colorController;
  late final TextEditingController _motorController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final moto = widget.moto;
    _marcaController = TextEditingController(text: moto?.marca ?? '');
    _modeloController = TextEditingController(text: moto?.modelo ?? '');
    _anoController = TextEditingController(text: moto?.ano.toString() ?? '');
    _placaController = TextEditingController(text: moto?.placa ?? '');
    _kilometrajeController = TextEditingController(text: moto?.kilometraje.toString() ?? '0');
    _colorController = TextEditingController(text: moto?.color ?? '');
    _motorController = TextEditingController(text: moto?.motor ?? '');
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _placaController.dispose();
    _kilometrajeController.dispose();
    _colorController.dispose();
    _motorController.dispose();
    super.dispose();
  }

  Future<void> _guardarMoto(BuildContext context, AppProvider appProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = appProvider.currentUserId;
      if (userId == null) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo guardar la moto porque la sesión no está activa.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      final nuevaMoto = Moto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: int.parse(_anoController.text),
        placa: _placaController.text.trim(),
        kilometraje: int.parse(_kilometrajeController.text),
        fechaCompra: DateTime.now(),
        fechaUltimaActualizacion: DateTime.now(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        motor: _motorController.text.trim().isEmpty ? null : _motorController.text.trim(),
        observaciones: null,
      );

      await appProvider.addMoto(nuevaMoto);

      if (!mounted) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.moto == null
              ? 'Moto guardada correctamente.'
              : 'La información de la moto se actualizó correctamente.'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo guardar la moto. Verifica los datos e inténtalo de nuevo.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.moto == null ? 'Registrar motocicleta' : 'Editar motocicleta'),
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            color: AppTheme.lightColorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.two_wheeler,
                                      size: 28,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.moto == null ? 'Información básica' : 'Editar información',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          widget.moto == null
                                              ? 'Completa los datos reales de tu motocicleta.'
                                              : 'Actualiza los datos de tu motocicleta con la información correcta.',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _marcaController,
                            decoration: const InputDecoration(
                              labelText: 'Marca *',
                              hintText: 'Ej: Yamaha, Honda, Suzuki',
                              prefixIcon: Icon(Icons.two_wheeler_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe la marca de tu moto.';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _modeloController,
                            decoration: const InputDecoration(
                              labelText: 'Modelo *',
                              hintText: 'Ej: MT-03, CB500X',
                              prefixIcon: Icon(Icons.build_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe el modelo de tu moto.';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _anoController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Año *',
                                    hintText: '2024',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Escribe el año de tu moto.';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'El año debe ser un número.';
                                    }
                                    final ano = int.parse(value);
                                    if (ano < 1900 || ano > DateTime.now().year + 1) {
                                      return 'Escribe un año válido.';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _placaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Placa *',
                                    hintText: 'ABC123',
                                    prefixIcon: Icon(Icons.confirmation_num_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Escribe la placa de tu moto.';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _kilometrajeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Kilometraje actual (km) *',
                              hintText: '0',
                              prefixIcon: Icon(Icons.speed_outlined),
                              suffixText: 'km',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe el kilometraje actual.';
                              }
                              if (int.tryParse(value) == null) {
                                return 'El kilometraje debe ser un número.';
                              }
                              final km = int.parse(value);
                              if (km < 0) {
                                return 'El kilometraje no puede ser negativo.';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 28),

                          Text(
                            'Información adicional (opcional)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _colorController,
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              hintText: 'Ej: Rojo, Azul, Negro',
                              prefixIcon: Icon(Icons.palette_outlined),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _motorController,
                            decoration: const InputDecoration(
                              labelText: 'Motor (cilindrada)',
                              hintText: 'Ej: 321cc, 500cc',
                              prefixIcon: Icon(Icons.settings_outlined),
                            ),
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting || appProvider.isLoading
                                  ? null
                                  : () => _guardarMoto(context, appProvider),
                              icon: _isSubmitting || appProvider.isLoading
                                  ? null
                                  : const Icon(Icons.check),
                              label: _isSubmitting || appProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryColor),
                                      ),
                                    )
                                  : Text(widget.moto == null ? 'Registrar motocicleta' : 'Guardar cambios'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Los campos con * son obligatorios.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


