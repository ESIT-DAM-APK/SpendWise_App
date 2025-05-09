import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart';
import 'package:test_flutter/helpers/modal_helpers.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String tipo)? onVerDetalles; // nuevo parámetro
  final int userId; // Añade este parámetro
  final String userName; // Nuevo parámetro para el nombre



  const DashboardScreen({
    super.key, 
    this.onVerDetalles,
    required this.userId, 
    required this.userName
    });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Función que se llama para actualizar la vista
  void _refreshData() {
    setState(() {}); // Llamamos a setState para que se recargue el FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.userName}', // Muestra el nombre
               style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),        backgroundColor: Colors.deepOrange, 
               centerTitle: false,
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _getTotalAmounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final totalIngresos = snapshot.data?['ingresos'] ?? 0.0;
            final totalGastos = snapshot.data?['gastos'] ?? 0.0;
            final saldo = totalIngresos - totalGastos;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '\$${saldo.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Saldo Disponible',
                          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCard(
                    context,
                    title: 'Ingresos',
                    amount: totalIngresos,
                    color: Colors.green,
                    onPressed: () {
                      widget.onVerDetalles?.call('Ingreso'); // title será 'Ingreso' o 'Gasto'
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    title: 'Gastos',
                    amount: totalGastos,
                    color: Colors.red,
                    onPressed: () {
                      widget.onVerDetalles?.call('Gasto'); // title será 'Ingreso' o 'Gasto'
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                        onPressed: () => showAddIngresoModal(
                          context,
                          refreshData: _refreshData,
                          userId: widget.userId, // Accede a userId a través de widget
                        ),
                      ),
                      _buildNavButton(
                        icon: Icons.arrow_downward,
                        color: Colors.red,
                        onPressed: () => showAddGastoModal(
                          context,
                          refreshData: _refreshData, // Aquí también
                          userId: widget.userId, // Accede a userId a través de widget
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return const Center(child: Text('No data available.'));
        },
      ),
    );
  }

  Future<Map<String, double>> _getTotalAmounts() async {
    final totalIngresos = await TransacDatabase.instance.getTotalAmount('Ingreso', widget.userId);
    final totalGastos = await TransacDatabase.instance.getTotalAmount('Gasto', widget.userId);

    return {
      'ingresos': totalIngresos,
      'gastos': totalGastos,
    };
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required double amount,
      required Color color,
      required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Asegúrate que el tipo sea exactamente 'Ingreso' o 'Gasto' (sin mayúsculas inconsistentes)
              final tipo = title == 'Ingresos' ? 'Ingreso' : 'Gasto';
              print('Enviando filtro: $tipo');
              widget.onVerDetalles?.call(tipo);
            },
              // onPressed: () {
              //   // Asegúrate de pasar exactamente 'Ingreso' o 'Gasto'
              //   final tipo = title.toLowerCase().contains('ingreso') ? 'Ingreso' : 'Gasto';
              //   widget.onVerDetalles?.call(tipo);

              //   print('Navegando al historial con filtro: $tipo');

              // },
              style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ver detalles',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
