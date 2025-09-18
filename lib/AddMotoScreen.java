// lib/screens/add_moto_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/moto.dart';
import '../providers/app_provider.dart';

class AddMotoScreen extends StatefulWidget {
  final bool isFirstMoto;

  AddMotoScreen({this.isFirstMoto = false});

  @override
  _AddMotoScreenState createState() => _AddMotoScreenState();
}

class _AddMotoScreenState extends State<AddMotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _colorController = TextEditingController();
  final _cilindrajeController = TextEditingController();
  final _kilometrajeController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  Color _statusColor = Colors.blue;

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _colorController.dispose();
    _cilindrajeController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  void _showStatus(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });
    
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = '';
        });
      }
    });
  }

  Future<void> _consultRunt() async {
    if (_placaController.text.trim().isEmpty) {
      _showStatus('Ingresa una placa para consultar', Colors.orange);
      return;
    }

    // Simular consulta RUNT con datos de prueba
    await Future.delayed(Duration(seconds: 2));
    
    final placa = _placaController.text.trim().toUpperCase();
    
    if (placa.contains('ABC123')) {
      // Datos de prueba exitosos
      _marcaController.text = 'Honda';
      _modeloController.text = 'CB 190R';
      _anoController.text = '2023';
      _colorController.text = 'Rojo';
      _cilindrajeController.text = '184';
      _showStatus('Datos obtenidos exitosamente (simulados)', Colors.green);
    } else {
      _showStatus('Vehículo no encontrado. Completa manualmente.', Colors.orange);
    }
  }

  Future<void> _saveMoto() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final moto = Moto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        placa: _placaController.text.trim().toUpperCase(),
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: int.tryParse(_anoController.text) ?? DateTime.now().year,
        kilometraje: int.tryParse(_kilometrajeController.text) ?? 0,
        fechaCompra: DateTime.now(),
        fechaUltimaActualizacion: DateTime.now(),
      );

      await context.read<AppProvider>().addMoto(moto);
      
      _showStatus('Moto guardada exitosamente', Colors.green);
      
      await Future.delayed(Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _showStatus('Error guardando moto: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFirstMoto ? 'Agrega tu primera moto' : 'Agregar moto'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mensaje de bienvenida
              if (widget.isFirstMoto) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Configura tu primera moto para comenzar a usar Moto Monitor',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],

              // Consulta RUNT
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Consulta RUNT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ingresa la placa para obtener datos automáticamente (prueba con "ABC123")',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _placaController,
                              decoration: InputDecoration(
                                labelText: 'Placa',
                                hintText: 'ABC123',
                                prefixIcon: Icon(Icons.pin),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La placa es requerida';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _consultRunt,
                            icon: Icon(Icons.search),
                            label: Text('Consultar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_statusMessage.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _statusColor == Colors.green ? Icons.check_circle :
                                _statusColor == Colors.red ? Icons.error :
                                Icons.info,
                                color: _statusColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusMessage,
                                  style: TextStyle(color: _statusColor.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Formulario básico
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.motorcycle, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Datos de la motocicleta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Marca y Modelo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _marcaController,
                              decoration: InputDecoration(
                                labelText: 'Marca',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La marca es requerida';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modeloController,
                              decoration: InputDecoration(
                                labelText: 'Modelo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El modelo es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Año y Color
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _anoController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Año',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El año es requerido';
                                }
                                final ano = int.tryParse(value);
                                if (ano == null || ano < 1980 || ano > DateTime.now().year + 1) {
                                  return 'Año inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: InputDecoration(
                                labelText: 'Color',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El color es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Cilindraje y Kilometraje
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cilindrajeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cilindraje (cc)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _kilometrajeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Kilometraje actual',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final km = int.tryParse(value);
                                  if (km == null || km < 0) {
                                    return 'Kilometraje inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Guardando...'),
                        ],
                      )
                    : Text(
                        'Guardar Motocicleta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}