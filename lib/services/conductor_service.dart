import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ConductorService {
  static const String _apiUrl = "https://transportes.factura-plataformakitdigital.com/api/apk.php";
  
  // Control de requests simultáneos
  static bool _isLoading = false;
  static Future<Map<String, dynamic>?>? _currentRequest;

  /// Obtiene el idConductor guardado en SharedPreferences
  static Future<int?> getIdConductor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("idConductor");
  }

  /// Consulta pedidos del conductor actual (SIN CACHE - siempre datos frescos)
  static Future<Map<String, dynamic>?> getPedidosConductor({bool forceRefresh = false}) async {
    final idConductor = await getIdConductor();
    if (idConductor == null) {
      debugPrint('ConductorService: No hay idConductor guardado');
      return null;
    }

    // Si ya hay una request en curso, esperar a que termine
    if (_isLoading && _currentRequest != null) {
      debugPrint('ConductorService: Request en curso, esperando...');
      return await _currentRequest;
    }

    // Crear nueva request
    _currentRequest = _fetchConductorData(idConductor);
    _isLoading = true;

    try {
      final result = await _currentRequest!;
      return result;
    } finally {
      _isLoading = false;
      _currentRequest = null;
    }
  }

  /// Método privado para hacer la llamada real a la API
  static Future<Map<String, dynamic>?> _fetchConductorData(int idConductor) async {
    try {
      debugPrint('ConductorService: Obteniendo datos frescos para conductor $idConductor');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          "idConductor": idConductor.toString(),
        },
      ).timeout(
        const Duration(seconds: 30), // Timeout de 30 segundos
        onTimeout: () {
          throw Exception('Timeout: La solicitud tardó demasiado');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('ConductorService: Datos obtenidos exitosamente');
          return data;
        } catch (e) {
          debugPrint('ConductorService: Error al decodificar JSON: $e');
          return null;
        }
      } else {
        debugPrint('ConductorService: Error HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('ConductorService: Error en la request: $e');
      return null;
    }
  }

  /// Obtener datos de un conductor específico (para perfil)
  static Future<Map<String, dynamic>?> getConductorData(int idConductor) async {
    try {
      debugPrint('ConductorService: Obteniendo datos del conductor $idConductor');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          "idConductor": idConductor.toString(),
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout: La solicitud tardó demasiado');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        debugPrint('ConductorService: Error HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('ConductorService: Error al obtener datos del conductor: $e');
      return null;
    }
  }

  /// Verificar si hay una request en curso
  static bool get isRequestInProgress => _isLoading;
}
