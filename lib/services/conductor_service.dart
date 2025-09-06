import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConductorService {
  static const String _apiUrl = "https://transportes.factura-plataformakitdigital.com/api/apk.php";

  /// Obtiene el idConductor guardado en SharedPreferences
  static Future<int?> getIdConductor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("idConductor");
  }

  /// Consulta pedidos del conductor actual
  static Future<Map<String, dynamic>?> getPedidosConductor() async {
    final idConductor = await getIdConductor();
    if (idConductor == null) return null;

    final response = await http.post(
      Uri.parse(_apiUrl),
      body: {
        "idConductor": idConductor.toString(),
      },
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    } else {
      return null;
    }
  }
}
