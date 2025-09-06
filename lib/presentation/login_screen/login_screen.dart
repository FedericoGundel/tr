import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/app_logo_widget.dart';
import './widgets/error_message_widget.dart';
import './widgets/login_form_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:device_info_plus/device_info_plus.dart';

/// Pantalla de inicio de sesión para la aplicación SecureAuth Dashboard
/// Proporciona autenticación segura con manejo de token JWT
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (isLoggedIn && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard-screen',
        (route) => false,
      );
    }
  }

/*
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // identificador único
  }
*/
  /// Maneja el inicio de sesión
  Future<void> _handleLogin(String username, String password) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(
          'https://transportes.factura-plataformakitdigital.com/api/apk.php');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        },
        body: {
          'user': username,
          'password': password,
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200) {
        final hasUser = data is Map && data['user'] is Map<String, dynamic>;
        if (hasUser) {
          final user = data['user'] as Map<String, dynamic>;

          final prefs = await SharedPreferences.getInstance();
/*
// 📲 Obtener número o ID del dispositivo
          final deviceId = await _getDeviceId(); // o el número de teléfono real

// Número guardado en la base
          final nroTelefono = user['NroTelefono']?.toString() ?? "";

// Validar
          if (nroTelefono != deviceId) {
            setState(() {
              _errorMessage = "El dispositivo no coincide con el registrado.";
            });
            return; // cortar login
*/
          final idConductor = int.tryParse(user['idRegistro'].toString());
          if (idConductor != null) {
            await prefs.setBool("isLoggedIn", true);
            await prefs.setInt("idConductor", idConductor);
            debugPrint("Guardado idConductor: $idConductor");
          } else {
            debugPrint(
                "⚠️ idRegistro no es un número válido: ${user['idRegistro']}");
          }

          HapticFeedback.lightImpact();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard-screen',
              (route) => false,
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Respuesta desconocida del servidor.';
          });
        }
      } else if (response.statusCode == 401) {
        final apiMsg = (data is Map && data['error'] is String)
            ? data['error'] as String
            : 'Usuario o contraseña incorrectos';
        setState(() {
          _errorMessage = apiMsg;
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de red: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _storeAuthToken() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),

                    // Logo
                    const AppLogoWidget(),

                    SizedBox(height: 2.h),

                    // Texto de bienvenida
                    Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),

                    Text(
                      'Iniciá sesión para acceder al panel',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Mensaje de error
                    ErrorMessageWidget(
                      errorMessage: _errorMessage,
                      onDismiss: _dismissError,
                    ),

                    // Formulario de login
                    LoginFormWidget(
                      onLoginPressed: (String user, String password) =>
                          _handleLogin(user, password),
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 6.h),

                    // Footer
                    Text(
                      '© 2025 Desarrollado por Empireystems. Todos los derechos reservados.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
