import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/l10n/app_localizations.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AlreadyHaveAnAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? AppLocalizations.of(context)!.dontHaveAccount : AppLocalizations.of(context)!.alreadyHaveAccount,
          style: const TextStyle(color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: press as void Function()?,
          child: Text(
            login ? AppLocalizations.of(context)!.signUp : AppLocalizations.of(context)!.signIn,
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
