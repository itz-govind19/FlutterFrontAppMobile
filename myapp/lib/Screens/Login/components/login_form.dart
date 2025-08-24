import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:myapp/Screens/Admin/admin_home.dart';
import 'package:myapp/Screens/User/user_home.dart';
import 'package:myapp/Screens/guest/guest_home.dart';
import 'package:myapp/auth/api_service.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/security/token_manager.dart';
import 'package:myapp/utils/string_utils.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      String? token = response["token"];
      if (token == null) {
        setState(() {
          _errorMessage = response["message"];
        });
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      await TokenManager.saveToken(token);

      String username = decodedToken["sub"]; // username claim
      String role = decodedToken["roles"]; // e.g., "ADMIN", "USER", "GUEST"

      Widget nextScreen;

      if (role.contains("ADMIN")) {
        // ✅ Admin has full access
        nextScreen = AdminHome(username: username);
      } else if (role.contains("USER")) {
        // ✅ User has restricted SideNav (only Payment + Booking history)
        nextScreen = UserHome(username: username);
      } else {
        // ✅ Default to Guest (BottomNavigation only)
        nextScreen = GuestHome();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } on SocketException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } on http.ClientException catch (e) {
      setState(() {
        _errorMessage = StringUtils.capitalize(AppLocalizations.of(context)!.technicalError.toLowerCase());
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: StringUtils.capitalize(AppLocalizations.of(context)!.username.toLowerCase())),
            validator: (value) => value!.isEmpty ? StringUtils.capitalize(AppLocalizations.of(context)!.enterUsername.toLowerCase()) : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: StringUtils.capitalize(AppLocalizations.of(context)!.password.toLowerCase())),
            obscureText: true,
            validator: (value) => value!.isEmpty ? StringUtils.capitalize(AppLocalizations.of(context)!.enterPassword.toLowerCase()) : null,
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(StringUtils.capitalize(AppLocalizations.of(context)!.login.toLowerCase())),
          ),
        ],
      ),
    );
  }
}
