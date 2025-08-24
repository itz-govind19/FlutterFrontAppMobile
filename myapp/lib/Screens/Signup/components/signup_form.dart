import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/auth/api_service.dart';
import 'package:myapp/dto/sign_up_model.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/utils/string_utils.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final signupData = SignUpRequest(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
      );

      try {
        final response = await ApiService.register(signupData);
        print("✅ Registration success: $response");

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.signupSuccessTitle),
            content: Text(AppLocalizations.of(context)!.signupSuccessMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.ok.toUpperCase()),
              ),
            ],
          ),
        );
      } on SocketException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } on http.ClientException catch (_) {
        setState(() {
          _errorMessage = StringUtils.capitalize(AppLocalizations.of(context)!.technicalError.toLowerCase());
        });
      } catch (e) {
        String errorMsg = AppLocalizations.of(context)!.registrationFailed;
        try {
          final errorString = e.toString();
          final jsonStart = errorString.indexOf('{');
          if (jsonStart != -1) {
            final jsonPart = errorString.substring(jsonStart);
            final decoded = jsonDecode(jsonPart);
            errorMsg = decoded["message"];
            setState(() {
              _errorMessage = errorMsg;
            });
          }
        } catch (_) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.technicalError;
          });
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.name,
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
            validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.enterEmail : null,
          ),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.username,
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.account_circle),
              ),
            ),
            validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.enterUsername : null,
          ),
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.email,
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterEmail;
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                  .hasMatch(value)) {
                return AppLocalizations.of(context)!.invalidEmail;
              }
              return null;
            },
          ),
          TextFormField(
            controller: _mobileController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.mobile,
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.phone),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.enterMobile;
              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return AppLocalizations.of(context)!.invalidMobile;
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.password,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
              validator: (value) =>
              value!.isEmpty ? AppLocalizations.of(context)!.enterPassword : null,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _submitForm,
            child: Text(AppLocalizations.of(context)!.signUp.toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}