import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:myapp/Screens/Admin/admin_home.dart';
import 'package:myapp/Screens/User/user_home.dart';
import 'package:myapp/Screens/Welcome/welcome_screen.dart';
import 'package:myapp/Screens/guest/guest_home.dart';
import 'package:myapp/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/security/token_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding initialized before async calls

  String? token = await TokenManager.getToken();

  // If token exists, you can decode it and navigate accordingly
  Widget nextScreen;

  if (token != null) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String username = decodedToken["sub"];
    String role = decodedToken["roles"];

    if (role.contains("ADMIN")) {
      nextScreen = AdminHome(username: username);
    } else if (role.contains("USER")) {
      nextScreen = UserHome(username: username);
    } else {
      nextScreen = GuestHome();
    }
  } else {
    // No token found, show login screen
    nextScreen = WelcomeScreen();
  }

  await dotenv.load(fileName: ".env"); // Load environment variables first
  runApp(const MyApp()); // Then run the app
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
      home: const WelcomeScreen(),
    );
  }
}
