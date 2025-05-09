import 'package:flutter/material.dart';
import '../database/transac_database.dart';
import 'register_view.dart';
import 'package:test_flutter/main.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  String? error;

  void _login() async {
    final user = await TransacDatabase.instance
        .login(_userController.text, _passController.text);

    if (user != null) {
      Navigator.pushReplacement(
        context,
       // MaterialPageRoute(builder: (context) => const DashboardScreen()),
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'SpendWise APP' )),
      );
    } else {
      setState(() {
        error = "Usuario o contraseña incorrecta";
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
                    'assets/images/Logo4.jpg',
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Carta blanca
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
                    const Text("Inicio de Sesión",
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
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Ingresar", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterView()));
                      },
                      child: const Text("¿No tienes cuenta? Regístrate"),
                    )
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
