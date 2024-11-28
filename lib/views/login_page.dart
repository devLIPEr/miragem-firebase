import 'package:flutter/material.dart';
import 'package:miragem_firebase/common/custom_colors.dart';
import 'package:miragem_firebase/components/custom_textfield.dart';
import 'package:miragem_firebase/services/firebase_auth_service.dart';
import 'package:miragem_firebase/views/register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final FirebaseAuthService authService = FirebaseAuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              Container(
                height: 250.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/imgs/logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              CustomTextField(
                  onChanged: (value) {},
                  keyboardType: TextInputType.text,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60.0,
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false),
              const SizedBox(height: 24.0),
              CustomTextField(
                  onChanged: (value) {},
                  keyboardType: TextInputType.text,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60.0,
                  controller: passwordController,
                  hintText: "Senha",
                  obscureText: true),
              const SizedBox(height: 12.0),
              GestureDetector(
                onTap: () =>
                    authService.sendForgetEmail(context, emailController),
                child: const Text(
                  "Esqueceu sua senha?",
                  style: TextStyle(color: CustomColors.link, fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 12.0),
              GestureDetector(
                onTap: () => authService.userSignIn(
                    context, emailController, passwordController),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: CustomColors.light,
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                        color: CustomColors.dark,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Ainda não tem uma conta? ",
                    style: TextStyle(color: CustomColors.dark, fontSize: 16.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Cadastre-se agora!",
                      style:
                          TextStyle(color: CustomColors.link, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
