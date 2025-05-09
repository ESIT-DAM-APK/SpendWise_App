import 'package:flutter/material.dart';
import 'package:test_flutter/views/add_transac.dart';
import 'package:test_flutter/views/history_transac.dart';
import 'package:test_flutter/views/login_view.dart';

class MenuView extends StatelessWidget {
  final int userId; // Añade este parámetro

  const MenuView({
    super.key,
    required this.userId, // Hazlo requerido
  });

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (Route<dynamic> route) => false,
    );
  }

  void _cambiarUsuario(BuildContext context) {
    _cerrarSesion(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.deepOrange,
          padding: const EdgeInsets.all(10),
          child: const Text(
            "Menu",
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 10),
        ListTile( // Eliminado 'const' aquí
          title: const Text("Bienvenido", style: TextStyle(color: Colors.grey)),
          subtitle: Text("Usuario $userId", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Divider(),
        ListTile(
          title: const Text("Historial"),
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => HistoryTransac(
                  userId: userId,
                  onNavBarTap: () {},
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text("Agregar Ingreso"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormTransac(
                  userId: userId,
                  onSaved: () {},
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text("Agregar Gasto"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormTransac(
                  userId: userId,
                  onSaved: () {},
                ),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("Cambiar de usuario"),
          onTap: () => _cambiarUsuario(context),
        ),
        ListTile(
          title: const Text(
            "Cerrar sesión",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _cerrarSesion(context),
        ),
      ],
    );
  }
}