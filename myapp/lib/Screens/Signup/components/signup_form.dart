import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/auth/api_service.dart';
import 'package:myapp/dto/sign_up_model.dart';
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
            title: const Text("Success"),
            content: const Text("Registered successfully. Please log in."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("OK"),
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
          _errorMessage = "Technical Error, Contact Administrator.";
        });
      } catch (e) {
        String errorMsg = "Registration failed. Please try again.";
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
            _errorMessage = "Technical Error, Contact Administrator.";
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
            decoration: const InputDecoration(
              hintText: "Full Name",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
            validator: (value) => value!.isEmpty ? "Please enter your name" : null,
          ),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "Username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.account_circle),
              ),
            ),
            validator: (value) => value!.isEmpty ? "Please enter username" : null,
          ),
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter email";
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                  .hasMatch(value)) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),
          TextFormField(
            controller: _mobileController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Mobile",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.phone),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter mobile";
              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return "Mobile number must be exactly 10 digits";
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
              decoration: const InputDecoration(
                hintText: "Password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
              validator: (value) =>
              value!.isEmpty ? "Please enter password" : null,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _submitForm,
            child: Text("Sign Up".toUpperCase()),
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