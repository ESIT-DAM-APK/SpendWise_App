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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpendWise APP',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0, 86, 8, 0.612))),
      home: const LoginView(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _filterTipo;
  bool _ignoreNavBarTap = false;


  // Contenido de las páginas según el índice seleccionado
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onVerDetalles: (String tipo) {
            setState(() {
              _filterTipo = tipo;
              _selectedIndex = 1;
              _ignoreNavBarTap = true; // Ignorar el próximo onNavBarTap
            });
          },
        );
      case 1:
        return HistoryTransac(
          filtroTipo: _filterTipo,
          onNavBarTap: () {
            if (!_ignoreNavBarTap) {
              setState(() {
                _filterTipo = null;
              });
            }
            _ignoreNavBarTap = false;
          },
        );
      case 2:
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
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Pacifico',
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(0,86,60,100),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(child: _getSelectedPage()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
            // Resetear el filtro cuando se selecciona el historial desde el NavBar
            if (index == 1) {
              _filterTipo = null;
            }
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