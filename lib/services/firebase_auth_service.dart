import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common/alert.dart';
import '../common/custom_colors.dart';
import '../common/firebase_errors.dart';
import '../views/auth_page.dart';

class FirebaseAuthService {
  void userRegister(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      customAlert(
        context,
        "Todos os campos são obrigatórios",
        24.0,
        "",
        0,
        [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomColors.dark),
            child: const Text(
              "Ok!",
              style: TextStyle(color: CustomColors.light, fontSize: 16.0),
            ),
          )
        ],
      );
    } else if (passwordController.text == confirmPasswordController.text) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        print(e.code);
        String? alertString = FirebaseErrorsMessages.errors[e.code];
        if (alertString != null) {
          customAlert(
            context,
            alertString,
            24.0,
            "",
            0,
            [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.dark),
                child: const Text(
                  "Ok!",
                  style: TextStyle(color: CustomColors.light, fontSize: 16.0),
                ),
              )
            ],
          );
        }
      }
    } else {
      customAlert(
        context,
        "As senhas não conferem",
        24.0,
        "",
        0,
        [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomColors.dark),
            child: const Text(
              "Ok!",
              style: TextStyle(color: CustomColors.light, fontSize: 16.0),
            ),
          )
        ],
      );
    }
  }

  void userSignIn(BuildContext context, TextEditingController emailController,
      TextEditingController passwordController) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      customAlert(
        context,
        "Informe email e senha para entrar",
        24.0,
        "",
        0,
        [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomColors.dark),
            child: const Text(
              "Ok!",
              style: TextStyle(color: CustomColors.light, fontSize: 16.0),
            ),
          )
        ],
      );
    } else {
      try {
        // ignore: use_build_context_synchronously
        loadingAlert(context);
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        print(e.code);
        String? alertString = FirebaseErrorsMessages.errors[e.code];
        if (alertString != null) {
          customAlert(
            context,
            alertString,
            24.0,
            "",
            0,
            [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.dark),
                child: const Text(
                  "Ok!",
                  style: TextStyle(color: CustomColors.light, fontSize: 16.0),
                ),
              )
            ],
          );
        }
      }
    }
  }

  void sendForgetEmail(
      BuildContext context, TextEditingController emailController) async {
    if (emailController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);
        // ignore: use_build_context_synchronously
        customAlert(
          context,
          "Email de recuperação de senha enviado",
          24.0,
          "",
          0,
          [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: CustomColors.dark),
              child: const Text(
                "Ok!",
                style: TextStyle(color: CustomColors.light, fontSize: 16.0),
              ),
            )
          ],
        );
      } on FirebaseAuthException catch (e) {
        print(e.code);
        String? alertString = FirebaseErrorsMessages.errors[e.code];
        if (alertString != null) {
          customAlert(
            context,
            alertString,
            24.0,
            "",
            0,
            [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.dark),
                child: const Text(
                  "Ok!",
                  style: TextStyle(color: CustomColors.light, fontSize: 16.0),
                ),
              )
            ],
          );
        }
      }
    } else {
      customAlert(
        context,
        "Preencha seu email",
        24.0,
        "",
        0,
        [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CustomColors.dark),
            child: const Text(
              "Ok!",
              style: TextStyle(color: CustomColors.light, fontSize: 16.0),
            ),
          )
        ],
      );
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
