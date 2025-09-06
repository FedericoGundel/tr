import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Login form widget containing username and password input fields
/// with simple non-empty validation and submission
class LoginFormWidget extends StatefulWidget {
  // Callback con username y password
  final void Function(String username, String password) onLoginPressed;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLoginPressed,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid =
        _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'El nombre de usuario es requerido';
    // Sin validación de formato ni límite de caracteres
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    // Sin longitud mínima
    return null;
  }

  void _handleSubmit() {
    if (widget.isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLoginPressed(
        _usernameController.text, // sin trim para permitir espacios si tu backend los usa
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'Ingresa tu nombre de usuario',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person', // icono de usuario
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              errorMaxLines: 2,
            ),
            validator: _validateUsername,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),

          SizedBox(height: 2.h),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Contrasweña',
              hintText: 'Ingresa tu contrasweña',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: widget.isLoading
                    ? null
                    : () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                tooltip: _isPasswordVisible ? 'Ocultar' : 'Mostrar',
              ),
              errorMaxLines: 2,
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleSubmit(),
          ),

          SizedBox(height: 1.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password feature coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Olvidaste tu contraseña?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: (_isFormValid && !widget.isLoading) ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                foregroundColor: _isFormValid
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                elevation: _isFormValid ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
                  : Text(
                'Iniciar sesión',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
