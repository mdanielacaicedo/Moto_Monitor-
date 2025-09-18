import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/moto.dart';

class RuntApiService {
  static final RuntApiService _instance = RuntApiService._internal();
  factory RuntApiService() => _instance;
  RuntApiService._internal();

  static const String _baseUrl = 'https://api.apitude.co/runt-vehicle-co/v1';
  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Future<VehicleApiResult> getVehicleByPlate(String plate) async {
    try {
      if (_apiKey == null) {
        return VehicleApiResult(
            success: false,
            message: 'API Key no configurada'
        );
      }

      if (plate.trim().isEmpty) {
        return VehicleApiResult(
            success: false,
            message: 'La placa es requerida'
        );
      }

      final cleanPlate = plate.trim().toUpperCase();

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final url = Uri.parse('$_baseUrl/vehicle/$cleanPlate');

      print('Consultando vehículo: $cleanPlate');

      try {
        final response = await http.get(url, headers: headers)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);

          if (jsonData['success'] == true && jsonData['data'] != null) {
            final vehicleData = jsonData['data'];
            final moto = _createMotoFromApiData(vehicleData, cleanPlate);

            return VehicleApiResult(
              success: true,
              message: 'Vehículo encontrado',
              moto: moto,
              rawData: vehicleData,
            );
          }
        }
      } catch (e) {
        print('API real no disponible, usando datos simulados');
      }

      return await MockRuntService().getVehicleByPlate(cleanPlate);

    } catch (e) {
      return VehicleApiResult(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  Moto _createMotoFromApiData(Map<String, dynamic> apiData, String plate) {
    try {
      return Moto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        placa: plate,
        marca: _parseString(apiData['brand'], 'Desconocida'),
        modelo: _parseString(apiData['model'], 'Desconocido'),
        ano: _parseInt(apiData['year'], DateTime.now().year),
        kilometraje: _parseInt(apiData['mileage'], 0),
        fechaCompra: _parseDateTime(apiData['purchase_date']) ?? DateTime.now(),
        fechaUltimaActualizacion: DateTime.now(),
      );
    } catch (e) {
      print('Error creando Moto desde API data: $e');

      return Moto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        placa: plate,
        marca: 'Consulta API',
        modelo: 'Por completar',
        ano: DateTime.now().year,
        kilometraje: 0,
        fechaCompra: DateTime.now(),
        fechaUltimaActualizacion: DateTime.now(),
      );
    }
  }

  Future<bool> isServiceAvailable() async {
    try {
      if (_apiKey == null) return false;

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String _parseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class VehicleApiResult {
  final bool success;
  final String message;
  final Moto? moto;
  final Map<String, dynamic>? rawData;

  VehicleApiResult({
    required this.success,
    required this.message,
    this.moto,
    this.rawData,
  });

  @override
  String toString() {
    return 'VehicleApiResult{success: $success, message: $message, moto: ${moto?.placa}}';
  }
}

class MockRuntService {
  static final MockRuntService _instance = MockRuntService._internal();
  factory MockRuntService() => _instance;
  MockRuntService._internal();

  Future<VehicleApiResult> getVehicleByPlate(String plate) async {
    await Future.delayed(const Duration(seconds: 2));

    final cleanPlate = plate.trim().toUpperCase();

    if (cleanPlate.contains('ABC123')) {
      return VehicleApiResult(
        success: true,
        message: 'Vehículo encontrado (datos simulados)',
        moto: Moto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          placa: cleanPlate,
          marca: 'Honda',
          modelo: 'CB 190R',
          ano: 2023,
          kilometraje: 15000,
          fechaCompra: DateTime.now().subtract(const Duration(days: 365)),
          fechaUltimaActualizacion: DateTime.now(),
        ),
      );
    } else if (cleanPlate.contains('XYZ')) {
      return VehicleApiResult(
        success: false,
        message: 'Vehículo no encontrado en el RUNT',
      );
    } else {
      return VehicleApiResult(
        success: true,
        message: 'Vehículo encontrado (datos simulados)',
        moto: Moto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          placa: cleanPlate,
          marca: 'Yamaha',
          modelo: 'FZ 25',
          ano: 2022,
          kilometraje: 8500,
          fechaCompra: DateTime.now().subtract(const Duration(days: 500)),
          fechaUltimaActualizacion: DateTime.now(),
        ),
      );
    }
  }
}