class FirebaseErrorsMessages {
  // https://stackoverflow.com/questions/67617502/what-are-the-error-codes-for-flutter-firebase-auth-exception
  static Map<String, String> errors = {
    "wrong-password": "Senha incorreta",
    "user-not-found": "Usuário não encontrado",
    "invalid-credential": "Senha ou email incorretos",
    "email-already-in-use": "Este email já está em uso",
    "weak-password": "A senha precisa de no mínimo 6 caracteres",
    "invalid-email": "Email inválido",
  };
}
