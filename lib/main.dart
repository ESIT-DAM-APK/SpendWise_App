import 'package:flutter/material.dart';
import 'package:test_flutter/views/history_transac.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart'; 
import 'views/menu_view.dart';
import 'database/transac_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Future(() async {
    const bool isDevelopment = true; // Cambiar a false en producción
    
    if (isDevelopment) {
      await TransacDatabase.instance.deleteAppDatabase();
      await TransacDatabase.instance.database;
    }
    
    runApp(const MyApp());
  });
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
  int currentUserId = 1; // Esto debería venir de tu sistema de autenticación
  bool _ignoreNavBarTap = false;
  String currentUserName = "Usuario"; // Nombre del usuario - inicializado por defecto

    // Método para cargar datos del usuario
  Future<void> _loadUserData() async {
    final db = await TransacDatabase.instance.database;
    final user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [currentUserId],
      limit: 1,
    );
    
    if (user.isNotEmpty && mounted) {
      setState(() {
        currentUserName = user.first['username'] as String;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos del usuario al iniciar
  }



  // Contenido de las páginas según el índice seleccionado
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          userId: currentUserId, // Pasa el ID del usuario actual
          userName: currentUserName, // Pasa el nombre del usuario


          onVerDetalles: (String tipo) {
            setState(() {
              _filterTipo = tipo;
              _selectedIndex = 1;
              _ignoreNavBarTap = true;
            });
          },
        );
      case 1:
        return HistoryTransac(
          userId: currentUserId, // Pasa el ID del usuario actual
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
        return MenuView(
          userId: currentUserId, // Pasa el userId actual
        );
      // Aquí puedes agregar más páginas según sea necesario
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