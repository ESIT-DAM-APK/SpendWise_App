import 'package:flutter/material.dart';
import 'package:test_flutter/views/history_transac.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart'; 
import 'views/menu_view.dart';




void main() {
    runApp(const MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APK PRESUPUESTO PERSONAL',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0 , 86, 8, 1), brightness: Brightness.light),
      useMaterial3: true),
     // home: const MyHomePage(title: 'PRESUPUESTO PERSONAL - GRUPO 6'),
        home: const LoginView(), // Cambié a LoginScreen
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  // Contenido de las páginas según el índice seleccionado
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen();

      case 1:
            return HistoryTransac();

      case 2:
        // return FormTransac(onSaved: () {
        //   setState(() {
        //     _selectedIndex = 0; // CAMBIAR A LA VISTA DE TRANSACCIONES
        //   });
        // });
        //return const Center(child: Text('Cerrar Sesion'));
        return const MenuView();
        
      default:
        return const Center(child: Text('Página desconocida'));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: _getSelectedPage()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.money), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
