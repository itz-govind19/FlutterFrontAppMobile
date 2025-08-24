import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
// import 'package:myapp/generated/app_localizations.dart';
import 'package:myapp/provider/language_provider.dart';
import 'package:provider/provider.dart';

import '../../components/background.dart';
import '../../responsive.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Responsive(
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: WelcomeImage(),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 450,
                              child: LoginAndSignupBtn(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  mobile: MobileWelcomeScreen(),
                ),
              ),
            ),
          ),

          // Language Dropdown in top-left corner
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<Locale>(
                      value: languageProvider.locale,
                      icon: const Icon(Icons.language, color: Colors.purple),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          languageProvider.setLocale(newLocale);
                        }
                      },
                      items: LanguageProvider.supportedLocales.map((Locale locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languageProvider.getLanguageName(locale.languageCode),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Localized Welcome Text (Centered on all screens)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.welcomeMessage,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
