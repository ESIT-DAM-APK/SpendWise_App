import 'package:flutter/material.dart';
import '../database/transac_database.dart';
import '../models/user_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? message;

  void _register() async {
    try {
      await TransacDatabase.instance.insertUser(UserModel(
        username: _userController.text,
        password: _passController.text,
      ));

      setState(() {
        message = "¡Usuario registrado!";
      });

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        message = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 125, 17, 0.612),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen circular
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Logo4.jpg', // Asegúrate de que la imagen esté en la carpeta assets
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Carta blanca de registro
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Registro",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _userController,
                      decoration: const InputDecoration(labelText: "Usuario"),
                    ),
                    TextField(
                      controller: _passController,
                      decoration: const InputDecoration(labelText: "Contraseña"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Registrarse", style: TextStyle(color: Colors.white)),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(message!, style: const TextStyle(color: Colors.green)),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
